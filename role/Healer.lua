-- Healer 役。白魔、学者、赤魔

local command = require 'command'
local io_chat = require 'io/chat'

local M = {}

M.cureIfPartyHPisLow = function(hp_need_cure)
    local player = windower.ffxi.get_player()
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

function M.mainTick()
    local player = windower.ffxi.get_player()
    if player.main_job == "WHM" then
	M.cureIfPartyHPisLow(75)
    else
	M.cureIfPartyHPisLow(60)
    end
end

function M.subTick()
    M.cureIfPartyHPisLow(50)
end

return M
