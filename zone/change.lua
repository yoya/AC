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

-- zone_in を実行したゾーン。zone_out はこれを基準に呼び、zone_in とペアにする。
-- windower の prev_zone はログイン直後に zone と同じ値になるので、これが
-- ログインか同じゾーン内の遷移かの判断にも使う (zone_change_handler)
M.current_zone = nil

-- 自動移動の起動世代。ゾーン移動やワープの度に進める
M.auto_move_seq = 0

-- 同一ゾーン内のワープ検出用。warp_handler_tick が毎 tick 更新する
M.prev_zone = nil
M.prev_pos = nil

local function pos_str(pos)
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

-- automatic_routes のエントリは route 単体か、その配列。配列に揃える
local function route_list(entry)
    if entry.route ~= nil then
	return { entry }
    end
    return entry
end

-- essential_points の判定距離。d / dx / dy がひとつも無ければ 2
local function near_args(fp)
    if fp.d == nil and fp.dx == nil and fp.dy == nil then
	return 2, nil, nil
    end
    return fp.d, fp.dx, fp.dy
end

-- zone_from: 正ならその zone から来た時だけ有効、負ならその zone から来た時は無効
local function skip_by_zone_from(t, prev_zone)
    if t.zone_from == nil or prev_zone == nil then
	return false
    end
    if t.zone_from > 0 then
	return t.zone_from ~= prev_zone
    end
    return -t.zone_from == prev_zone
end

local function can_exec(f, t)
    if t.leader_only == true and not iam_leader() then
	io_chat.infof("移動するのはリーダーだけ: %s => %s", f, t.route)
	return false
    end
    if t.need_level ~= nil then
	local player = windower.ffxi.get_player()
	local level = player and player.main_job_level
	if level == nil or level < t.need_level then
	    io_chat.infof("移動するのに level %d 必要: %s => %s",
			  t.need_level, f, t.route)
	    return false
	end
    end
    return true
end

-- ひとつの essential_point の route 群から実行するものを1つ選ぶ。
-- contents 一致を contents 指定なしより優先する。
-- contents 一致があるならそれだけを見る。leader_only や need_level で
-- 実行できない時に contents 指定なしの既定ルートへ落とさない為
local function pick_route(f, entry, prev_zone)
    local matched = nil    -- contents 一致
    local fallback = nil   -- contents 指定なし
    for _, t in ipairs(route_list(entry)) do
	if t ~= nil and not skip_by_zone_from(t, prev_zone) then
	    if t.contents ~= nil then
		if matched == nil and contents.match_contents_name(t.contents) then
		    matched = t
		end
	    elseif fallback == nil then
		fallback = t
	    end
	end
    end
    local t = matched or fallback
    if t == nil or not can_exec(f, t) then
	return nil
    end
    return t
end

-- 現在地から実行できる automatic_route を選ぶ。無ければ nil。
-- 近い essential_point が複数ある時は距離が一番近いものを選ぶ
-- (pairs の順は不定なので、選ばないと実行ごとに変わりうる)
function M.select_automatic_route(zone, prev_zone, automatic_routes)
    print("zone/change.select_automatic_route")
    if type(automatic_routes) ~= "table" then
	return nil
    end
    local zone_object = aczone.zone_table[zone]
    if zone_object == nil then
	return nil
    end
    local me = ac_pos.current_pos()
    local best = nil
    for f, entry in pairs(automatic_routes) do
	local fp = zone_object.essential_points[f]
	-- データ不備は、そこだけ飛ばす。他の essential_point の判定は続ける
	if fp == nil then
	    io_chat.errorf("essential_points not found: %s", f)
	elseif fp.x == nil then
	    io_chat.errorf("essential_points illegal format: %s", f)
	else
	    local d, dx, dy = near_args(fp)
	    if control.debug then
		io_chat.print(f, "fp:", fp, "near_dist:", d,
			      "near_dist_x,y:", dx, dy)
	    end
	    if ac_pos.is_near(fp, d, dx, dy) then
		local t = pick_route(f, entry, prev_zone)
		if t ~= nil then
		    local dist = ac_pos.distance(me, fp)
		    if best == nil or dist < best.dist then
			best = { point = f, route = t.route, dist = dist }
		    end
		end
	    end
	end
    end
    return best
