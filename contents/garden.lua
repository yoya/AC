-- モグガーデン

local M = {}

local utils = require 'utils'
local split_multi = utils.string.split_multi

local control = require 'control'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

local io_chat = require 'io/chat'
local io_net = require 'io/net'

local incoming_text = require 'incoming/text'
local aczone = require 'zone'
local acitem = require 'item'

local item_data = require 'item/data'
local crystal_ids = item_data.crystal_ids -- クリスタル/塊

function M.tick(player)
    if not control.auto then return end
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
---        print("no target")
        return
    end
    if mob.name == "Green Thumb Moogle" then
	M.parent.AC.idleFunctionSellJunkItems(mob)
    elseif mob.name == "Ephemeral Moogle" then
        if acitem.checkInventoryFreespace() then
            for i, id in pairs(crystal_ids) do
                if acitem.bagsHasItem(id) then
                    acitem.bagsToInventory(id)
                    coroutine.sleep(1)
                end
            end
        end
        for i, id in pairs(crystal_ids) do
            if acitem.inventoryHasItem(id) then
                acitem.tradeByItemId(mob, id)
                coroutine.sleep(3)
                io_net.targetByMob(mob)
            end
        end
        coroutine.sleep(7)
        io_net.targetByMob(mob)
    elseif mob.name == "Garden Furrow" or mob.name == "Garden Furrow #2"
           or mob.name == "Garden Furrow #3" then
        local id = 940 -- 反魂樹の根
        acitem.tradeByItemId(mob, id)
        control.auto = false
    elseif string.find(mob.name, "Mineral Vein") or
	string.find(mob.name, "Arboreal Grove") then
        while control.auto do
            pushKeys({"escape", "f8", "enter"})
            coroutine.sleep(2)
            pushKeys({"enter"})
            coroutine.sleep(3)
            if acitem.diffInventoryTotalNum() == 0 or
                acitem.checkInventoryFreespace() == false then
                control.auto = false
            end
        end
    elseif mob.name == "Pond Dredger" then
        control.auto = false
        coroutine.sleep(2)
        pushKeys({"escape", "f8", "enter"})
        coroutine.sleep(3)
        pushKeys({"enter"})
    end
end

local listener_idx = 0

-- 同じメッセージで複数 incoming handler が動く事があるので、その対処
local furrow_check = false  -- 畑
local pond_check = false  -- 池
local rearing_check = false  -- モンスター飼育

M.furrow_count   = -1  -- 畑
M.arboreal_count = -1  -- 木立
M.mineral_count  = -1  -- 鉱脈
M.pond_count     = -1  -- 池
M.coast_count    = -1  -- 海
M.rearing_count  = -1  -- お世話
--
M.furrow_rank   = -1  -- 畑
M.arboreal_rank = -1  -- 木立
M.mineral_rank  = -1  -- 鉱脈
M.pond_rank     = -1  -- 池
M.coast_rank    = -1  -- 海
M.rearing_rank  = -1  -- お世話

M.rankup_count_table = {
    furrow   = { 0,  3, 10, 46, 127, 256, 512, 99999 },  -- 畑
    arboreal = { 0 , 9, 20, 74, 195, 300, 750, 99999 },  -- 木立
    mineral  = { 0,  9, 20, 74, 196, 300, 750, 99999 },  -- 鉱脈
    pond     = { 0,  3,  7, 16,  29,  50,  80, 99999 },  -- 池
    coast    = { 0,  3,  7, 16,  29,  50,  80, 99999 },  -- 海
    rearing  = { 0, 15, 20, 40,  60,  80, 100, 99999 },  -- お世話
}

-- M.check_garden_rankup("海", ”coast”)
function M.check_garden_rankup(name, label)
    local count = M[label..'_count']
    local rank = M[label..'_rank']
    local rankup_table = M.rankup_count_table[label]
    if count >= 0 and rank >= 0 then
	if rankup_table[rank+1] <= count then
	    io_chat.noticef("%sランクアップ(%d => %d), need:%d <= count:%d",
			    name,  rank, rank + 1, rankup_table[rank+1], count)
	end
    end
end

