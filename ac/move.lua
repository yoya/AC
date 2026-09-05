--- Move
--- 移動処理。向き変更もここ

local M = {}

local utils = require 'utils'
local array_reverse = utils.table.array_reverse

local control = require 'control'
local io_chat = require 'io/chat'
local command = require 'command'
local keyboard = require 'keyboard'
local push_keys = keyboard.push_keys

local contents = require 'contents'
local ac_pos = require 'ac/pos'
local distance = ac_pos.distance
local current_pos = ac_pos.current_pos

local io_net = require 'io/net'
local acmob = require 'mob'
local get_mob_position = acmob.get_mob_position
local acitem = require 'item'

local ac_party = require 'ac/party'
local pstatus = require 'player_status'
local pull = require 'pull'

--
-- 走行の意図
--
-- windower.ffxi.run は「止めるまで走り続ける」ので、走り出した後に return する
-- 経路が 1 つ増えるたびに、そこへ run(false) を書き足す事になっていた。書き
-- 忘れると、直前の向き (待機中に base_pos へ戻る向き等) へ走り続ける。
--
-- そこで「今 tick 走りたいか」を意図として持ち、tick の末尾で
-- apply_run() が「誰も走りたいと言わなかった tick なら止める」を引き受ける。
-- 走り出しは今まで通り即座に効くので、tick 内で向きを出し直すループ
-- (role/Follower.follow_leader 等) はそのまま動く。
--
-- run を直接呼んでよいのは、自分で最後まで面倒を見る自動移動 (_auto_move_to)
-- と、まだ移していない contents/ works だけ。role/ と battle/ はここを通す。
local run_wanted = nil   -- この tick に want_run / want_stop が呼ばれたか
local run_active = false -- ここが走らせている最中か

-- 走る。向きは毎 tick 出し直す前提 (相対座標なので tick をまたぐと古くなる)
M.want_run = function(dx, dy)
    run_wanted = true
    windower.ffxi.run(dx, dy)
    run_active = true
end

-- 止める
M.want_stop = function()
    run_wanted = false
    if run_active then
	windower.ffxi.run(false)
	run_active = false
    end
end

-- tick の末尾で 1 度だけ呼ぶ。tick_serial のどこで return しても通るよう、
-- AC.lua の tick() から呼ぶ事
M.apply_run = function()
    if M.auto then
	-- 自動移動が走行を持っている。触らない
	run_wanted = nil
	return
    end
    if run_wanted == nil and run_active then
	-- 誰も走りたいと言わなかった。止め忘れの経路はここで回収する
	windower.ffxi.run(false)
	run_active = false
    end
    run_wanted = nil
end

local turn_to_front = function(target)
    local push_numpad5 = 'setkey numpad5 down; wait 0.1; setkey numpad5 up'
    command.send(push_numpad5..'; wait 0.5; '..push_numpad5)
end
M.turn_to_front = turn_to_front

