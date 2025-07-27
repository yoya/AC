local packets = require('packets')

local utils = require('utils')
local io_chat = require('io/chat')
local acstat = require('stat')
local acinspect = require('inspect')

local M = {}

function actionHandler(amPacket) -- 0x028
    local cate = amPacket.Category
    -- io_chat.print("0x028: " .. cate)
    if cate == 7 then
	-- io_chat.print("Weapon Skill start")
	acinspect.ws()
    elseif cate == 3 then
	-- io_chat.print("Weapon Skill finish")
    end
end

function actionMessageHandler(amPacket) -- 0x029
    -- io_chat.print(amPacket)
    -- io_chat.print("0x029: "..amPacket.Message)
    local mesg = amPacket.Message
    if mesg == 6 then  -- defeated enemy
	-- io_chat.print(amPacket)
	local actor_index = amPacket["Actor Index"]
	local target_index = amPacket["Target Index"]
	-- io_chat.print("defeated enemy: actor:"..actor_index .. " target:"..target_index)
	if utils.isMemberIndex(actor_index) then
	    local mob = windower.ffxi.get_mob_by_index(target_index)
	    acstat.defeat(mob.name)
	    acstat.print()
	end
    elseif mesg == 20 then
	io_chat.print("XXX: action message: Fall???")
    elseif mesg == 206 then
	do end -- (味方の？)強化切れ
    end
end

function M.incoming_handler(id, data, modified, injected, blocked)
    local player = windower.ffxi.get_player()
    if id == 0x028 then -- Action Message
	actionHandler(packets.parse('incoming', data))
    elseif id == 0x029 then -- Action Message
	actionMessageHandler(packets.parse('incoming', data))
    elseif id == 0x02D then
	--        local packet = packets.parse('incoming', data)
	--          io_chat.print("============== packet(0x2D)")
	--        if packet["Player Index"] == player.index then
	--            io_chat.print(packet)
	--        end
    elseif id == 0x110 then -- Update Current Sparks via 110
	local header, value1, value2, Unity1, Unity2, Unknown = data:unpack('II')
	acinspect.eminence(value1)
    end
end

return M
