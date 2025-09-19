-- Utility
-- 雑多な関数群。整理できてない

local command = require 'command'

local M = {}

--[[
    local run = windower.ffxi.run
windower.ffxi.run = function(...)
    run(...)
    local a = {...}()
    if not a then print(debug.traceback()) end
end
]]

-- utils/*.lua メソッドのマージ
function M.require_child_module(parent, parentname, modname)
    local mod = require(parentname..'/'..modname)
    mod.parent = parent
    parent[modname] = mod
    --[[
    for n, m in pairs(mod) do
	if n ~= 'parent' and M[n] ~= nil then
	    error("utils.require_child_module:\nduplicate member:"..n)
	end
	M[n] = m
    end
    ]]
end

M.require_child_module(M, 'utils', 'string')
M.require_child_module(M, 'utils', 'table')
M.require_child_module(M, 'utils', 'angle')
M.require_child_module(M, 'utils', 'vector')

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

--[[
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
]]

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


function M.split(inputstr, sep)
  if sep == nil then
      sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function M.tonumber(s)
    return tonumber(string.match(s, "[0-9]+"))
end

return M
