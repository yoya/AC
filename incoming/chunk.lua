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

-- PC Update (0x0DD と似てる)
packet_handler[0x00D] = function(packet)
    local id = packet["Player"]
    local info = {
	index = packet["Index"],
	name = packet["Character Name"],
    }
    ac_party.updatePartyMemberInfo(id, info)
end

-- Status flags (古くからある)
packet_handler[0x00E] = function(packet)
--    io_chat.printf("0x00E Status Flags NPC:%d Index:%d",
--		   packet["NPC"], packet["Index"])
end

  -- Action Message
packet_handler[0x028] = function(packet)
    local cate = packet.Category
    if cate == 1 then
	-- auto attack
    elseif cate == 3 then
	-- io_chat.print("0x028 cate:3 Weapon Skill finish")
    elseif cate == 7 then
	-- io_chat.print("0x028 cate:7 Weapon Skill start")
	acinspect.ws()
	local id = packet["Actor"]
	local player = windower.ffxi.get_player()
	if player.id == id then
	    ac_stat.ws()
	end
    elseif cate == 8 then
	-- io_chat.print("XXX 魔法開始？"..packet.Actor..">"..packet.Param)
    else
	-- io_chat.print("XXX 0x028 cate:"..cate)
    end
    -- 連携の検知。battlemod を参考にした。
    if packet["Target 1 Action 1 Added Effect Message"] ~= nil then
	local id = packet["Target 1 ID"]
	local mob = windower.ffxi.get_mob_by_target("t")
	-- 戦闘中でない恐らく他パーティが戦っている敵への連携
	if mob == nil or mob.id ~= id then
	    return
	end
	local message = packet["Target 1 Action 1 Added Effect Message"]
	if  287 < message and message < 303 then
	    acinspect.sc(message, message - 287)
	elseif 384 < message and message < 399 then
	    acinspect.sc(message, message - 384)
	elseif 766 < message and message < 769 then
	    acinspect.sc(message, message - 752)
	elseif 768 < message and message < 771 then
	    acinspect.sc(message, message - 754)
	end
    end
end

-- Action Message
packet_handler[0x029] = function(packet)
    -- io_chat.print(packet)
    local mesg = packet.Message
    -- 自分もしくは味方が敵を倒した時の処理
    -- 自分もしくは味方が敵を倒した時の処理
    if (mesg == 6 or mesg == 20) then
	-- io_chat.print(packet)
	local actor_index = packet["Actor Index"]
	local target_index = packet["Target Index"]
	-- io_chat.print("defeated enemy: actor:"..actor_index .. " target:"..target_index)
	if not ac_party.isMemberIndex(actor_index) then
	    return  -- 恐らく他パーティが倒してるのでスルー
	end
	local mob = windower.ffxi.get_mob_by_index(target_index)
	if mesg == 6 then  -- defeated enemy
	    ac_stat.defeat(mob.name)
	elseif mesg == 20 then  -- falling enemy (イリュージョン)
	    ac_stat.falling(mob.name)
	    io_chat.setNextColor(3)
	    io_chat.print("XXX: action message: Fall???")
	end
	-- ac_defeated.done() -- setTask で表示しない時に戻せるよう残す
	-- command, delay, duration, period, eachfight)
	task.setTask(task.PRIORITY_LOW,
		     task.newTask("ac defeated", 3, 3, 1, true))
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

-- Pet Info
packet_handler[0x067] = function(packet)
    --io_chat.printf("0x067 Pet Info MessageType:%d OwnerIndex:%d",
    -- packet["Message Type"], packet["Owner Index"])
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

-- Alliance status update
packet_handler[0x0C8] = function(packet)
    local alliance_table = {}
    for i =1, 18 do
	local id = packet["ID "..i]
	local index = packet["Index "..i]
	local flags = packet["Flags "..i]
	local zone = packet["Zone "..i]
	alliance_table[id] = { id=id, index=index, flags=flags, zone=zone }
    end
    acinspect.party_update(alliance_table)
end

-- Party member update  (0x00D と似てる)
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
