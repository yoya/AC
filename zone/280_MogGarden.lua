-- モグガーデン

local M = { id = 280 }

local utils = require 'utils'
local io_chat = require 'io/chat'
local io_net = require 'io/net'
local incoming_text = require 'incoming/text'

local split_multi = utils.string.split_multi

M.routes = { }

function garden_furrow(player, mob)
    io_net.targetByMobId(mob.id)
    coroutine.sleep(3)
end

function M.tick(player)
    local mobArr = windower.ffxi.get_mob_array()
    if M.parent.isNear(280, "furrow", 3) then
        for i, m in pairs(mobArr) do
            if string.find(m.name, "Garden Furrow") then
		-- garden_furrow(player, m)
            end
        end
    end
end

local listener_idx = 0

local furrow_check = false  -- 畑
local pond_check = false  -- 池
local rearing_check = false  -- モンスター飼育

function M.incoming_text_handler(text)
    if string.contains(text, "の記録を") then
	furrow_check = true
	pond_check = true
	rearing_check = true
    end
    if furrow_check and	string.contains(text, "畑での収穫回数：") then
	local s = split_multi(text, {"畑での収穫回数：", "木立の収穫回数：", "鉱脈の収穫回数："})
	local furrow_count = utils.tonumber(s[2])
	local arboreal_count = utils.tonumber(s[3])
	local mineral_count = utils.tonumber(s[4])
	io_chat.setNextColor(7)
	io_chat.print("furrow_count ", furrow_count, "arboreal_count", arboreal_count, "mineral_count", mineral_count)
	furrow_check = false
    end
    if pond_check and string.contains(text, "池での漁獲回数：") then
	local s = split_multi(text, {"池での漁獲回数：", "海での漁獲回数："})
	local pond_count = utils.tonumber(s[2])
	local coast_count = utils.tonumber(s[3])
	io_chat.setNextColor(7)
	io_chat.print("pond_count", pond_count, "coast_count", coast_count)
	pond_check = false
    end
    if rearing_check and text:contains( "モンスター飼育完了総数：") then
	local s = split_multi(text, {"お世話した回数：", "モンスター飼育完了総数："})
	local rearing_count = utils.tonumber(s[2])
	io_chat.setNextColor(7)
	io_chat.print("rearing_count", rearing_count)
	rearing_check = false
    end
end

function M.zone_in()
    print("M.zone_in")
    listener_idx = incoming_text.addListener("", M.incoming_text_handler)
end

function M.zone_out()
    print("M.zone_out")
    if listener_idx > 0 then
	incoming_text.removeListener(listener_idx)
	listener_idx = 0
    end
end

M.essentialPoints = {
    furrow = {x=5.1,y=2.0,z=0.1}, -- 畑
}

return M
