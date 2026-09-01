-- リーダー (またはプラー) の待機時処理。
-- 敵を探して釣り、いなければ base_pos に戻る。

local M = {}

local control = require 'control'
local command = require 'command'
local task = require 'task'
local utils = require 'utils'
local acmob = require 'mob'
local ac_target = require 'ac/target'
local acprob = require 'prob'
local pull = require 'pull'
local ac_move = require 'ac/move'

local get_mob_position = acmob.get_mob_position

-- 優先して釣る敵
M.preferred_enemy_list = {
    -- カオス戦
    "Profane Circle", "Chaos",
    -- コロナイズ
    "Knotted Root", "Bedrock Crag", "Icy Palisade",
    -- 醴泉島
    "Wretched Poroggo", "Water Elemental",
    "Indomitable Faaz", "Devouring Mosquito",
    -- ドメインベーション
    "Azi Dahaka's Dragon", "Azi Dahaka",
    "Naga Raja's Lamia", "Naga Raja",
    "Quetzalcoatl's Sibilus", "Quetzalcoatl",
    "Mireu",
    -- 実験
    -- "Apex Jagil",  -- 2026/8/26 強化された？
    -- 火曜日なのにモンクMlv39、リコイルダイブで2143ダメージ
    --"Apex Toad",  -- ウォーの門、トード。
    "Mourioche",  -- マンドラ
    -- アルタナM
    "Cait Sith Ceithir",
}

-- base_pos から離れているか。tick をまたいで保持する
local is_far = false
-- 往復検知用に前回の向きを覚えておく
local prev_dx = 0
local prev_dy = 0

-- リンク中 > 優先敵 > 最寄り、の順に釣る敵を探す
local search_target = function(me_pos)
    -- リンクしてる敵
    local mob = acmob.search_nearest_mob(me_pos, {
        range = control.enemy_range,
        linked_only = true,
    })
    -- 優先する敵
    if mob == nil then
        mob = acmob.search_nearest_mob(pull.base_pos, {
            range = control.enemy_range,
            prefer_mobs = utils.table.merge_lists(acmob.more_attractive_enemy_list,
                                                  M.preferred_enemy_list),
            name_match = control.enemy_filter,
        })
    end
    -- 優先度の高い敵がいない場合は、誰でも良い
    if mob == nil then
        mob = acmob.search_nearest_mob(pull.base_pos, {
            range = control.enemy_range,
            name_match = control.enemy_filter,
        })
    end
    return mob
end

-- ゾーン移動やワープをまたぐと、覚えている向きは意味を失う。base_pos は
-- 別に捨てられるので、往復検知の状態だけ初期に戻す
function M.reset_move()
    is_far = false
    prev_dx = 0
    prev_dy = 0
    -- ゾーンチェンジ中やログアウト後は me を引けない。その時は走っていない
    if windower.ffxi.get_mob_by_target("me") ~= nil then
        ac_move.want_stop()
    end
end

function M.tick_idle(player, me)
    local me_pos = {}
    if get_mob_position(me_pos, "me") ~= true then
        -- zone チェンジでよくある
        return
    end
    local mob = search_target(me_pos)
    if mob ~= nil and control.attack then
        ac_move.want_stop()
        -- 掴めた時だけ撃つ。掴めていない <t> に /attack on を撃つと、
        -- その時たまたま乗っている味方を殴りに行く。実際に撃つのは末尾
        if not ac_target.want(mob) then
            return
        end
    elseif pull.base_pos ~= nil then
        -- 敵がいなければ base_pos に戻る
        local dx = pull.base_pos.x - me_pos.x
        local dy = pull.base_pos.y - me_pos.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 4 then
            is_far = true
        end
        if is_far then
            ac_move.want_run(dx, dy)
            if dist < 2 then
                ac_move.want_stop()
                is_far = false
            end
        end
        -- near の範囲を通り過ぎると永久に往復するのでその対処
        local similarity = utils.vector.CosineSimilarity({x=dx, y=dy},
                                                         {x=prev_dx, y=prev_dy})
        prev_dx = dx
        prev_dy = dy
        if similarity < -0.8 then
            -- 逆向きに動いたら近くになったと判断して停止
            is_far = false
            coroutine.sleep(0.2)
            ac_move.want_stop()
        end
    end
    -- 敵を見つけた時だけ。/attack on はその時の <t> に効くので、mob が nil の
    -- まま毎 tick 送ると、倒した敵の後にオートターゲットで乗った味方などを
    -- 撃ち続けて「攻撃対象ではありません」が出続ける
    if control.attack and mob ~= nil then
        command.send('input /attack on')
        acprob.clear_prob_recast_time()
        task.reset_by_fight()
    end
end

return M
