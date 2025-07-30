-- Utility
-- 雑多な関数群。整理できてない

local command = require 'command'

local M = {}

-- utils/*.lua メソッドのマージ
function M.child_module_merge(parent, mod)
    mod.parent = parent
    for n, m in pairs(mod) do
	if M[n] ~= nil then
	    error("utils.child_module_merge: duplicate member:"..n)
	end
	M[n] = m
    end
end

M.child_module_merge(M, require 'utils/table')
M.child_module_merge(M, require 'utils/angle')
M.child_module_merge(M, require 'utils/party')

function M.iamLeader()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    if party.party1_leader == player.id then
        return true
    end
    return false
end

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

M.distance = function(target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
        print("distance: target:"..#target.." not found")
        return false
    end
    return mob.distance;
end

M.rankInJob = function()
    print("rankInJob")
    local party = windower.ffxi.get_party()
    for i = 0, 5 do
        local member = party["p"..i]
        if i == 1 then
            io_chat.print(member)
        end
    end
end

M.cureIfPartyHPisLow = function()
    local player = windower.ffxi.get_player()
    local mainJob = player.main_job
    local subJob = player.sub_job
    if mainJob ~= "WHM" and mainJob ~= "SCH" and
       mainJob ~= "RDM" then
        mainJob = nil
    end
    if subJob ~= "WHM" and subJob ~= "SCH" and
        subJob ~= "RDM" then
        subJob = nil
    end
    if mainJob == nil and subJob == nil then
        return
    end
--    print("cureIfPartyHPisLow:"..mainJob)
    local player_mp = player.vitals.mp
    if player_mp < 8 then
        print("few player mp:"..player_mp)
        return
    end
    local party = windower.ffxi.get_party()
    for i=0,5 do
        local t = "p"..i
        local member = party[t]
        if member ~= nil and  member.mob ~= nil then
            local hpp = member.hpp
            local hp = member.hp
            local hp_need_cure = 75
            if mainJob == "RDM" or mainJob == nil then
                hp_need_cure = 65
            end
            if mainJob == "BLM" then
                hp_need_cure = 50
            end
            if hp > 0 and hpp < hp_need_cure
                and hp < 1800 then
--              print(t.." HP: "..hp.." ("..hpp.."%)")
                local c = 'input /ma ケアル <'..t..'>'
                if hp < 300 and mainJob == "WHM" then
                    c = 'input /ja 女神の祝福 <me>'
                elseif hp < 500 and player_mp >= 88 then
                   c = 'input /ma ケアルIV <'..t..'>'
                elseif hp < 1000  and player_mp >= 46 then
                    c = 'input /ma ケアルIII <'..t..'>'
                elseif hp < 1500  and player_mp >= 24 then
                    c = 'input /ma ケアルII <'..t..'>'
                end
                windower.ffxi.run(false)
                command.send(c)
                coroutine.sleep(2)
            end
        end
    end
end

M.target_lockon = function(b)
    local player = windower.ffxi.get_player()
    local locked = player.target_locked
    if b ~= locked then
        command.send('input /lockon')
    end
end

function M.left_move(t)
    command.send('setkey a down')
    coroutine.sleep(t)
    command.send('setkey a up')
end

function M.right_move(t)
    command.send('setkey d down')
    coroutine.sleep(t)
    command.send('setkey d up')
end




return M
