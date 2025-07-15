---
--- Position
--- 位置関係の関数郡

local M = {}

local utils = require 'utils'
local array_reverse = utils.array_reverse
local turnToFront = utils.turnToFront

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

local command = require 'command'
local io_chat = require 'io/chat'

function targetPos(t)
    local mob = windower.ffxi.get_mob_by_target(t)
    if mob == nil then
        return nil
    end
    return {x=mob.x, y=mob.y, z=mob.z}
end
M.targetPos = targetPos

function targetDistance(t)
    local mob = windower.ffxi.get_mob_by_target(t)
    if mob == nil then
        return nil
    end
    return mob.distance
end
M.targetDistance = targetDistance


function currentPos()
    return targetPos("me")
end
M.currentPos = currentPos

function distance2(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    return dx * dx + dy * dy
end

function distance(pos1, pos2)
    if pos1 == nil or pos2 == nil then
        return 99999
    end
    if pos1.z ~= nil and pos2.z ~= nil then
        local dz = pos2.z - pos1.z
        if math.abs(dz) > 10 then
            return 99999
        end
    end
    return math.sqrt(distance2(pos1, pos2))
end
M.distance = distance

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
            local r = routeTable[p.r]
            print("r", r)
            table[p.r] = r[1]
            table.insert(r1List, r[1])
            table.insert(r1ListName, p.r)
        end
    end
    print("rList", rList)
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
        if i < start_idx then
            print("skip route idx:", i)
        else
            if p.x == nil and p.a == nil then
                windower.ffxi.run(true)
                break
            end
            if p.a == "mount" then
                command.send('input /mount ラプトル')
                coroutine.sleep(2.0)
            end
            if p.a == "dismount" then
                command.send('input /dismount')
                coroutine.sleep(2.0)
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
                print("moving", i, p.x, p.y)
                while (distance(currentPos(), p) > 0.5 and moveToRunning == true) do
                    if distance(currentPos(), p) > 6468 and false then
                        print("not near position")
                        stop()
                        return
                    end
                    turnTo(p)
                    pos = currentPos()
                    windower.ffxi.run(p.x - pos.x, p.y - pos.y)
                    coroutine.sleep(0.1)
                end
                windower.ffxi.run(false)
                local t = math.random(0,1)/5
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
