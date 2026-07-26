--- packets で送受信する関数はここ

local M = {}

local packets = require 'packets'
local control = require 'control'
local keyboard = require 'keyboard'
local utils = require 'utils'
local io_chat = require 'io/chat'

-- https://github.com/DiscipleOfEris/Assist/blob/master/assist.lua
M.target_by_mob = function(mob)
    if mob == nil then
	print(debug.traceback())
	return
    end
---    print("tagetByMobId", mobId)
    local player = windower.ffxi.get_player()
    packets.inject(packets.new('incoming', 0x58, {
        ['Assist Id'] = player.id,
	['Assist Index'] = player.index,
        ['Player'] = player.id,
	['Player Index'] = player.index,
	['Target'] = mob.id,
	['Target Index'] = mob.index,
    }))
    return true
end

-- ターゲットが一致するまで tab を押し直す。
-- 対象がターゲット不能になると無限に押し続けるので上限を設ける。
local TARGET_RETRY_MAX = 20  -- 約 0.7 秒 x 20 = 14 秒

M.target_by_mob_ex = function(mob)
    M.target_by_mob(mob)
    local retry = 0
    while control.auto do
	retry = retry + 1
	if retry > TARGET_RETRY_MAX then
	    io_chat.warnf("target_by_mob_ex: %s を掴めないので諦める",
			  mob and mob.name or "(nil)")
	    return false
	end
	coroutine.sleep(0.3)
	local m = windower.ffxi.get_mob_by_target("t")
	if m ~= nil then
	    -- print("m.index ~= mob.index", m.index, mob.index)
	end
	if m == nil or m.index ~= mob.index then
	    -- print("tab")
	    utils.target_lockon(false)
	    coroutine.sleep(0.2)
	    keyboard.push_keys({"tab"})
	    M.target_by_mob(mob)
	    coroutine.sleep(0.2)
	else
	    -- print("mob match")
	    return true
	end
    end
    return false
end

M.target_by_mob_name = function(name)
    local mob = windower.ffxi.get_mob_by_name(name)
    if mob == nil then
	print("io/net.target_by_mob_name mob == nil name:"..name)
	return false
    end
    return M.target_by_mob(mob)
end

M.target_by_mob_id = function(mobId)
---    print("tagetByMobId", mobId)
    local player = windower.ffxi.get_player()
    packets.inject(packets.new('incoming', 0x58, {
        ['Player'] = player.id,
        ['Target'] = mobId,
        ['Index'] = player.index
    }))
end

M.target_by_mob_index = function(mobIndex)  -- 動かない？
    if control.debug then
	print("WARNING: io/net.target_by_mob_index:", mobIndex)
    end
    if mobIndex == 0 then
        print("ERROR: io/net.target_by_mob_index mobIndex:", mobIndex)
        return
    end
    local mob = windower.ffxi.get_mob_by_index(mobIndex)
    if mob == nil then
	print("io/net.target_by_mob_index mob not found by index:", mobIndex)
        return
    end
    M.target_by_mob(mob)
end

return M
