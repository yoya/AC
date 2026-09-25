local M = {}

local command = require 'command'
local io_net = require 'io/net'
local io_chat = require 'io/chat'

local ac_party = require 'ac/party'
local iam_leader = ac_party.iam_leader

local acmob = require 'mob'
local keyboard = require 'keyboard'
local pstatus = require 'player_status'
local push_keys = keyboard.push_keys
--local acjob = require 'job'
local acjob = __AC.job

-- これらの敵と戦っていて、それ以外の敵が現れた時は、
-- それ以外の方にターゲットを移す

local postpone_enemies = { -- ボス。後回し
    ["Chaos"] = true,
}

local prefer_enemy_table = { -- 先に倒すべき敵
    -- 巨人族
    "Profane Circle",      --  サークル
}

function search_prefer_enemy()
    local arr = {}
    for i, name in ipairs(prefer_enemy_table) do
	local mob = windower.ffxi.get_mob_by_name(name)
	if mob ~= nil then
	    -- io_chat.print("search_prefer_enemy", mob.name, mob.status)
	    if  mob.status == pstatus.IDLE or mob.status == pstatus.ENGAGED then
		table.insert(arr, mob)
	    end
	end
    end
    return arr
end

function search_enemy(range, excludeEmemy)
    -- print("search_enemy", range, excludeEmemy)
    -- 何故かアンバスでは常に空っぽが返る
    -- local mob_arr = windower.ffxi.get_mob_array()
    local mob_arr = search_prefer_enemy()
    -- io_chat.print("search_enemy: #mob_arr", #mob_arr)
    for i, mob in ipairs(mob_arr) do
	io_chat.set_next_color(8) -- 明るい赤紫
	io_chat.print("search_enemy name", excludeEmemy, mob.name)
	-- is_mob_attackable ではなく is_enemy。claim は見ない
	if acmob.is_enemy(mob) and mob.distance < range then
	    if mob.name ~= excludeEmemy then
		return mob
	    end
	end
    end
end

function M.tick(player)
    if player.status == pstatus.ENGAGED then
	local mob = windower.ffxi.get_mob_by_target("t")
	if mob == nil then
	    return
	end
	if mob.name == "Chaos" then
	    acjob.chaos_start()
	else
	    -- acjob.battle_start()
	end
	if postpone_enemies[mob.name] == true then
	    -- print("postpone_enemies")
	    local next_mob = search_enemy(30, mob.name)
	    if next_mob ~= nil then
		io_chat.set_next_color(8) -- 明るい赤紫
		io_chat.print("より優先度の高い敵を発見")
		command.send('input /attackoff <me>')
		io_net.target_by_mob(next_mob)
		command.send('wait 1; input /attack <t>')
	    end
	end
	-- 敵から距離があると近づく処理。飛ばされた後用
	if 5 < mob.distance then
            push_keys({"w", "w", "w"})
	end
    end
end

return M
