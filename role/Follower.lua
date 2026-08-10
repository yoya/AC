-- フォロワー (リーダー以外) の待機時処理

local M = {}

local control = require 'control'
local command = require 'command'
local utils = require 'utils'
local task = require 'task'
local acitem = require 'item'
local item_data = require 'item/data'
local acmob = require 'mob'
local ac_move = require 'ac/move'
local io_net = require 'io/net'
local acprob = require 'prob'
local ac_party = require 'ac/party'
local pstatus = require 'player_status'

local crystal_ids = item_data.crystal_ids -- クリスタル/塊
local get_mob_position = acmob.get_mob_position
local turn_to_pos = ac_move.turn_to_pos
local turn_to_front = ac_move.turn_to_front

-- リーダーから離れているか。tick をまたいで保持する
local is_far = false

-- リーダーを見失った時に向かう、最後に見えた位置と、そこへ走る期限
local last_leader_pos = nil
local lost_leader_deadline = 0
-- 見えなくなってから、最後の位置へ走り続ける上限
local LOST_LEADER_SEC = 30

-- リーダーの交戦相手に乗る距離。これより遠い敵には乗らない
local JOIN_BATTLE_RANGE = 10

-- tick は control.period (既定 1秒) 周期。その間 run の向きを固定すると
-- 動くリーダーには追い付けないので、tick の中で向きを出し直しながら走る。
-- ac/move.lua の move_to が自動移動でやっているのと同じ考え方。
local FOLLOW_STEP_SEC = 0.15
local FOLLOW_STEP_NUM = 5

-- 走行速度 (yalm/秒)。最後のステップで走り過ぎないよう、残り距離を走る時間に
-- 直すのに使う。実際がこれより速くても FOLLOW_STEP_SEC で頭打ちになるだけなので、
-- 装備やマウントで速くなる分は見ずに基本値のままにしておく。
local RUN_SPEED = 5.0

-- 追従を始める距離と、止まる距離。tick 毎に引き直すと同じ場所で「遠い/近い」が
-- 入れ替わって落ち着かないので、追従が終わった時に一度だけ引いて、次に歩き出す
-- までその値を使う。開始と停止の間は必ず空ける (重なると振動する)。
local start_dist, start_dist_engaged, stop_dist

-- 直前の追従で走った向き。行き過ぎ (向きが反転) の検出に使う
local last_run_vec = nil

-- 歩き出す距離を乱数にしているのは、非戦闘時に人間らしい遅延を出すため
local roll_follow_dist = function()
    stop_dist = math.random(2, 3)
    start_dist = math.random(5, 6)
    start_dist_engaged = math.random(7, 8)
end
roll_follow_dist()

-- p1 が乗り物系のワープギミックを触った時、追随する対象
local warp_gimmick_names = {
    "Home Point", "Survival Guide", "Waypoint",
    "Shimmering Circle", "Shaft Entrance",
    "Nunaarl Bthtrogg", "Undulating Confluence",
    "Echo Disseminator", "Veridical Conflux", -- WoE
    "Ethereal", "Affi", "Dremi", "Shiftrix", "Dimmian",
    "Diaphanous",  -- ソーティ
    "Swirling Vortex",  -- アポリオン
    "???",
}

local is_warp_gimmick = function(name)
    for _, n in ipairs(warp_gimmick_names) do
	if string.find(name, n) then
	    return true
	end
    end
    return false
end

-- 溜まったクリスタルをバッグに退避する
local stow_crystals = function()
    if not acitem.check_bags_freespace() then
        return
    end
    for _, id in pairs(crystal_ids) do
        if acitem.inventory_has_item(id) then
            acitem.move_to_bags(id)
        end
    end
end

-- マウント状態をリーダーに合わせる
local sync_mount = function(player, leader)
    if leader.status == pstatus.MOUNTED and player.status ~= pstatus.MOUNTED then
        command.send('input /mount ラプトル')
    elseif leader.status ~= pstatus.MOUNTED and player.status == pstatus.MOUNTED then
        command.send('input /dismount')
    end
end

-- リーダーが見えている間、最後の位置を覚えておく
local remember_leader = function(leader)
    last_leader_pos = {x = leader.x, y = leader.y}
    lost_leader_deadline = os.time() + LOST_LEADER_SEC
end

