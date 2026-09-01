-- Healer 役。白魔、学者、赤魔

local command = require 'command'
local io_chat = require 'io/chat'
local pstatus = require 'player_status'
local ac_move = require 'ac/move'

local M = {}

function get_lower_hp_target(hpp_needed)
    local party = windower.ffxi.get_party()
    local min_hp = 99999
    local min_target = nil
    local count = 0
    for i=0,5 do
        local t = "p"..i
        local member = party[t]
        if member ~= nil and  member.mob ~= nil then
            local hpp = member.hpp
            local hp = member.hp
            if hp > 0 and hpp < hpp_needed then
		count = count + 1
		if hp < min_hp then
		    min_hp = hp
		    min_target = t
		end
            end
        end
    end
    return count, min_target
end

M.cure_action_table = {
    { hp=1800, mp=8, cure='ケアル', tp=200, waltz='ケアルワルツ' },
    { hp=1500, mp=24, cure='ケアルII', tp=350, waltz='ケアルワルツII' },
    { hp=1000, mp=46, cure='ケアルIII', tp=500, waltz='ケアルワルツIII' },
    -- ここから main RDM,WHM, DNCのみ
    { hp=500, mp=99, cure='ケアルIV', tp=650, waltz='ケアルワルツIV' },
}

M.cure_if_party_h_pis_low = function(player, hp_need_cure)
    if player.status ~= pstatus.ENGAGED then
	return  -- 戦闘してなければ、何もしない
    end
    local main_job = player.main_job
    local sub_job = player.sub_job
    local player_mp = player.vitals.mp
    local player_tp = player.vitals.tp

    if main_job == "DNC" or sub_job =="DNC" then
	if player_tp < 200 then
	    -- print("few player tp:"..player_mp)
	    return
	end
    else
	if player_mp < 8 then
	    -- print("few player mp:"..player_mp)
	    return
	end
    end
    local party = windower.ffxi.get_party()
    for i=0,5 do
        local t = "p"..i
        local member = party[t]
        if member ~= nil and  member.mob ~= nil then
	    ac_move.want_stop()
            local hpp = member.hpp
            local hp = member.hp
            if hp > 0 and hpp < hp_need_cure
                and hp < 1800 then
		io_chat.notice(t.." HP: "..hp.." ("..hpp.."%)")
                local c = 'input /ma ケアル <'..t..'>'
		if main_job == "DNC" or sub_job =="DNC" then
		    c = 'input /ja ケアルワルツ <'..t..'>'
		end
                if hp < 300 and main_job == "WHM" then
                    c = 'input /ja 女神の祝福 <me>'
		else
		    for _, cure_action in ipairs(M.cure_action_table) do
			if hp < cure_action.hp then
			    if main_job == "DNC" or sub_job =="DNC" then
				if cure_action.tp < player_tp then
				    c = 'input /ja '..cure_action.waltz..' <'..t..'>'
				end
			    else
				if cure_action.mp < player_mp then
				    c = 'input /ma '..cure_action.cure..' <'..t..'>'
				end
			    end
			end
		    end
		end
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
	    M.cure_if_party_h_pis_low(player, 75)
	else
	    M.cure_if_party_h_pis_low(player, 60)
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
	M.cure_if_party_h_pis_low(player, 50)
    end
end

return M
