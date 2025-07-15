local acpos = require 'pos'
local aczone = require 'zone'
local io_chat = require 'io/chat'

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
    local automatic_routes = zone_object.automatic_routes
    if automatic_routes ~= nil then
	coroutine.sleep(2)
	local pos = acpos.currentPos()
	coroutine.sleep(3)
	if acpos.isNear(pos, 1) then
	    for f, t in pairs(automatic_routes) do
		local fp = zone_object.essentialPoints[f]
		if acpos.isNear(fp, 10) then
		    io_chat.print(f.."から"..t.."に移動")
		    acpos.moveTo(zone_object.routes[t], zone_object.routes)
		end
	    end
	end
    end
end

function M.warp_handler(zone, pos, prevZone, prevPos)
    -- print("zone/change: warp_handler", zone, pos)
end

return M
