-- フォロワー (リーダー以外) の待機時処理

local M = {}

local control = require 'control'
local command = require 'command'
local task = require 'task'
local acitem = require 'item'
local item_data = require 'item/data'
local acmob = require 'mob'
local ac_move = require 'ac/move'
local ac_pos = require 'ac/pos'
local io_net = require 'io/net'
local acprob = require 'prob'
local pstatus = require 'player_status'

local crystal_ids = item_data.crystal_ids -- クリスタル/塊
local get_mob_position = acmob.get_mob_position
local turn_to_target = ac_move.turn_to_target
local turn_to_front = ac_move.turn_to_front

-- リーダーから離れているか。tick をまたいで保持する
local is_far = false

-- p1 が乗り物系のワープギミックを触った時、追随する対象
local warp_gimmick_names = {
    "Home Point", "Survival Guide", "Shimmering Circle", "Waypoint",
    "Nunaarl Bthtrogg", "Undulating Confluence",
    "Echo Disseminator",  -- WoE
    "Veridical Conflux",  -- WoE
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
local sync_mount = function(player, p1)
    if p1.status == pstatus.MOUNTED and player.status ~= pstatus.MOUNTED then
        command.send('input /mount ラプトル')
    elseif p1.status ~= pstatus.MOUNTED and player.status == pstatus.MOUNTED then
        command.send('input /dismount')
    end
end

-- リーダー(p1)を追う。まだ追従中で戦闘に移れないなら true を返す。
-- 離れたことに確率的に気づかせているのは、人間らしい遅延を出すため。
local follow_leader = function(me_pos, leader_pos, p1)
    local dx = leader_pos.x - me_pos.x
    local dy = leader_pos.y - me_pos.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if p1.hpp > 0 then
        if math.random(1, 3) <= 2 and dist > math.random(3, 5) and dist < 24 then
            is_far = true
        elseif dist > math.random(6, 7) then -- 離れすぎたらすぐ気付く
            is_far = true
        end
    end
    if is_far then
        turn_to_target("p1")
        turn_to_front()
        windower.ffxi.run(dx, dy)
        if dist > math.random(2, 4) then
            return true  -- まだ遠いので今 tick は追従だけ
        end
    end
    is_far = false
    windower.ffxi.run(false)
    return false
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
local follow_warp_gimmick = function(p1)
    if p1.target_index == 0 then
        return
    end
    local target = windower.ffxi.get_mob_by_index(p1.target_index)
    if target ~= nil and is_warp_gimmick(target.name) then
        io_net.target_by_mob_index(p1.target_index)
        windower.ffxi.run(true)
    end
end

-- 敵にターゲットして近接攻撃する
local attack_enemy = function(p1, me_pos, item_level)
    windower.ffxi.run(false)
    local mob = windower.ffxi.get_mob_by_target("bt")
    if mob ~= nil then
        command.send('input /target <bt>')
    else
        mob = acmob.search_nearest_mob(me_pos, {
            range = control.enemy_range,
            linked_only = true,
        })
    end
    if mob == nil then
        --- p1 がターゲットしてる敵に合わせる
        if p1.status ~= pstatus.ENGAGED or p1.target_index == 0 then
            return
        end
        local target = windower.ffxi.get_mob_by_index(p1.target_index)
        if target == nil or target.status ~= pstatus.ENGAGED then
            return  -- 敵と戦闘開始してなければ様子見
        end
        -- p1 が戦闘している敵にターゲット
        io_net.target_by_mob_index(p1.target_index)
        mob = windower.ffxi.get_mob_by_target("t")
    end
    if mob ~= nil then
        io_net.target_by_mob(mob)
        if item_level >= 119 or mob.hpp < 100 then
            -- 5 が近接攻撃できるギリギリの距離
            if ac_pos.distance(p1, mob) <= 5 then  -- 敵が近づくまで待つ
                coroutine.sleep(math.random(0,2)/4)
                command.send('input /attack <t>')
                task.reset_by_fight()
            end
        end
    end
    acprob.clear_prob_recast_time()
end

function M.tick_idle(player, me)
    if not player then
        return
    end
    stow_crystals()
    --- p1 がリーダーだと仮定。(リーダーというよりフォローする対象が p1)
    local p1 = windower.ffxi.get_mob_by_target("p1")
    if p1 == nil then
        return  -- リーダーがいない
    end
    sync_mount(player, p1)
    local me_pos = {}
    local leader_pos = {}
    get_mob_position(me_pos, "me")
    get_mob_position(leader_pos, "p1")
    if leader_pos.x == nil then
        return
    end
    if follow_leader(me_pos, leader_pos, p1) then
        return  -- まだリーダーに追従中
    end
    if not can_join_battle(player.item_level) then
        return
    end
    -- ワープギミックは attack が off でも追随する
    follow_warp_gimmick(p1)
    if control.attack then
        attack_enemy(p1, me_pos, player.item_level)
    end
end

return M
