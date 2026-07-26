--- packets で送受信する関数はここ

local M = {}

local packets = require 'packets'
local control = require 'control'
local keyboard = require 'keyboard'
local utils = require 'utils'

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

M.target_by_mob_ex = function(mob)
    M.target_by_mob(mob)
    while control.auto do
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
	    break
	end
    end
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
