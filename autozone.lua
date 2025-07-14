--- zone 関係

local M = {}

local utils = require 'utils'
local io_chat = require 'io/chat'

local acpos = require 'pos'
local currentPos = acpos.currentPos
local turnTo = acpos.turnTo
local lookForward = acpos.lookForward
local command = require 'command'
local aczone = require 'zone'

function isNear(pos)
    local me_pos = acpos.currentPos()
    d = acpos.distance(me_pos, pos)
    if d < 1.0 then
        return true
    end
    return false
end

function zone_change_handler()
    coroutine.sleep(3)
    local zone = windower.ffxi.get_info().zone
    local me_pos = acpos.currentPos()
    if me_pos == nil then
        print("failed currentPos for me_pos")
        return ;
    end
    local round_x = math.round(me_pos.x, 3)
    local round_y = math.round(me_pos.y, 3)
    local round_z = math.round(me_pos.z, 3)
    print("zone:"..zone.." x="..round_x.." y="..round_y.." z="..round_z)
---    local east_adoulin_hp_pos = {-50.5, -92, 0} ここまで含める
    local east_adoulin_hp2_pos = {-51.5, -96, 0}
---local east_adoulin_hp2_pos = {-57.8, -130, 0}
    local jeuno_garden_hp_pos = {36.0, 8.8}
    if zone == 257 then
--        print("東アドゥリンなう")
        local dx = me_pos.x - east_adoulin_hp2_pos[1]
        local dy = me_pos.y - east_adoulin_hp2_pos[2]
        local dist = math.sqrt(dx*dx + dy+dy)
--        print("dist: "..dist)
        if dist < 10 then
            io_chat.print("東アドゥリン Home Point #2 (M)")
            coroutine.sleep(10)
            local me_pos2 = acpos.currentPos()
            local dx2 = me_pos.x - me_pos2.x
            local dy2 = me_pos.y - me_pos2.y
            local dist2 = math.sqrt(dx2*dx2 + dy2+dy2)
            if dist2 < 0.5 then
                turnTo({x=-58, y=-131}) --- モグハウスへ
                lookForward()
                coroutine.sleep(2)
                windower.ffxi.run(true)
            else
                print("dist >= 0.5")
            end
        end   
    elseif zone == 246 then
--        io_chat.print("ジュノ庭なう")
        local dx = me_pos.x - jeuno_garden_hp_pos[1]
        local dy = me_pos.y - jeuno_garden_hp_pos[2]
        local dist = math.sqrt(dx*dx + dy+dy)
        print("dist: "..dist)
        if dist < 10 then
--            io_chat.print("ジュノ庭 Home Point #1 (E)")
            coroutine.sleep(2)
            turnTo({x=-54.5, y=0}) --- ヨアヒムとシェミの間
            lookForward()
            coroutine.sleep(3)
            windower.ffxi.run(true)
        end
    --- ソロムグ原野(120),ザルカバード(112)
    ---  ワジャーム樹林(51)、ゼオルム火山(61)、カダーバの浮沼(79)、ボスディン(111)、
    --- ヨアトル森林(124), 東アルテパ(114), 西アルテパ(125)、 バタリア(105)
    --- ビビキー湾(4)、マリミア(266)
    -- 過去ロランベリー耕地(84)
    --- ケイザック古戦場(261)、ヤッセの狩り場(260), モリマー台地(265),ヨルシア森林(263)
    --- 一旦外す。ワークスの邪魔   261, 260, 265, 263, 266
--    elseif utils.contains({120, 112, 51, 61, 79, 111, 124, 114, 125, 105, 4, 84}, zone) then
--        io_chat.print("5秒後に /mount ラプトル")
--        coroutine.sleep(5) --- 10はok
--        command.send('input /mount ラプトル; wait 1; input /follow <p1>')
    elseif zone == 70 then
        io_chat.print("チョコボサーキットなう")
        coroutine.sleep(2)
---        turnToPos(-320, -475, -335.4, -473.2)
        local tx = -335.4
---        local ty = -474.5  --- 475 > x < 473.5 
        local ty = -473.5  --- 475 > x < 473.5 
        turnTo({tx, ty})
        lookForward()
        coroutine.sleep(2)
        windower.ffxi.run(tx - me_pos.x, ty - me_pos.y)
        lookForward()
    elseif zone == 142 then  --- ユグホト砦洞窟内
        if isNear({x=437.2,y=68.6,z=-40}) then -- 温泉から入った所
	    local routeTable = aczone.getRouteTable(zone)
            acpos.autoMoveTo(zone, "horl", routeTable, false)
        elseif isNear({x=434,y=170,z=-40}) then -- HP#1
            windower.ffxi.run(1, 0)  -- go to right
        end
    elseif zone == 79 then  --- カダーバのうき沼、本ワープ
        windower.ffxi.run(-1, 0)  -- go to left
    elseif zone == 273 then -- うぉーの門
        print("woh gate")
        coroutine.sleep(1)
	local routeTable = aczone.getRouteTable(zone)
        acpos.autoMoveTo(zone, "raive", routeTable, false)
    end
end
M.zone_change_handler = zone_change_handler

function warp_handler(prevZone, prevPos, zone, pos)
    if prevPos == nil or pos == nil then
        print(prevPos, pos)
        return
    end
    print("warp_handler", prevZone, prevPos.x, prevPos.y, zone, pos.x, pos.y)
    if zone == 139 then -- ホルレー
        io_chat.print("ホルレーなう")
        local bcStartPos = {x=-316.3,y=-102.57}
        local dist = acpos.distance(pos, bcStartPos)
        io_chat.print({"dist", dist})
        if dist < 10 then
            io_chat.print("AMAN トローブ開始位置")
            coroutine.sleep(2)
        end  
    end
end
M.warp_handler = warp_handler

return M
