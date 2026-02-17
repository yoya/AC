--- packets で送受信する関数はここ

local packets = require 'packets'
local control = require 'control'
local M = {}

-- https://github.com/DiscipleOfEris/Assist/blob/master/assist.lua
M.targetByMob = function(mob)
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

M.targetByMobName = function(name)
    local mob = windower.ffxi.get_mob_by_name(name)
    if mob == nil then
	print("io/net.targetByMobName mob == nil name:"..name)
	return false
    end
    return M.targetByMob(mob)
end

M.targetByMobId = function(mobId)
---    print("tagetByMobId", mobId)
    local player = windower.ffxi.get_player()
    packets.inject(packets.new('incoming', 0x58, {
        ['Player'] = player.id,
        ['Target'] = mobId,
        ['Index'] = player.index
    }))
end

M.targetByMobIndex = function(mobIndex)  -- 動かない？
    if control.debug then
	print("WARNING: io/net.targetByMobIndex:", mobIndex)
    end
    if mobIndex == 0 then
        print("ERROR: io/net.targetByMobIndex mobIndex:", mobIndex)
        return
    end
    local mob = windower.ffxi.get_mob_by_index(mobIndex)
    if mob == nil then
	print("io/net.targetByMobIndex mob not found by index:", mobIndex)
        return
    end
    M.targetByMob(mob)
end

return M
