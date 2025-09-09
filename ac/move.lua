--- Move
--- 移動処理。向き変更もここ

local M = {}

local utils = require 'utils'
local array_reverse = utils.table.array_reverse

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local command = require 'command'
local io_chat = require 'io/chat'

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

local moveToRunning = false

function stop()
---    print("moveToRunning = false")
    moveToRunning = false
end
M.stop = stop

function moveTo(route, routeTable)
    local pos = currentPos()
    local r1List = {}  -- 各routeの一個目をリスト化
    local r1ListName = {}
    if routeTable == nil then
	print("routeTable == nil")
	return
    end
    for i, p in ipairs(route) do
        if p.r ~= nil then
            print("p.r="..(p.r))
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
        print(idx, name, r)
        moveTo(r, routeTable)
    end
    moveToRunning = true
    print("moveFrom", math.round(pos.x, 2), math.round(pos.y, 2))
    local start_idx = nearest_idx(pos, route)
--    print('start_idx', start_idx)
    if distance(pos, route[start_idx]) > 64 then
        print("not starting position")
        stop()
        return false
    end
--    print("#route", #route)
    for i, p in ipairs(route) do
	if i <= 1 then
	     do end
	elseif i < start_idx then
            print("skip route idx:", i)
        else
	    if p.r ~= nil then
		moveTo(p.r, routeTable)
	    end
	    if p.x == nil and p.a == nil then
                windower.ffxi.run(true)
                break
            end
	    if p.w ~= nil then
		print("wait:"..p.w)
		coroutine.sleep(p.w)
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
            if p.x ~= nil then
		local x = p.x
		local y = p.y
		local d = p.d or 0
                print("moving to", i, x, y, d)
		x = x + math.random(-d*100,d*100)/100
		y = y + math.random(-d*100,d*100)/100
		local dpos = {x=x,y=y,z=p.z}
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
                local t = math.random(0,2)/10
                coroutine.sleep(t)
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
                pushKeys({"enter"})
                coroutine.sleep(1.0)
            end
            if p.a == "wait" then
                coroutine.sleep(1.0)
            end
            if p.a == "up" then
                pushKeys({"up"})
                coroutine.sleep(1.0)
            end
            if p.a == "down" then
                pushKeys({"down"})
                coroutine.sleep(1.0)
            end
        end
    end
    return true
end
M.moveTo = moveTo

function autoMoveTo(zone_id, dest, routeTable, reverse)
    if dest == nil then
        if routeTable == nil then
            print("not defined zone route", zone_id)
        else
            for i, dest in pairs(routeTable) do
                io_chat.print(i)
            end
        end
    else
        route = routeTable[dest]
        if reverse == true then
            route = array_reverse(route)
        end
        moveTo(route, routeTable)
    end
end
M.autoMoveTo = autoMoveTo

return M
