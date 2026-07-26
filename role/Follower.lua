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

local crystal_ids = item_data.crystal_ids -- クリスタル/塊
local get_mob_position = acmob.get_mob_position
local turn_to_target = ac_move.turn_to_target
local turn_to_front = ac_move.turn_to_front

-- リーダーから離れているか。tick をまたいで保持する
local isFar = false

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

function M.tick_idle(player, me)
---    print("I am not a leader")
    if not player then
        return
    end
    if acitem.check_bags_freespace() then
        for i, id in pairs(crystal_ids) do
            if acitem.inventory_has_item(id) then
                acitem.move_to_bags(id)
            end
        end
    end
---    local level = player.main_job_level
    local item_level = player.item_level
    local me_pos = {}
    local leader_pos = {}
    get_mob_position(me_pos, "me")
    --- p1 がリーダーだと仮定。(リーダーというよりフォローする対象が p1)
    local target_leader = "p1"
    local p1 = windower.ffxi.get_mob_by_target("p1")
    if p1 == nil then
	return  -- リーダーがいない
    end
    -- リーダーがマウントしてたら、自分もマウント
    if p1.status == 85 and player.status ~= 85 then
	command.send('input /mount ラプトル')
    end
    if p1.status ~= 85 and player.status == 85 then
	command.send('input /dismount')
    end
    get_mob_position(leader_pos, target_leader)
    if leader_pos.x == nil then
        return
    end
    local dx = leader_pos.x - me_pos.x
    local dy = leader_pos.y - me_pos.y
    local dist =  math.sqrt(dx*dx + dy*dy)
    -- リーダーと離れたのを確率的に気づくように
    -- あと離れすぎたり、エリアが違う時や、やめる。
    if p1.hpp > 0 then
	if math.random(1, 3) <= 2 and dist > math.random(3, 5) and
	    dist < 24 then
	    isFar = true
	elseif dist > math.random(6, 7) then -- 離れすぎたらすぐ気付く
	    isFar = true
	end
    end
    if isFar == true then
        turn_to_target(target_leader)
        turn_to_front()
        windower.ffxi.run(dx, dy)
        if dist > math.random(2, 4) then
            return
        end
    end
    isFar = false
    windower.ffxi.run(false)
    -- 100以下は 戦闘しない
    if item_level < 100 then
	return
    end
    -- 119未満は無理しない, 109 は頑張る。潜在外し
    if item_level < 109 then
        local mob = windower.ffxi.get_mob_by_target("bt")
        if mob == nil or mob.hpp > 90 then
            -- 戦闘直後は危ないので、戦いに参加しない
            return
        end
    end
    -- ワープギミックは target まで追随する。
    if p1.target_index ~= 0 then
	local target = windower.ffxi.get_mob_by_index(p1.target_index)
	if target ~= nil and is_warp_gimmick(target.name) then
	    -- print("p1 target Found", p1.target_index, target.index)
	    io_net.target_by_mob_index(p1.target_index)
	    windower.ffxi.run(true)
	end
    end
    if control.attack then
        windower.ffxi.run(false)
	local mob = windower.ffxi.get_mob_by_target("bt")
	if mob ~= nil then
	    command.send('input /target <bt>')
	else
	    local condition = {
		range = control.enemy_range,
		linkedOnly = true,
		-- nameMatch = control.enemy_filter,
	    }
	    mob = acmob.search_nearest_mob(me_pos, condition)
	end
	if mob == nil then
	    --- p1 がターゲットしてる敵に合わせる
	    if p1.status ~= 1 or p1.target_index == 0 then
		return
	    end
	    local target = windower.ffxi.get_mob_by_index(p1.target_index)
	    if target == nil or target.status ~= 1 then
		-- 敵と戦闘開始してなければ様子見
		return
	    end
	    -- p1 が戦闘している敵にターゲット
	    io_net.target_by_mob_index(p1.target_index)
	    mob = windower.ffxi.get_mob_by_target("t")
	end
	--if mob ~= nil and mob.hpp < 100 then
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
end

return M
