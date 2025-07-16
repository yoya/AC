-- 開拓応援

local M = {}

local utils = require 'utils'
local acmob = require 'mob'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local io_chat = require 'io/chat'

M.auto = false

local N  = 0
local NE = math.pi * (1/4)
local E  = math.pi * (2/4)
local SE = math.pi * (3/4)
local S  = math.pi
local SW = math.pi * (5/4)
local W  = math.pi * (6/4)
local NW = math.pi * (7/4)

-- 0:喜ぶ 1:泣く 2:驚く 3:悔しむ
-- 4:励ます 5:慌てる 6:照れる 7:気合

local stationWorkerBoostTable = {
    [265] = { -- モリマー台地
        [0]  = {SE,S, 4}, [3]  = {S,SW, 5},
        [6]  = {SW,W, 6}, [9]  = {W,NW, 7},
        [12] = {NW,N, 0}, [15] = {N,NE, 1},
        [18] = {NE,E, 2}, [21] = {E,SE, 3},
    },
}

local getStationWorkerBoostInfo = function(zone)
    local timeTable = stationWorkerBoostTable[zone]
    local time = windower.ffxi.get_info().time
    for t, i in pairs(timeTable) do
        if t*60 <= time and time < (t+3)*60 then
            return i
        end
    end
    return nil
end 

-- 範囲は -math.pi < theta < math.pi
local normalangle = function(a)
    if a <= math.pi or math.pi <= a then
        a = a % (2*math.pi)
    end
    if a < math.pi then
        return a
    end
    return a - (2*math.pi)
end

-- 中間の角度
local midangle = function(a, b)
    a = normalangle(a)
    b = normalangle(b)
    if math.abs(a-b) < math.pi then
        return normalangle((a + b) / 2)
    end
    a = a % (2*math.pi)
    b = b % (2*math.pi)
    return normalangle(a - b)
end

local stationWorkerFunction = function(zone, mob)
    M.auto = true
    utils.target_lockon(true)
    local info = getStationWorkerBoostInfo(zone)
    -- N = 0, E = 3.14*0.5, S = 3.14, W = 3.14*1.5 
    local theta = midangle(info[1], info[2])
    io_chat.print("theta: "..theta.." select:"..info[3])
    local done = false
    -- 向きをあわせる
    while done == false and M.auto do
        utils.left_move(0.01)
        local me_pos = {}
        acmob.getMobPosition(me_pos, "me")
        local dx = me_pos.x - mob.x
        local dy = me_pos.y - mob.y
        local t = math.atan2(dx, dy)
        local dt = (theta % (2*math.pi)) - (t % (2*math.pi))
	-- io_chat.print("theta:"..theta.." t:"..t.." dt:"..dt)
        if math.abs(dt) < 2*math.pi/32 then
            done = true
        end
    end
    -- 応援方法を選択する
    pushKeys({"enter"})
    coroutine.sleep(2.5)
    if info[3] > 0 then
        for i = 1, info[3] do
	    print("select down: "..i.."/"..info[3])
            pushKeys({"down"})
            coroutine.sleep(0.5)
        end
    end
    pushKeys({"enter"})
    M.auto = false
end

M.stationWorkerFunction = stationWorkerFunction

return M
