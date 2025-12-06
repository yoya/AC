--- Move
--- 移動処理。向き変更もここ

local M = {}

local utils = require 'utils'
local array_reverse = utils.table.array_reverse

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local command = require 'command'
local io_chat = require 'io/chat'
local contents = require 'contents'
local ac_pos = require 'ac/pos'
local distance = ac_pos.distance

local turnToFront = function(target)
    local push_numpad5 = 'setkey numpad5 down; wait 0.1; setkey numpad5 up'
    command.send(push_numpad5..'; wait 0.5; '..push_numpad5)
end
M.turnToFront = turnToFront

local turnToPos = function(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    --- atan2 のままだと右を向くので、90度の補正
    local dir = math.atan2(dx, dy) - 3.14/2
    windower.ffxi.turn(dir)
end
M.turnToPos = turnToPos

M.turnToTarget = function(target)
---    print("turnToTarget:"..target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
---        print("turnToTarget: target:"..#target.." not found")
        return false
    end
    local me = windower.ffxi.get_mob_by_target("me")
    turnToPos(me.x, me.y, mob.x, mob.y)
end

function nearest_idx(pos, posTable)
    local near_idx = nil
    local near_dis = 99999
    for i, p in ipairs(posTable) do
        if p.x ~= nil then
            d = distance(pos, p)
            if d < near_dis then
                near_idx = i
                near_dis = d
            end
        end
    end
    return near_idx
end

-- 指定した方向に向く
local turnTo = function(pos)
    local me = currentPos()
    if me == nil then
	return
    end
    local dx = pos.x - me.x
    local dy = pos.y - me.y
    --- atan2 のままだと右を向くので、90度の補正
    local dir = math.atan2(dx, dy) - 3.14/2
    windower.ffxi.turn(dir)
end
M.turnTo = turnTo

-- 視界を前を向ける
local lookForward = function()
    local push_numpad5 = 'setkey numpad5 down; wait 0.1; setkey numpad5 up'
    command.send(push_numpad5..'; wait 0.5; '..push_numpad5)
end
M.lookForward = lookForward

--
-- moveTo
--

M.auto = false

function stop()
---    print("M.auto = false")
    M.auto = false
end
M.stop = stop


function containPos(route, pos)
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

function moveToAction(p)
    if p.w ~= nil then
	p.wait = p.w
	p.w = nil
    end
    if p.wait ~= nil then
	print("wait:"..p.wait)
	coroutine.sleep(p.wait)
    end
    if p.a == "mount" then
	command.send('input /mount ラプトル')
	coroutine.sleep(2.0)
    end
    if p.a == "dismount" then
	command.send('input /dismount')
	coroutine.sleep(3.0)
    end
    if p.a == "insne" then
	print("insne")
	windower.ffxi.run(false)
	coroutine.sleep(1)
	command.send('input /ma スニーク <me>; wait 7.5; input /ma インビジ <me>')
	coroutine.sleep(16)
    end
    if p.a == "sneak" then
	print("sneak")
	windower.ffxi.run(false)
	coroutine.sleep(1)
	command.send('input /ma スニーク <me>')
	coroutine.sleep(7)
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
    return true
end

function moveTo(route, routeTable, nextRoute)
    local pos = currentPos()
    local r1List = {}  -- 各routeの一個目をリスト化
    local r1ListName = {}
    if routeTable == nil then
	print("routeTable == nil")
	return
    end
    -- io_chat.print(route)
    for i, p in ipairs(route) do
	if p.route == nil and p.r ~= nil then
	    p.route = p.r
	end
        if p.route ~= nil then
            print("p.r="..(p.route))
	    -- moveTo(p.r, routeTable)
	    --[[
            local r = routeTable[p.r]
            table[p.r] = r[1]
            table.insert(r1List, r[1])
            table.insert(r1ListName, p.r)
	    ]]
        end
    end
    if #r1List > 0 then
        local idx = nearest_idx(pos, r1List)
        local name = r1ListName[idx]
        local r = routeTable[name]
	if r == nil then
	    io_chat.setNextColor(3)
	    io_chat.printf("route name:%s is not found", name)
	    return
	end
        print(idx, name, r)
        moveTo(r, routeTable)
    end
    M.auto = true
    print("moveFrom", math.round(pos.x, 2), math.round(pos.y, 2))
    local start_idx = nearest_idx(pos, route)
--    print('start_idx', start_idx)
    if distance(pos, route[start_idx]) > 64 then
        print("not starting position")
        stop()
        return false
    end
    local prevPos= nil
    for i, p in ipairs(route) do
	if not M.auto then
	    break
	end
	if i <= 1 and p.x ~= nil then
	     do end  -- ひとつ目が座標の場合に skip
	elseif i < start_idx then
            print("skip route idx:", i)
        else
	    if p.route ~= nil then
		local r = routeTable[p.route]
		moveTo(r, routeTable)
	    end
	    if utils.table.count_keys(p) == 0 then
                -- {} の時はオートラン
		windower.ffxi.run(true)
            end
	    if p.stop ~= nil then
		if p.stop == "raives" then
		    windower.ffxi.run(false)
		    if contents.raives.arise() then
			stop()
			return false -- レイヴ発生中なら移動終了
		    end
		end
	    end
	    if not moveToAction(p) then
		return false
	    end
            if p.x ~= nil then
		local x = p.x
		local y = p.y
		local d = p.d or 0
		while M.auto do  -- TODO: auto を見る
		    local player = windower.ffxi.get_player()
		    if player.status == 4 then
			coroutine.sleep(1)  -- イベント中は一休み
		    else
			break  -- 移動の続きに戻る
		    end
		end
                print("moving to", i, x, y, d)
		x = x + math.random(-d*100,d*100)/100
		y = y + math.random(-d*100,d*100)/100
		local dpos = {x=x,y=y,z=p.z}
		local currPos = currentPos()
		if prevPos ~= nil then
		    if distance(prevPos, currPos) > 128 then
			print("too far next move point")
			return
		    end
		    local vec1 = {x=currPos.x-prevPos.x,y=currPos.y-prevPos.y}
		    local vec2 = {x=dpos.x-currPos.x,y=dpos.y-currPos.y}
		    local similality = utils.vector.CosineSimilarity(vec1, vec2)
		    if similality < 0.5 then
			windower.ffxi.run(false)
			local t = (0.5 - similality) / 3
			-- print("similality:"..similality.." => sleep "..t)
			coroutine.sleep(t)
		    end
		end
		prevPos = {x=currPos.x, y=currPos.y}
                while (distance(currentPos(), dpos) > 0.5 and moveToRunning == true) do
                    if distance(currentPos(), dpos) > 6468 and false then
                        print("not near position")
                        stop()
                        return
                    end
                    turnTo(dpos)
                    pos = currentPos()
                    windower.ffxi.run(dpos.x - pos.x, dpos.y - pos.y)
                    coroutine.sleep(0.1)
                end
		windower.ffxi.run(false)
		if nextRoute ~= nil and containPos(nextRoute, p) then
		    return  -- 次のルートに重なるのでこのルートは終了
		end
            end
            if p.t ~= nil then
                command.send('input /target '..p.t)
                coroutine.sleep(0.5)
            end
            if p.a == "f8touch" or p.a == "opendoor" then
                pushKeys({"escape", "f8", "enter"})
                coroutine.sleep(1.0)
                touch = true
            end
            if p.a == "esc" then
                pushKeys({"escape"})
                coroutine.sleep(1.0)
            end
            if p.a == "tab" then
                pushKeys({"tab"})
                coroutine.sleep(1.0)
            end
            if p.a == "touch" then
                pushKeys({"enter"})
                coroutine.sleep(1.0)
            end
            if p.a == "rmstatus" then
                pushKeys({"escape", "numpad+", "numpad+", "enter"})
                coroutine.sleep(2.0)
            end
            if p.a == "enter" then
		print("ac/move pushkey enter")
                pushKeys({"enter"})
                coroutine.sleep(1.0)
            end
            if p.a == "wait" then
		print("ac/move wait 1.0")
                coroutine.sleep(1.0)
            end
            if p.a == "up" then
		print("ac/move pushkey up")
                pushKeys({"up"})
                coroutine.sleep(1.0)
            end
            if p.a == "down" then
		print("ac/move: pushkey down")
                pushKeys({"down"})
                coroutine.sleep(1.0)
            end
        end
    end
    return true
end
M.moveTo = moveTo

function autoMoveTo(zone_id, destTable, routeTable)
    if destTable[1] == nil then
        if routeTable == nil then
	    io_chat.setNextColor(3) -- 赤
            print("not defined zone route", zone_id)
        else
            for i, dest in pairs(routeTable) do
		io_chat.setNextColor(6) -- 緑
                io_chat.print(i)
            end
        end
    else
	for i, dest in ipairs(destTable) do
	    io_chat.setNextColor(6) -- 緑
	    io_chat.print("["..i.."] dest: "..dest)
	    if dest:sub(1,1) == '-' then
		dest = dest:sub(2)
		reverse = true
	    else
		reverse = false
	    end
	    local nextDest = destTable[i+1]
	    _autoMoveTo(zone_id, dest, routeTable, reverse, nextDest)
	end
    end
end
M.autoMoveTo = autoMoveTo

function _autoMoveTo(zone_id, dest, routeTable, reverse, nextDest)
    local route = routeTable[dest]
    local nextRoute = routeTable[nextDest]
    if route == nil then
	io_chat.setNextColor(3) -- 赤
	io_chat.printf("route dest:%s is not found", dest)
	return
    end
    if reverse == true then
	route = array_reverse(route)
    end
    moveTo(route, routeTable, nextRoute)
end


return M