-- リーダーを追う。まだ追従中で戦闘に移れないなら true を返す。
-- engaged が真 (リーダーが戦闘中) のときは交戦を優先し、ゆるい追従は
-- 抑える。離れすぎたときだけ追いつく。
local follow_leader = function(me_pos, leader, engaged)
    local dx = leader.x - me_pos.x
    local dy = leader.y - me_pos.y
    local dist = math.sqrt(dx*dx + dy*dy)
    local was_far = is_far
    if leader.hpp > 0 then
        if not engaged and dist > start_dist then
            is_far = true  -- 非戦闘時のゆるい追従
        elseif dist > start_dist_engaged then -- 離れすぎたらすぐ気付く (戦闘中でも)
            is_far = true
        end
    end
    if not is_far then
        windower.ffxi.run(false)
        last_run_vec = nil
        return false
    end
    if not was_far then
        -- 追従を始める時だけ。毎 tick 送ると視点が動きっぱなしになる
        turn_to_front()
    end
    local arrived = false
    for _ = 1, FOLLOW_STEP_NUM do
        local mob = ac_party.leader_mob()
        local me = windower.ffxi.get_mob_by_target("me")
        if mob == nil or mob.x == nil or me == nil then
            break  -- 見失った。次の tick で拾い直す
        end
        remember_leader(mob)
        dx = mob.x - me.x
        dy = mob.y - me.y
        dist = math.sqrt(dx*dx + dy*dy)
        if dist <= stop_dist then
            arrived = true
            break
        end
        if last_run_vec ~= nil and
            utils.vector.CosineSimilarity(last_run_vec, {x=dx, y=dy}) < 0 then
            -- 前に走った向きの逆を向いた = リーダーを追い越している。ここで
            -- 走ると追い越し直して往復になるので、着いたものとして止める
            arrived = true
            break
        end
        turn_to_pos(me.x, me.y, mob.x, mob.y)
        windower.ffxi.run(dx, dy)
        last_run_vec = {x = dx, y = dy}
        -- 残り距離のぶんだけ走る。まるごと走ると stop_dist を踏み越える
        coroutine.sleep(math.min(FOLLOW_STEP_SEC, (dist - stop_dist) / RUN_SPEED))
    end
    if not arrived then
        -- 最後のステップの後は距離を測っていない。古い距離で走り続けると
        -- 次の tick まで無補正で進んでリーダーを追い越すので、測り直して決める
        local mob = ac_party.leader_mob()
        local me = windower.ffxi.get_mob_by_target("me")
        if mob == nil or mob.x == nil or me == nil then
            windower.ffxi.run(false)  -- 測れないので走らせたままにしない
            return true
        end
        dx = mob.x - me.x
        dy = mob.y - me.y
        if math.sqrt(dx*dx + dy*dy) > stop_dist then
            return true  -- まだ遠いので今 tick は追従だけ
        end
    end
    is_far = false
    last_run_vec = nil
    windower.ffxi.run(false)
    roll_follow_dist()  -- 次に歩き出す距離を決める
    return false
end

-- リーダーが描画範囲外に出ると mob を引けない。そこで止まると永久に
-- 置いていかれるので、最後に見えた位置まで走って拾い直しを狙う。
local follow_lost_leader = function(me_pos)
    if last_leader_pos == nil or me_pos.x == nil then
        return
    end
    local dx = last_leader_pos.x - me_pos.x
    local dy = last_leader_pos.y - me_pos.y
    if math.sqrt(dx*dx + dy*dy) < 3 or os.time() > lost_leader_deadline then
        -- 着いた、もしくは追い切れない (ワープした等)。諦める
        last_leader_pos = nil
        is_far = false
        last_run_vec = nil
        windower.ffxi.run(false)
        return
    end
    turn_to_pos(me_pos.x, me_pos.y, last_leader_pos.x, last_leader_pos.y)
    windower.ffxi.run(dx, dy)
    last_run_vec = {x = dx, y = dy}
end

-- 装備レベル的に戦闘に参加してよいか
local can_join_battle = function(item_level)
    -- 100以下は戦闘しない
    if item_level < 100 then
        return false
    end
    -- 119未満は無理しない, 109 は頑張る。潜在外し
    if item_level < 109 then
        local mob = windower.ffxi.get_mob_by_target("bt")
        if mob == nil or mob.hpp > 90 then
            return false  -- 戦闘直後は危ないので、戦いに参加しない
        end
    end
    return true
end

-- p1 がワープギミックを触ったら、その target まで追随する
local follow_warp_gimmick = function(leader)
    if leader.target_index == 0 then
        return
    end
    local target = windower.ffxi.get_mob_by_index(leader.target_index)
    if target ~= nil and is_warp_gimmick(target.name) then
        io_net.target_by_mob_index(leader.target_index)
        windower.ffxi.run(true)
    end
end

