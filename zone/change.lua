local aczone = require 'zone'
local ac_pos = require 'ac/pos'
local ac_move = require 'ac/move'
local ac_stat = require 'ac/stat'
local io_chat = require 'io/chat'
local command = require 'command'
local ac_party = require 'ac/party'
local iam_leader = ac_party.iam_leader
local task = require 'task'
local control = require 'control'
local contents = require 'contents'
local incoming_text = require 'incoming/text'
local pstatus = require 'player_status'

local M = {}

M.incoming_text_listener_id = nil

-- zone_in を実行したゾーン。zone_out はこれを基準に呼ぶ。
-- windower の prev_zone はログイン直後に zone と同じ値になり、AC.lua で nil に
-- 落としているので、それを使うと zone_in だけ走って zone_out が抜ける。
M.current_zone = nil

function pos_str(pos)
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

function M.search_and_invoke_automatic_routes(zone, prev_zone, automatic_routes,
					      contents_match)
    -- if prev_zone == nil then print(debug.traceback()) end
    print("zone/change.search_and_invoke_automatic_routes")
    if type(automatic_routes) ~= "table" then
	return false
    end
    -- コンテンツに応じて有効な宛先を切り替える
    local new_routes = {}
    -- io_chat.notice("automatic_routes", automatic_routes)
    for f, rr in pairs(automatic_routes) do
	local routes = (rr[1] == nil) and { rr } or rr
	for _, route in ipairs(routes) do
	    if route ~= nil then
		if route.zone_from ~= nil and prev_zone ~= nil and
		    ((route.zone_from > 0 and route.zone_from ~= prev_zone) or
		     (route.zone_from < 0 and -route.zone_from == prev_zone)) then
		    -- route を skip
		    -- io_chat.error("route を skip", route.zone_from, prev_zone)
		elseif contents_match then
		    if route.contents ~= nil and
			contents.match_contents_name(route.contents) then
			new_routes[f] = route
		    end
		else
		    -- コンテンツ制限ありの方を優先
		    if new_routes[f] == nil and route.contents == nil then
			new_routes[f] = route
		    end
		end
	    end
	end
    end
    automatic_routes = new_routes
    -- io_chat.notice("new_routes", new_routes)
    local zone_object = aczone.zone_table[zone]
    for f, t in pairs(automatic_routes) do
	local fp = zone_object.essential_points[f]
	if fp == nil then
	    io_chat.errorf("essential_points not found: %s", f)
	    return false
	end
	if fp.x == nil then
	    io_chat.errorf("essential_points illegal format: %s", f)
	    return false
	end
	local route = t.route
	local near_dist = nil
	local near_dist_x = nil
	local near_dist_y = nil
	if fp.d == nil and fp.dx == nil and fp.dy == nil then
	    near_dist = 2
	end
	if fp.d ~= nil then near_dist = fp.d end
	if fp.dx ~= nil then near_dist_x = fp.dx end
	if fp.dy ~= nil then near_dist_y = fp.dy end
	local exec_auto_route = ac_pos.is_near(fp, near_dist,
					      near_dist_x, near_dist_y)
	if t.leader_only == true and not iam_leader() then
	    io_chat.infof("移動するのはリーダーだけ: %s => %s", f, route)
	    exec_auto_route = false
	end
	local player = windower.ffxi.get_player()
	local level = player.main_job_level
	if t.need_level ~= nil then
	    if level < t.need_level then
		io_chat.infof("移動するのに level 20 必要: %s => %s", f, route)
		exec_auto_route = false
	    end
	else
	    -- print("level, t.need_level",level, t.need_level)
	end
	if control.debug then
	    io_chat.print(f, "fp:", fp, "near_dist:", near_dist, "nexrDistX,Y:", near_dist_x, near_dist_y)
	end
	if exec_auto_route then
	    io_chat.printf("移動 %s => %s", f, route)
	    aczone.AC.start_pos = nil
	    auto_move_to(zone, {route}, zone_object.routes)
	    return true
	end
    end
    return false
end

function M.automatic_routes_handler(zone, prev_zone, automatic_routes)
    print("zone/change.automatic_routes_handler", zone)
    if not control.automove then
	print("control.automove is false")
	return
    end
    local pos = ac_pos.current_pos()
    if prev_zone == nil and aczone.in_moghouse(zone, pos) then
	io_chat.print("ログインしてすぐのモグハウスは自動移動オフ")
	return
    end
    local zone_object = aczone.zone_table[zone]
    if zone_object == nil then
	return
    end
    local player = windower.ffxi.get_player()
    if player == nil or player.status == pstatus.DEAD then
	print("player and player.status", player and player.status)
	coroutine.sleep(3)
	player = windower.ffxi.get_player()
	if player == nil or player.status == pstatus.DEAD then
	    io_chat.print("移動しない status: ", player and player.status)
	    return
	end
    end
    coroutine.sleep(3)
    pos = ac_pos.current_pos()
    coroutine.sleep(5)
    if ac_pos.is_near(pos, 0.5) then
	local ret = M.search_and_invoke_automatic_routes(zone, prev_zone,
							 automatic_routes,
							 true)
	if not ret then
	    M.search_and_invoke_automatic_routes(zone, prev_zone,
						 automatic_routes,
						 false)
	end
    end
