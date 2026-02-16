-- Healer 役。白魔、学者、赤魔

local command = require 'command'
local io_chat = require 'io/chat'

local M = {}

function getLowerHPTarget(hpp_needed)
    local party = windower.ffxi.get_party()
    local target = nil
    local minHP = 99999
    local minTarget = nil
    local count = 0
    for i=0,5 do
        local t = "p"..i
        local member = party[t]
        if member ~= nil and  member.mob ~= nil then
            local hpp = member.hpp
            local hp = member.hp
            if hp > 0 and hpp < hpp_needed then
		count = count + 1
		if hp < minHP then
		    minHP = hp
		    minTarget = t
		end
            end
        end
    end
    return count, target
end

M.cureIfPartyHPisLow = function(player, hp_need_cure)
    if player.status ~= 1 then
	return  -- 戦闘してなければ、何もしない
    end
    local main_job = player.main_job
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
            if hp > 0 and hpp < hp_need_cure
                and hp < 1800 then
		io_chat.print(t.." HP: "..hp.." ("..hpp.."%)")
                local c = 'input /ma ケアル <'..t..'>'
                if hp < 300 and main_job == "WHM" then
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

function M.main_tick(player)
    local item_level = player.item_level
    if item_level < 117 then
        if math.random(1, 100) < 0 then
            -- command.send('input /ma インビジ <me>')
        end
    else
	if player.main_job == "WHM" then
	    M.cureIfPartyHPisLow(player, 75)
	else
	    M.cureIfPartyHPisLow(player, 60)
	end
    end
end

function M.sub_tick(player)
    local item_level = player.item_level
    if item_level < 117 then
        if math.random(1, 100) < 0 then
            -- command.send('input /ma インビジ <me>')
        end
    else
	M.cureIfPartyHPisLow(player, 50)
    end
end

return M