function M.check_coast_rankup()
    if M.coast_count >= 0 and M.coast_rank >= 0 then
	io_chat.printf("海 rank:%d => %d???, count:%d <= %d",
		       M.coast_rank, M.coast_rank + 1,
		       M.rankup_count_table.coast[M.coast_rank],
		       M.coast_count
	)
	if M.rankup_count_table.coast[M.coast_rank] <= M.coast_count then
	    io_chat.printf("海ランクアップ rank:%d => %d, count:%d <= %d",
			   M.coast_rank, M.coast_rank + 1,
			   M.rankup_count_table.coast[M.coast_rank],
			   M.coast_count
	    )
	end
    end
end

function M.incoming_text_handler(text)
    if string.contains(text, "の記録を") then
	furrow_check = true
	pond_check = true
	rearing_check = true
    end
    if M.furrow_rank < 0 and string.contains(text, "モーグリの畑") then
	local s = split_multi(text, {"ランク"})
	M.furrow_rank = utils.tonumber(s[2])
	io_chat.info("furrow_rank ", M.furrow_rank)
	M.check_garden_rankup("畑", "furrow")
    end
    if M.arboreal_rank < 0 and string.contains(text, "よく手入れされた木立") then
	local s = split_multi(text, {"ランク"})
	M.arboreal_rank = utils.tonumber(s[2])
	io_chat.info("arboreal_rank ", M.arboreal_rank)
	M.check_garden_rankup("木立", "arboreal")
    end
    if M.coast_rank < 0 and string.contains(text, "海岸に仕掛けられた網") then
	local s = split_multi(text, {"ランク"})
	M.coast_rank = utils.tonumber(s[2])
	io_chat.info("coast_rank ", M.coast_rank)
	M.check_garden_rankup("海", "coast")
    end
    if M.pond_rank < 0 and string.contains(text, "淡水の池に仕掛けられた網") then
	local s = split_multi(text, {"ランク"})
	M.pond_rank = utils.tonumber(s[2])
	io_chat.info("pond_rank ", M.pond_rank)
	M.check_garden_rankup("淡水の池", "pond")
    end
    if M.mineral_rank < 0 and string.contains(text, "露出した鉱脈") then
	local s = split_multi(text, {"ランク"})
	M.mineral_rank = utils.tonumber(s[2])
	io_chat.info("mineral_rank ", M.mineral_rank)
	M.check_garden_rankup("鉱脈", "mineral")
    end
    -- 
    if furrow_check and	string.contains(text, "畑での収穫回数：") then
	local s = split_multi(text, {"畑での収穫回数：", "木立の収穫回数：", "鉱脈の収穫回数："})
	M.furrow_count = utils.tonumber(s[2])
	M.arboreal_count = utils.tonumber(s[3])
	M.mineral_count = utils.tonumber(s[4])
	io_chat.setNextColor(7)
	io_chat.print("furrow_count ", M.furrow_count,
		      "arboreal_count", M.arboreal_count,
		      "mineral_count", M.mineral_count)
	furrow_check = false
    end
    if pond_check and string.contains(text, "池での漁獲回数：") then
	local s = split_multi(text, {"池での漁獲回数：", "海での漁獲回数："})
	M.pond_count = utils.tonumber(s[2])
	M.coast_count = utils.tonumber(s[3])
	io_chat.setNextColor(7)
	io_chat.print("pond_count", M.pond_count,
		      "coast_count", M.coast_count)
	pond_check = false
	M.check_garden_rankup("淡水の池", "pond")
	M.check_garden_rankup("海", "coast")
    end
    if rearing_check and text:contains( "モンスター飼育完了総数：") then
	local s = split_multi(text, {"お世話した回数：", "モンスター飼育完了総数："})
	M.rearing_count = utils.tonumber(s[2])
	io_chat.setNextColor(7)
	io_chat.print("rearing_count", M.rearing_count)
	rearing_check = false
    end
end

function M.contents_in()
    listener_idx = incoming_text.addListener("", M.incoming_text_handler)
end

function M.contents_out()
    if listener_idx > 0 then
	incoming_text.removeListener(listener_idx)
	listener_idx = 0
    end
end

return M