end

function M.automatic_trust_handler(zone, prev_zone, automatic_trust)
    io_chat.print("automatic_trust")
    local zone_object = aczone.zone_table[zone]
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

function M.zone_out_handler(zone)
    -- zone out の処理
    if zone == nil then
	return
    end
    local zone_out_object = aczone.zone_table[zone]
    if zone_out_object ~= nil then
	local zone_out = zone_out_object.zone_out
	if zone_out ~= nil then
	    print("zone_out:", zone)
	    zone_out()
	end
    end
    if M.incoming_text_listener_id ~= nil then
	incoming_text.remove_listener(M.incoming_text_listener_id)
	M.incoming_text_listener_id = nil
    end
    contents.zone_out()
end

function M.zone_in_handler(zone, prev_zone)
    -- zone in の処理
    M.current_zone = zone
    local zone_object = aczone.zone_table[zone]
    if zone_object ~= nil then
	local zone_in = zone_object.zone_in
	local incoming_text_listener = zone_object.incoming_text_listener
	if zone_in ~= nil then
	    print("zone_in:", zone)
	    zone_in()
	end
	if incoming_text_listener ~= nil then
	    M.incoming_text_listener_id = incoming_text.add_listener("", incoming_text_listener)
	end
	local automatic_routes = zone_object.automatic_routes
	if automatic_routes ~= nil then
	    M.automatic_routes_handler(zone, prev_zone, automatic_routes)
	end
	if iam_leader() then
	    local automatic_trust = zone_object.automatic_trust
	    if automatic_trust ~= nil then
		io_chat.set_next_color(6)
		io_chat.print("automatic_trust", automatic_trust);
		M.automatic_trust_handler(zone, prev_zone, automatic_trust)
	    end
	end
    end
end

function M.zone_change_handler(zone, prev_zone)
    -- zone 毎の処理
    print("zone/change zone_change_handler: "..zone.." <= "..tostring(prev_zone))
    ac_stat.init()
    task.all_clear()
    aczone.AC.start_pos = nil
    -- zone out の処理。zone_in を実行したゾーンとペアで呼ぶ
    local out_zone = M.current_zone
    if prev_zone == nil and out_zone ~= zone then
	-- ログイン直後。前のキャラの zone_out は走らせない
	out_zone = nil
	M.current_zone = nil
    end
    M.zone_out_handler(out_zone)
    -- zone in の処理
    M.current_zone = zone
    local zone_object = aczone.zone_table[zone]
    if zone_object ~= nil then
	M.zone_in_handler(zone, prev_zone)
	local change_handler = zone_object.zone_change_handler
	if change_handler ~= nil then
	    print("zone_change_handler found")
	    change_handler(zone, prev_zone)
	end
    end
end

function M.warp_handler_tick()
    -- print("M.warp_handler_tick()")
    local zone = windower.ffxi.get_info().zone
    local pos = ac_pos.current_pos()
    if zone == nil or pos == nil then
	return
    end
    -- print("M.warp_handler_tick", zone,  ac_pos.distance(pos, M.prev_pos))
    if M.prev_zone == zone and M.prev_pos ~= nil then
	local dist = ac_pos.distance(pos, M.prev_pos)
	-- print("dist:", dist)
	-- 東アドゥリンWP、レンタル<=>競売が 36.8
	if  dist > 32 then
	    M.warp_handler(zone, pos, M.prev_zone, M.prev_pos, dist)
	end
    end
    M.prev_zone = zone
    M.prev_pos = pos
end

-- 同じ zone でワープした時。WP や AMANトローブ
function M.warp_handler(zone, pos, prev_zone, prev_pos, dist)
    print("zone/change:warp " .. zone .. ":" .. pos_str(pos) .. " << " .. prev_zone .. ":" ..  pos_str(prev_pos) .. " dist:" ..  math.round(dist, 2))
    task.all_clear()
    -- warp out の処理
    if prev_zone == nil then
	print("ERROR: prev_zone == nil")  -- 普通はありえない
    else
	local zone_out_object = aczone.zone_table[prev_zone]
	if zone_out_object ~= nil then
	    local warp_out = zone_out_object.warp_out
	    if warp_out ~= nil then
		print("warp_out:", prev_zone)
		warp_out()
	    end
	end
    end
    -- warp in の処理
    local zone_object = aczone.zone_table[zone]
    if zone_object == nil then
	return
    end
    local warp_in = zone_object.warp_in
    if warp_in ~= nil then
	warp_in()
    end
    local automatic_routes = zone_object.automatic_routes
    if automatic_routes ~= nil then
	M.automatic_routes_handler(zone, prev_zone, automatic_routes)
    end
end

return M
