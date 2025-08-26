local M = {}

local packets = require('packets')

local io_chat = require('io/chat')

local task = require('task')
local acinspect = require('inspect')

local ac_char = require('ac/char')
local ac_defeated = require('ac/defeated')
local ac_party = require('ac/party')
local ac_stat = require('ac/stat')

local packet_handler = { }

packet_handler[0x028] = function(packet) -- Action Message
    local cate = packet.Category
    -- io_chat.print("0x028: " .. cate)
    if cate == 1 then
	-- auto attack
    elseif cate == 3 then
	-- io_chat.print("0x028 cate:3 Weapon Skill finish")
    elseif cate == 7 then
	-- io_chat.print("0x028 cate:7 Weapon Skill start")
	acinspect.ws()
    else
	-- io_chat.print("XXX 0x028 cate:"..cate)
    end
end

packet_handler[0x029] = function(packet) -- Action Message
    -- io_chat.print(packet)
    local mesg = packet.Message
    if mesg == 6 then  -- defeated enemy
	-- io_chat.print(packet)
	local actor_index = packet["Actor Index"]
	local target_index = packet["Target Index"]
	-- io_chat.print("defeated enemy: actor:"..actor_index .. " target:"..target_index)
	-- 敵を倒した時の処理
	if ac_party.isMemberIndex(actor_index) then
	    local mob = windower.ffxi.get_mob_by_index(target_index)
	    ac_stat.defeat(mob.name)
	    -- defeated 表示/保存処理は queue に乗せる予定
	    ac_defeated.done() -- setTask だと表示しない時があるので、一旦戻す
	    -- command, delay, duration, period, eachfight)
	    task.setTask(task.PRIORITY_LOW,
			 task.newTask("ac defeated", 3, 3, 3, true))
	end
    elseif mesg == 20 then
	io_chat.setNextColor(3)
	io_chat.print("XXX: action message: Fall???")
    elseif mesg == 206 then
	do end -- (味方の？)強化切れ
    else
	do end
	-- io_chat.print("XXX 0x029: "..packet.Message)
	-- 4 敵弱体
	-- 17 味方強化？
	-- 18  MB ？
    end
end

-- Kill Message, when you gain XP/LP/CP/JP/MP
packet_handler[0x02D] = function(packet)
    --local player = windower.ffxi.get_player()
    --io_chat.print("============== packet(0x2D)")
    --if packet["Player Index"] == player.index then
    --    io_chat.print(packet)
    --end
end

-- Char Stats -- id がないので(パーティメンバーでなく)自分のみの情報？
packet_handler[0x061] = function(packet)
    local player = windower.ffxi.get_player()
    local char = {
	main_job_id = packet["Main job"],
	sub_job_id = packet["Sub job"],
	unity_point = packet["Unity Points"],
	current_exp_point = packet["Current EXP"],
	next_exp_point = packet["Required EXP"],
	master_breaker = packet["Master Breaker"],
	current_exemplar_point = packet["Current Exemplar Points"],
	next_exemplar_point = packet["Required Exemplar Points"],
    }
    ac_char.update(player.id, char)
end

-- This packet likely varies based on jobs, but currently I only have it worked out for Monstrosity.
packet_handler[0x063] = function(packet)
    local player = windower.ffxi.get_player()
    if player == nil then
	return
    end
    local char = {
	current_merit_point = packet["Merit Points"],
	limit_breaker = packet["Limit Breaker"],
	max_merit_point = packet["Max Merit Points"],
    }
    ac_char.update(player.id, char)
end

-- Party status icon update
packet_handler[0x076] = function(packet)
    --[[ packets/fields.lua を見ると以下の構造っぽいけど駄目
    for i, member in ipairs(packet["Party Buffs"]) do
	local index = member["Index"]
	ac_party.updatePartyMemberInfo({
	    id = packet["ID"],
	    index = member["Index"],
	    buffs = member["Buffs"],
	})
    end
    ]]
end

-- Party member update
packet_handler[0x0DD] = function(packet)
    local id = packet["ID"]
    local info = {
	index = packet["Index"],
	main_job = packet["Main job"],
	main_job_level = packet["Main job level"],
	sub_job = packet["Sub job"],
	sub_job_level = packet["Sub job level"],
	master_level = packet["Master Level"],
	name = packet["Name"],
    }
    ac_party.updatePartyMemberInfo(id, info)
end
-- Char Update
packet_handler[0x0DF] = function(packet)
    local id = packet["ID"]
    local char = {
	main_job_id = packet["Main job"],
	sub_job_id = packet["Sub job"],
	-- master_level = packet["Master Level"],
	master_breaker = packet["Master Breaker"],
    }
    -- ac_char.update(id, char)
end

-- Update Current Sparks via 110
packet_handler[0x110] = function(packet)
    local player = windower.ffxi.get_player()
    local char = {
	eminence_point = packet["Sparks Total"]
    }
    ac_char.update(player.id, char)
end

-- Currency Info (Currencies I)
packet_handler[0x113] = function(packet)
    local player = windower.ffxi.get_player()
    local char = {
	eminence_point = packet["Sparks of Eminence"],
	unity_point = packet["Unity Accolades"],
    }
    ac_char.update(player.id, char)
end

-- Currency Info (Currencies2)
packet_handler[0x118] = function(packet)
    local player = windower.ffxi.get_player()
    local char = {
	hallmark = packet["Hallmarks"],
	total_hallmark = packet["Total Hallmarks"],
	gallantry = packet["Badges of Gallantry"],
	domain_point = packet["Domain Points"],
	mog_segments = packet["Mog Segments"],
	gallimaufry = packet["Gallimaufry"],
    }
    ac_char.update(player.id, char)
end

function M.incoming_handler(id, data, modified, injected, blocked)
    local handler = packet_handler[id]
    --print("incoming_handler:",id)
    if handler ~= nil then
	local packet = packets.parse('incoming', data)
	handler(packet)
    end
end

return M
