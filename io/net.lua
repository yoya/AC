--- packets で送受信する関数はここ

local packets = require 'packets'

local M = {}

M.targetByMobId = function(mobId)
---    print("tagetByMobId", mobId)
    local player = windower.ffxi.get_player()
    packets.inject(packets.new('incoming', 0x58, {
        ['Player'] = player.id,
        ['Target'] = mobId,
        ['Index'] = player.index
    }))
end

M.targetByMobIndex= function(mobIndex)
---    print("tagetByMobId", mobId)
    if mobIndex == 0 then
        print("targetByMobIndex mobIndex: "..mobIndex)
        return
    end
    local player = windower.ffxi.get_player()
    local mob = windower.ffxi.get_mob_by_index(mobIndex)
    if mob == nil then
        return
    end
    packets.inject(packets.new('incoming', 0x58, {
        ['Player'] = player.id,
        ['Target'] = mob.id,
        ['Index'] = player.index
    }))
end

return M