local turn_to_pos = function(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    --- atan2 のままだと右を向くので、90度の補正
    local dir = math.atan2(dx, dy) - 3.14/2
    windower.ffxi.turn(dir)
end
M.turn_to_pos = turn_to_pos

M.run_to_mob = function(mob)
    local me = windower.ffxi.get_mob_by_target("me")
    local dx = mob.x - me.x
    local dy = mob.y - me.y
    local dir = math.atan2(dx, dy) - 3.14/2
    windower.ffxi.turn(dir)
    windower.ffxi.run(dx, dy)
end

M.turn_to_target = function(target)
---    print("turn_to_target:"..target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
---        print("turn_to_target: target:"..#target.." not found")
        return false
    end
    local me = windower.ffxi.get_mob_by_target("me")
    turn_to_pos(me.x, me.y, mob.x, mob.y)
end

function nearest_idx(pos, posTable)
    local near_idx = nil
    local near_dis = 99999
    for i, p in ipairs(posTable) do
        if p.x ~= nil then
            local d = distance(pos, p)
            if d < near_dis then
                near_idx = i
                near_dis = d
            end
        end
    end
    return near_idx
end

-- 別ルートを経由して dest へ向かう時の中継点を選ぶ、つもりだった関数。
-- 書きかけのまま止まっており、呼び出し元もない。未実装であることを
-- 隠さないよう nil を返すだけにしてある。
function relay_idx(pos, dest, route_table)
    return nil
end

-- 指定した方向に向く
local turn_to = function(pos)
    local me = current_pos()
    if me == nil then
	return
    end
    local dx = pos.x - me.x
    local dy = pos.y - me.y
    --- atan2 のままだと右を向くので、90度の補正
    local dir = math.atan2(dx, dy) - 3.14/2
    windower.ffxi.turn(dir)
end
M.turn_to = turn_to

-- 視界を前を向ける
local look_forward = function()
    local push_numpad5 = 'setkey numpad5 down; wait 0.1; setkey numpad5 up'
    command.send(push_numpad5..'; wait 0.5; '..push_numpad5)
end
M.look_forward = look_forward

--
-- move_to
--

M.auto = false
-- 移動の世代。誰の M.stop() かを見分ける為に _auto_move_to が進める
M.auto_seq = 0

function stop()
---    print("M.auto = false")
    M.auto = false
end
M.stop = stop


function contain_pos(route, pos)
    for i, p in ipairs(route) do
	local d = 1
	if p.d ~= nil then
	    d = p.d + 1
	end
	if p.x ~= nil and distance(p, pos) < d then
	    return true
	end
    end
    return false
end

function move_to_action_faith(f)
    if not ac_party.iam_leader() then
	return -- リーダーじゃないとフェイスを呼べないので
    end
    local faith_list = f
    if type(f) == "string" then
	if f == "ambus" then
	    faith_list = { "ヴァレンラール", "モンブロー",
			  "テルセウス", "コルモル", "シルヴィ(UC)" }
	elseif f == "balance" then
	    faith_list = { "ヴァレンラール", "モンブロー",
			  "ヨアヒム", "コルモル", "シルヴィ(UC)" }
	elseif f == "cursna" then
	    faith_list = { "イングリッド", "モンブロー",
			   "ヨアヒム", "コルモル", "シルヴィ(UC)" }
	elseif f == "guard" then
	    faith_list = { "ブリジッド", "サクラ", "モーグリ", }
	elseif f == "raise" then
	    faith_list = { "モンブロー", "フェリアスコフィン",
			  "ブリジッド", "クピピ", "コルモル" }
	else
	    faith_list = { "ヨアヒム", "クピピ",
			  "ブリジッド", "モーグリ", "サクラ" }
	end
    end
    windower.ffxi.run(false)
    coroutine.sleep(1)
    local party_count = ac_party.count_member()
    if party_count == 0 then
	party_count = 1  -- ソロの時
    end
    for i = 1, (6 - party_count) do
	f = faith_list[i]
	if f == nil then
	    io_chat.errorf("faith_list[%d] f == nil", i)
	    break
	end
	command.send('input /ma '..f..' <me>')
	coroutine.sleep(7.0)
    end
    --[[
    for _, f in ipairs(faith_list) do
	command.send('input /ma '..f..' <me>')
	coroutine.sleep(7.0)
	end
    ]]
end

function M.action_touch(name)
    local found = false
    local count = 0
    -- ターゲットが見えるまで待つ
    while not found do
	count = count + 1
	local mob = windower.ffxi.get_mob_by_name(name)
	if mob == nil or mob.name ~= name then
	    io_chat.warnf("ac/move.action_touch not found:%s %d/10",
			  name, count)
	    coroutine.sleep(0.5)
	else
	    found = true
	end
	if count > 10 then
	    io_chat.errorf("ac/move.action_touch not found:%s) %d/10",
			   name, count)
	    return
	end
    end
    -- ターゲットを合わせる
    io_net.target_by_mob_name(name)
    coroutine.sleep(0.2)
    utils.target_lockon(true) -- ロックする
    push_keys({"enter"})  -- 無駄打ち
    coroutine.sleep(0.2)
    push_keys({"enter"})  -- 本打ち
    coroutine.sleep(0.5)
    utils.target_lockon(false) -- ロックを外す
    coroutine.sleep(0.5)
end

function move_to_action(p, reverse)
    if (not reverse and p.a == "dismount") or (reverse and p.a=="mount") then
	command.send('input /dismount')
	coroutine.sleep(3.0)
    end
    if p.enemy_filter ~= nil then
	io_chat.set_next_color(6)
	io_chat.print("enemy_filter:", p.enemy_filter)
	control.enemy_filter = p.enemy_filter
    end
    if p.a == "faith" then
	move_to_action_faith(p.faith_list)
    end
    if p.a == "insne" then
	print("insne")
	windower.ffxi.run(false)
	coroutine.sleep(1)
	command.send('input /ma スニーク <me>; wait 7.5; input /ma インビジ <me>')
	coroutine.sleep(16)
    end
    if p.a == "invisi" then
	print("invisi")
	windower.ffxi.run(false)
	coroutine.sleep(1)
	command.send('input /ma インビジ <me>')
	coroutine.sleep(7)
    end
    if p.a == "invisi_cancel" then
	print("invisi cancel")
	windower.ffxi.run(false)
	coroutine.sleep(1)
	windower.ffxi.cancel_buff(69) -- インビジキャンセル
    end
    if (not reverse and p.a == "mount") or (reverse and p.a=="dismount") then
	command.send('input /mount ラプトル')
	coroutine.sleep(2.0)
    end
    if p.a == "sneak" then
	print("sneak")
	windower.ffxi.run(false)
	coroutine.sleep(1)
	command.send('input /ma スニーク <me>')
	coroutine.sleep(7)
    end
    if p.auto ~= nil then
	control.auto = p.auto
	if p.auto then
	    pull.base_pos = {x=0, y=0, z=0}
	    get_mob_position(pull.base_pos, "me")  -- 帰還地点を更新
	end
    end
    if p.enemy_range ~= nil then
	io_chat.info("enemy_range:"..p.enemy_range)
	control.enemy_range = p.enemy_range
    end
    if p.faith ~= nil then
	move_to_action_faith(p.faith)
    end
    if p.keys ~= nil then
	push_keys(p.keys)
    end
    if p.opendoor ~= nil then
	io_chat.warn("deplicated ac/move.opendoor, instead of use touch")
	M.action_touch(p.opendoor)
    end
    if p.puller ~= nil then
	control.puller = p.puller
	print("puller:", p.puller)
    end
    if p.show ~= nil then
	if p.show == "bag_empty_epace" then
	    local n = acitem.inventory_freespace_num()
	    io_chat.info("かばんの空きは"..n.."*99 = "..(n*99))
	end
    end
    if p.target ~= nil then
	print("target:"..p.target)
	while M.auto do
	    io_net.target_by_mob_name(p.target)
	    coroutine.sleep(0.3)
	    local mob = windower.ffxi.get_mob_by_target("t")
	    if mob == nil or mob.name ~= p.target then
		-- print("tab")
		push_keys({"tab"})
		coroutine.sleep(0.25)
	    elseif mob.distance <= 35.56 then
		utils.target_lockon(true)
		coroutine.sleep(1)
		break
	    end
	end
    end
    if p.target_lockon ~= nil then
	utils.target_lockon(p.target_lockon)
    end
    if p.touch ~= nil then
	M.action_touch(p.touch)
    end
    if p.w ~= nil then
	p.wait = p.w
	p.w = nil
    end
    if p.wait ~= nil then
	print("wait:"..p.wait)
	coroutine.sleep(p.wait)
    end
    return true
end

function move_to(route, route_table, next_route, reverse)
    local pos = current_pos()
    local r1_list = {}  -- 各routeの一個目をリスト化
    local r1_list_name = {}
    if route_table == nil then
	io_chat.warn("route_table == nil (zone にルート定義が無い)")
	return
    end
    -- io_chat.print(route)
    for i, p in ipairs(route) do
	if p.route == nil and p.r ~= nil then
	    p.route = p.r
	end
        if p.route ~= nil then
            print("p.r="..(p.route))
	    -- move_to(p.r, route_table)
	    --[[
            local r = route_table[p.r]
            table[p.r] = r[1]
            table.insert(r1_list, r[1])
            table.insert(r1_list_name, p.r)
	    ]]
        end
    end
    if #r1_list > 0 then
        local idx = nearest_idx(pos, r1_list)
        local name = r1_list_name[idx]
        local r = route_table[name]
	if r == nil then
	    io_chat.set_next_color(3)
	    io_chat.printf("route name:%s is not found", name)
	    return
	end
        print(idx, name, r)
        move_to(r, route_table)
    end
    print("moveFrom", math.round(pos.x, 2), math.round(pos.y, 2))
    local start_idx = nearest_idx(pos, route)
--    print('start_idx', start_idx)
    if distance(pos, route[start_idx]) > 64 then
        io_chat.error("not starting position")
        -- M.stop()
        return false
    end
    local prev_pos= nil
    for i, p in ipairs(route) do
	if not M.auto then
	    break
	end
	if i <= 1 and p.x ~= nil then
	     do end  -- ひとつ目が座標の場合に skip
	elseif i < start_idx then
            print("skip route["..i.."] pos:("..tostring(p.x)..", "..tostring(p.y)..")")
        else
	    if p.route ~= nil then
		local r = route_table[p.route]
		move_to(r, route_table, nil, reverse)
	    end
	    if utils.table.count_keys(p) == 0 then
                -- {} の時はオートラン
		windower.ffxi.run(true)
            end
	    if p.stop ~= nil then
		if p.stop == "raives" then
		    windower.ffxi.run(false)
		    if contents.raives.arise() then
			-- M.stop()
			return false -- レイヴ発生中なら移動終了
		    end
		end
	    end
	    if not move_to_action(p, reverse) then
		return false
	    end
            if p.x ~= nil then
		local x = p.x
		local y = p.y
		local d = p.d or 0
		while M.auto do  -- TODO: auto を見る
		    local player = windower.ffxi.get_player()
		    if player.status == pstatus.EVENT then
			coroutine.sleep(1)  -- イベント中は一休み
		    else
			break  -- 移動の続きに戻る
		    end
		end
		if control.debug then
		    io_chat.print("moving to", i, x, y, d)
		end
		x = x + math.random(-d*100,d*100)/100
		y = y + math.random(-d*100,d*100)/100
		local dpos = {x=x,y=y,z=p.z}
		local curr_pos = current_pos()
		pull.base_pos = curr_pos  -- 帰還地点を更新
		if prev_pos ~= nil then
		    local far = distance(prev_pos, curr_pos)
		    if far > 128 then
			io_chat.warn("too far next move point")
			io_chat.printf("prev_pos(%d,%d) curr_pos(%d,%d) distance(%d) > 128",
				       prev_pos.x, prev_pos.y,
				       curr_pos.x, curr_pos.y, far)
			local zone_id = windower.ffxi.get_info().zone
			io_chat.printf("add midpoint (x=%d,y=%d) zone(%d) file",
				       (prev_pos.x + curr_pos.x)/2,
				       (prev_pos.y + curr_pos.y)/2, zone_id)
			-- M.stop()
			return false
		    end
		    local vec1 = {x=curr_pos.x-prev_pos.x,y=curr_pos.y-prev_pos.y}
		    local vec2 = {x=dpos.x-curr_pos.x,y=dpos.y-curr_pos.y}
		    local similality = utils.vector.CosineSimilarity(vec1, vec2)
		    if similality < 0.5 then
			windower.ffxi.run(false)
			local t = (0.5 - similality) / 3
			-- print("similality:"..similality.." => coroutine.sleep "..t)
			coroutine.sleep(t)
		    end
		end
		prev_pos = {x=curr_pos.x, y=curr_pos.y}
                -- 地形に引っかかって 0.5 まで近づけないと永久に回るので時間で打ち切る
                local move_deadline = os.time() + 60
                while (distance(current_pos(), dpos) > 0.5 and M.auto) do
                    if os.time() > move_deadline then
                        io_chat.warnf("move: (%.1f,%.1f) に近づけないので打ち切る",
                                      dpos.x, dpos.y)
                        windower.ffxi.run(false)
                        return false
                    end
                    turn_to(dpos)
                    pos = current_pos()
		    if pos ~= nil and pos.x ~= nil then
			windower.ffxi.run(dpos.x - pos.x, dpos.y - pos.y)
			coroutine.sleep(0.1)
		    else
			print("pos == nil or pos.x == nil pos:", pos)
			coroutine.sleep(1.0)
		    end
                end
		windower.ffxi.run(false)
		if next_route ~= nil and contain_pos(next_route, p) then
		    return  -- 次のルートに重なるのでこのルートは終了
		end
            end
            if p.t ~= nil then
                command.send('input /target '..p.t)
                coroutine.sleep(0.5)
            end
	    if p.a == "f8" then
                push_keys({"f8"})
                coroutine.sleep(1.0)
	    end
            if p.a == "f8touch" or p.a == "opendoor" then
                push_keys({"escape", "f8", "enter"})
                coroutine.sleep(1.0)
            end
            if p.a == "esc" then
                push_keys({"escape"})
                coroutine.sleep(0.5)
            end
            if p.a == "tab" then
                push_keys({"tab"})
                coroutine.sleep(0.5)
            end
            if p.a == "touch" then
                push_keys({"enter"})
                coroutine.sleep(1.0)
            end
            if p.a == "rmstatus" then
                push_keys({"escape", "numpad+", "numpad+", "enter"})
                coroutine.sleep(2.0)
            end
            if p.a == "enter" then
		print("ac/move pushkey enter")
                push_keys({"enter"})
                coroutine.sleep(1.0)
            end
            if p.a == "wait" then
		print("ac/move wait 1.0")
                coroutine.sleep(1.0)
            end
            if p.a == "up" then
		print("ac/move pushkey up")
                push_keys({"up"})
                coroutine.sleep(1.0)
            end
            if p.a == "down" then
		print("ac/move: pushkey down")
                push_keys({"down"})
                coroutine.sleep(1.0)
            end
        end
    end
    return true
end

function auto_move_to(zone_id, destTable, route_table)
    if destTable[1] == nil then
        if route_table == nil then
	    io_chat.set_next_color(3) -- 赤
            print("not defined zone route", zone_id)
        else
	    io_chat.set_next_color(5) -- 水色
	    io_chat.printf("### route table: (num:%d) zone:%d",
			   utils.table.count_keys(route_table), zone_id)
	    local NGlist = {}
            for dest, route in pairs(route_table) do
		local pos = current_pos()
		local idx = nearest_idx(pos, route)
		local desc = ""
		if route[1] ~= nil and route[1].desc then
		    desc = route[1].desc
		end
		local d = distance(pos, route[idx])
		if d < 64 then
		    io_chat.set_next_color(6) -- 緑
		    io_chat.printf("O %s(%d=>%d) %s", dest, d, idx, desc)
		else
		    local NGstr = string.format("%s(%d)", dest, d)
		    table.insert(NGlist, NGstr)
		end
            end
	    io_chat.set_next_color(3) -- 赤
	    io_chat.print("X "..table.concat(NGlist, '  '))
        end
    else
	for i, dest in ipairs(destTable) do
	    io_chat.set_next_color(6) -- 緑
	    io_chat.print("["..i.."] dest: "..dest)
	    local reverse
	    if dest:sub(1,1) == '-' then
		dest = dest:sub(2)
		reverse = true
	    else
		reverse = false
	    end
	    local next_dest = destTable[i+1]
	    _auto_move_to(zone_id, dest, route_table, reverse, next_dest)
	end
    end
    -- M.stop()
end
M.auto_move_to = auto_move_to

function _auto_move_to(zone_id, dest, route_table, reverse, next_dest)
    local route = route_table[dest]
    local next_route = route_table[next_dest]
    if route == nil then
	io_chat.set_next_color(3) -- 赤
	io_chat.printf("route dest:%s is not found", dest)
	return
    end
    if reverse == true then
	route = array_reverse(route)
    end
    if M.auto == true then
	print("_auto_move_to: singleton guard", dest)
	return
    end
    M.auto = true
    -- 中断 (M.auto = false) された後に次の移動が始まっていると、こちらの
    -- M.stop() がその移動を巻き添えで止めてしまうので、自分の番か確かめる
    M.auto_seq = M.auto_seq + 1
    local seq = M.auto_seq
    move_to(route, route_table, next_route, reverse)
    if seq == M.auto_seq then
	M.stop() -- M.auto = false
    end
end


return M
