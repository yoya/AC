local acpos = require 'pos'
local aczone = require 'zone'

local M = {}

function M.zone_change_handler(zone, prevZone)
    print("zone/change zone_change_handler", zone, prevZone)
    local zone_object = aczone.zoneTable[zone]
    if zone_object == nil then
	return
    end
    local change_handler = zone_object.zone_change_handler
    if change_handler ~= nil then
	print("zone_change_handler found")
	change_handler(zone, prevZone)
    end
    local automove_handler = zone_object.automove_handler
    if automove_handler ~= nil then	
	print("automove_handler found")
	local pos1 = acpos.currentPos()
	coroutine.sleep(5)
	local pos2 = acpos.currentPos()
	if acpos.distance(pos1, pos2) < 1.0 then
	    automove_handler(zone, prevZone)
	end
    end
end

return M
