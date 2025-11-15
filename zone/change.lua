local aczone = require 'zone'
local ac_pos = require 'ac/pos'
local ac_move = require 'ac/move'
local ac_stat = require 'ac/stat'
local io_chat = require 'io/chat'
local command = require 'command'
local ac_party = require 'ac/party'
local iamLeader = ac_party.iamLeader
local task = require 'task'

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
    local player = windower.ffxi.get_player()
    local level = player.main_job_level
    coroutine.sleep(3)
    local pos = ac_pos.currentPos()
    coroutine.sleep(5)
    if ac_pos.isNear(pos, 0.5) then
	for f, t in pairs(automatic_routes) do
	    local fp = zone_object.essentialPoints[f]
	    if fp == nil or fp.x == nil then
		print("maybe esseialPoints illegal format")
		return
	    end
	    local route = t.route
	    local exec_auto_route = ac_pos.isNear(fp, 2)
	    if t.leader_only == true and not iamLeader() then
		io_chat.setNextColor(4) -- ピンク
		io_chat.print("移動するのはリーダーだけ")
		exec_auto_route = false
	    end
	    if t.need_level ~= nil and level < t.need_level then
		io_chat.setNextColor(4) -- ピンク
		io_chat.print("移動するのに level 20 必要")
		exec_auto_route = false
	    end
	    if exec_auto_route then
		io_chat.print(f.."から"..route.."に移動")
		ac_move.moveTo(zone_object.routes[route], zone_object.routes)
		break
	    end
	end
    end
end

function M.automatic_trust_handler(zone, automatic_trust)
    io_chat.print("automatic_trust")
    local zone_object = aczone.zoneTable[zone]
    if zone_object == nil then
	return
    end
    coroutine.sleep(3)
    for i, f in pairs(automatic_trust) do
	io_chat.print("automatic_trust:".. f)
	local c = string.format('input /ma %s <me>', f)
	command.send(c)
	coroutine.sleep(7)
    end
end

function M.zone_in_handler(zone, prevZone)
    -- zone in の処理
    local zone_object = aczone.zoneTable[zone]
    if zone_object ~= nil then
	local zone_in = zone_object.zone_in
	if zone_in ~= nil then
	    print("zone_in:", zone)
	    zone_in()
	end
	local automatic_routes = zone_object.automatic_routes
	if automatic_routes ~= nil then
	    M.automatic_routes_handler(zone, automatic_routes)
	end
	if iamLeader() then
	    local automatic_trust = zone_object.automatic_trust
	    if automatic_trust ~= nil then
		io_chat.setNextColor(6)
		io_chat.print("automatic_trust", automatic_trust);
		M.automatic_trust_handler(zone, automatic_trust)
	    end
	end
    end
end

function M.zone_change_handler(zone, prevZone)
    -- zone 毎の処理
    print("zone/change zone_change_handler", zone, prevZone)
    ac_stat.init()
    task.allClear()
    -- zone out の処理
    if prevZone == nil then
	print("ERROR: prevZone == nil")  -- 普通はありえない
    else
	local zone_out_object = aczone.zoneTable[prevZone]
	if zone_out_object ~= nil then
	    local zone_out = zone_out_object.zone_out
	    if zone_out ~= nil then
		print("zone_out:", prevZone)
		zone_out()
	    end
	end
    end
    -- zone in の処理
    local zone_object = aczone.zoneTable[zone]
    if zone_object ~= nil then
	M.zone_in_handler(zone, prevZone)
	local change_handler = zone_object.zone_change_handler
	if change_handler ~= nil then
	    print("zone_change_handler found")
	    change_handler(zone, prevZone)
	end
    end
end

function M.warp_handler_tick()
    -- print("M.warp_handler_tick()")
    local zone = windower.ffxi.get_info().zone
    local pos = ac_pos.currentPos()
    if zone == nil or pos == nil then
	return
    end
    if prevPos == nil then
	-- print("warp tick zone:"..zone, pos.x..","..pos.y, "prevPos==nil")
    else
	-- print("warp tick zone:"..zone, pos.x..","..pos.y, M.prevPos.x..","..M.prevPos.y)
    end

    -- print("M.warp_handler_tick", zone,  ac_pos.distance(pos, M.prevPos))
    if M.prevZone == zone and M.prevPos ~= nil then
	local dist = ac_pos.distance(pos, M.prevPos)
	-- print("dist:", dist)
	-- 東アドゥリンWP、レンタル<=>競売が 36.8
	if  dist > 32 then
	    M.warp_handler(zone, pos, M.prevZone, M.prevPos, dist)
	end
    end
    M.prevZone = zone
    M.prevPos = pos
end

-- 同じ zone でワープした時。WP や AMANトローブ
function M.warp_handler(zone, pos, prevZone, prevPos, dist)
    print("zone/change:warp " .. zone .. ":" .. posStr(pos) .. " << " .. prevZone .. ":" ..  posStr(prevPos) .. " dist:" ..  math.round(dist, 2))
    task.allClear()
    -- warp out の処理
    if prevZone == nil then
	print("ERROR: prevZone == nil")  -- 普通はありえない
    else
	local zone_out_object = aczone.zoneTable[prevZone]
	if zone_out_object ~= nil then
	    local warp_out = zone_out_object.warp_out
	    if warp_out ~= nil then
		print("warp_out:", prevZone)
		warp_out()
	    end
	end
    end
    -- warp in の処理
    local zone_object = aczone.zoneTable[zone]
    if zone_object == nil then
	return
    end
    local warp_in = zone_object.warp_in
    if warp_in ~= nil then
	warp_in()
    end
    local automatic_routes = zone_object.automatic_routes
    if automatic_routes ~= nil then
	M.automatic_routes_handler(zone, automatic_routes)
    end
end

return M
