local M = {}

local packets = require('packets')

local io_chat = require('io/chat')
local acstat = require('stat')
local acinspect = require('inspect')
local ac_record =  require('ac/record')
local ac_defeated = require('ac/defeated')
local ac_party = require('ac/party')

local packet_handler = { }

packet_handler[0x01B] = function(packet) -- Job Info
    --[[
    local data = packet._raw
    local arr = data:unpack('I')
    local main_job = arr[0x08]
    print("main_job"..main_job)
    local job_master_level = arr[0x6D+(2*main_job)+1]
    io_chat.print("job_master_level:"..job_master_level)
    ]]
end

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
	    acstat.defeat(mob.name)
	    -- defeated 表示/保存処理は queue に乗せる予定
	    ac_defeated.done()
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
    local points = packet["Unity Points"]  -- ユニテイポイント
    ac_record.unity(points)
end

-- Update Current Sparks via 110
packet_handler[0x110] = function(packet)
    local sparks = packet["Sparks Total"]
    ac_record.eminence(sparks)
end

function M.incoming_handler(id, data, modified, injected, blocked)
    local handler = packet_handler[id]
    if handler ~= nil then
	local packet = packets.parse('incoming', data)
	handler(packet)
    end
end

return M