-- リーダーが戦っている敵を返す。まだ交戦していなければ nil
local leader_enemy = function(leader)
    if leader.status ~= pstatus.ENGAGED or leader.target_index == 0 then
        return nil
    end
    local mob = windower.ffxi.get_mob_by_index(leader.target_index)
    if mob == nil or mob.status ~= pstatus.ENGAGED then
        return nil  -- 敵と戦闘開始してなければ様子見
    end
    return mob
end

-- 交戦する敵を決める。リーダーが戦っている敵が最優先。リーダーがまだ
-- 交戦していない間だけ、自分に絡んでいる敵 (bt) や味方にヘイトが向いて
-- いる敵を拾う。順序を逆にすると、リーダーが次の敵に移った時に各自が
-- バラバラの敵を掴んで落ち着かない。
local search_enemy = function(leader, me_pos)
    -- 遠くの敵には乗らない。乗ると follow_leader を飛ばして敵へ直進するので、
    -- 釣ってキャンプへ戻るリーダーとすれ違い、道中の敵にリンクする。
    -- 追従でリーダーに追い付けば、その敵は自然と範囲に入る
    local mob = leader_enemy(leader)
    if mob ~= nil then
        local dx = mob.x - me_pos.x
        local dy = mob.y - me_pos.y
        if math.sqrt(dx*dx + dy*dy) <= JOIN_BATTLE_RANGE then
            return mob
        end
    end
    -- bt は倒した敵が消えるまで残る。素通しすると死体を交戦相手として
    -- 掴み続け、その間 tick_idle が追従を飛ばして死体の上で止まる。
    -- 他の2つと同じ検査を通す。
    mob = windower.ffxi.get_mob_by_target("bt")
    if mob ~= nil and acmob.is_mob_attackable(mob) then
        return mob
    end
    return acmob.search_nearest_mob(me_pos, {
        range = control.enemy_range,
        linked_only = true,
    })
end

-- 決めた敵に張り付いて近接攻撃する
local attack_enemy = function(mob, item_level)
    windower.ffxi.run(false)
    -- 既にこの敵をターゲットしているなら入れ直さない。ターゲットを
    -- 毎 tick 入れ直すと、その度にターゲットが揺れる。
    local t = windower.ffxi.get_mob_by_target("t")
    local retarget = (t == nil or t.index ~= mob.index)
    if retarget then
        io_net.target_by_mob(mob)
    end
    if item_level < 119 and mob.hpp >= 100 then
        return
    end
    -- 敵との距離は自分基準で測る (リーダー基準だと自分が範囲外でも
    -- 攻撃を撃って失敗する)。5 が近接攻撃できるギリギリの距離。
    local me = windower.ffxi.get_mob_by_target("me")
    local dx = mob.x - me.x
    local dy = mob.y - me.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist > 5 then
        -- 遠ければ敵へ詰める (リーダーではなく敵に寄る)
        turn_to_pos(me.x, me.y, mob.x, mob.y)
        windower.ffxi.run(dx, dy)
        return
    end
    windower.ffxi.run(false)
    if retarget then
        coroutine.sleep(0.3)  -- 注入直後の <t> はまだ切り替わっていない
    end
    coroutine.sleep(math.random(0,2)/4)
    command.send('input /attack <t>')
    task.reset_by_fight()
end

function M.tick_idle(player, me)
    if not player then
        return
    end
    stow_crystals()
    local me_pos = {}
    get_mob_position(me_pos, "me")
    -- フォローする対象は party スロット p1 ではなく実リーダー
    local leader = ac_party.leader_mob()
    if leader == nil or leader.x == nil then
        follow_lost_leader(me_pos)  -- リーダーがいない / 描画範囲外
        return
    end
    remember_leader(leader)
    sync_mount(player, leader)
    local joinable = can_join_battle(player.item_level)
    local enemy = nil
    if joinable and control.attack then
        enemy = search_enemy(leader, me_pos)
    end
    if enemy ~= nil then
        -- 交戦相手が決まったら移動は敵基準にする。リーダーと敵の両方を
        -- 追うと、行き先が tick 毎に入れ替わって落ち着かない。
        is_far = false
        last_run_vec = nil
    elseif follow_leader(me_pos, leader, leader.status == pstatus.ENGAGED) then
        return  -- まだリーダーに追従中
    end
    if not joinable then
        return
    end
    -- ワープギミックは attack が off でも追随する
    follow_warp_gimmick(leader)
    if enemy ~= nil then
        attack_enemy(enemy, player.item_level)
        acprob.clear_prob_recast_time()
    end
end

return M