end

function M.invoke_automatic_route(zone, sel)
    local zone_object = aczone.zone_table[zone]
    io_chat.printf("移動 %s => %s", sel.point, sel.route)
    aczone.AC.start_pos = nil
    ac_move.auto_move_to(zone, {sel.route}, zone_object.routes)
end

function M.automatic_routes_handler(zone, prev_zone, is_login, automatic_routes)
    print("zone/change.automatic_routes_handler", zone)
    -- 起動の世代を進める。判定の前に何秒も待つので、待っている間に次の
    -- ゾーン移動やワープが来たら、古い起動は捨てる。
    -- 同じモグハウス出入りが zone change と warp の両方から来る事もある
    M.auto_move_seq = M.auto_move_seq + 1
    local seq = M.auto_move_seq
    local function is_current()
	if seq ~= M.auto_move_seq then
	    print("zone/change: 新しい自動移動が来たのでこの起動は捨てる")
	    return false
	end
	return true
    end
    if not control.automove then
	print("control.automove is false")
	return
    end
    local pos = ac_pos.current_pos()
    if is_login and aczone.in_moghouse(zone, pos) then
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
	if not is_current() then return end
	player = windower.ffxi.get_player()
	if player == nil or player.status == pstatus.DEAD then
	    io_chat.print("移動しない status: ", player and player.status)
	    return
	end
    end
    -- ゾーンイン直後は座標が安定しないので、少し待ってから基準位置を取る
    coroutine.sleep(3)
    if not is_current() then return end
    pos = ac_pos.current_pos()
    -- さらに待って、その間に動いていない事を確かめる
    coroutine.sleep(5)
    if not is_current() then return end
    if not ac_pos.is_near(pos, 0.5) then
	print("zone/change: 動いているので自動移動しない")
	return
    end
    if ac_move.auto then
	print("zone/change: 移動中なので自動移動を起動しない")
	return
    end
    local sel = M.select_automatic_route(zone, prev_zone, automatic_routes)
    if sel ~= nil then
	M.invoke_automatic_route(zone, sel)
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

function M.zone_in_handler(zone, prev_zone, is_login)
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
	    M.automatic_routes_handler(zone, prev_zone, is_login,
				       automatic_routes)
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
    -- windower はログイン直後に prev_zone == zone を返す。同じゾーン内の
    -- 遷移 (モグハウス) でも同じ値になるので、zone_in 済みかどうかで区別する
    local is_login = (prev_zone == nil or prev_zone == zone)
	and M.current_zone ~= zone
    if is_login then
	prev_zone = nil  -- 前のゾーンは無い
    end
    -- zone out の処理。zone_in を実行したゾーンとペアで呼ぶ。
    -- ログイン直後は前のキャラのゾーンなので走らせない
    if not is_login then
	M.zone_out_handler(M.current_zone)
    end
    -- zone in の処理
    M.current_zone = zone
    local zone_object = aczone.zone_table[zone]
    if zone_object ~= nil then
	M.zone_in_handler(zone, prev_zone, is_login)
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
	    M.warp_handler(zone, pos, M.prev_pos, dist)
	end
    end
    M.prev_zone = zone
    M.prev_pos = pos
end

-- 同じ zone でワープした時。WP や AMANトローブ。
-- warp_handler_tick が M.prev_zone == zone の時だけ呼ぶので、
-- warp_out と warp_in は必ず同じゾーンのものになる
function M.warp_handler(zone, pos, prev_pos, dist)
    print("zone/change:warp " .. zone .. ":" .. pos_str(pos) .. " << " ..
	  pos_str(prev_pos) .. " dist:" ..  math.round(dist, 2))
    task.all_clear()
    local zone_object = aczone.zone_table[zone]
    if zone_object == nil then
	return
    end
    if zone_object.warp_out ~= nil then
	print("warp_out:", zone)
	zone_object.warp_out()
    end
    if zone_object.warp_in ~= nil then
	zone_object.warp_in()
    end
    local automatic_routes = zone_object.automatic_routes
    if automatic_routes ~= nil then
	M.automatic_routes_handler(zone, zone, false, automatic_routes)
    end
end

return M
