local aczone = require 'zone'
local ac_pos = require 'ac/pos'
local ac_move = require 'ac/move'
local ac_stat = require 'ac/stat'
local io_chat = require 'io/chat'

local M = {}

function posStr(pos)
    if pos == nil then
	return "(nil)"
    end
    if type(pos) ~= "table" then
	return "(no table)"
    end
    if pos.x == nil then
	return "(nopos)"
    end
    local str = math.round(pos.x,2) .. "," .. math.round(pos.y,2)
    if pos.z ~= nil then
	str = str .. "," .. math.round(pos.z, 2)
    end
    return str
end

function M.automatic_routes_handler(zone, automatic_routes)
    local zone_object = aczone.zoneTable[zone]
    if zone_object == nil then
	return
    end
    coroutine.sleep(2)
    local pos = ac_pos.currentPos()
    coroutine.sleep(3)
    if ac_pos.isNear(pos, 1) then
	for f, t in pairs(automatic_routes) do
	    local fp = zone_object.essentialPoints[f]
	    if ac_pos.isNear(fp, 10) then
		io_chat.print(f.."から"..t.."に移動")
		ac_move.moveTo(zone_object.routes[t], zone_object.routes)
	    end
	end
    end
end

function M.zone_change_handler(zone, prevZone)
    print("zone/change zone_change_handler", zone, prevZone)
    ac_stat.init()
    -- zone 毎の処理
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
	M.automatic_routes_handler(zone, automatic_routes)
    end
end

function M.warp_handler_tick()
    local zone = windower.ffxi.get_info().zone
    local pos = ac_pos.currentPos()
    if zone == nil or pos == nil then
	return
    end
    -- print("M.warp_handler_tick", zone,  ac_pos.distance(pos, prevPos))
    if M.prevZone == zone then
	local dist = ac_pos.distance(pos, prevPos)
	-- 東アドゥリンWP、レンタル<=>競売が 36.8
	if  dist > 32 then
	    M.warp_handler(zone, pos, prevZone, prevPos, dist)
	end
    end
    M.prevZone = zone
    M.prevPos = pos
end

-- 同じ zone でワープした時。WP や AMANトローブ
function M.warp_handler(zone, pos, prevZone, prevPos, dist)
    print("zone/change:warp " .. zone .. ":" .. posStr(pos) .. " << " .. prevZone .. ":" ..  posStr(prevPos) .. " dist:" ..  math.round(dist, 2))
    local zone_object = aczone.zoneTable[zone]
    if zone_object == nil then
	return
    end
    local automatic_routes = zone_object.automatic_routes
    if automatic_routes ~= nil then
	M.automatic_routes_handler(zone, automatic_routes)
    end
end

return M
