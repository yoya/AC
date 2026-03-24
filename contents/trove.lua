-- AMAN トローブ

local M = {}

local control =  require 'control'
local incoming_text = require 'incoming/text'
local acitem =  require 'item'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

M.item_list = {
    9275, -- マーズオーブ
    9276, -- ビーナスオーブ
}
M.item_table = {
    [9275] = 1, -- マーズオーブ
    [9276] = 1, -- ビーナスオーブ
}

function M.init()
end
M.init()

function M.tick(player)
end

function M.zone_in()
    M.init()
end

function M.zone_out()
    M.init()
end

function M.tick(player)
    if not control.auto or last_time == nil then
	last_time = nil
    else
	if (last_time + 60) < os.time() then
	    if M.mob_Furnace ~= nil then
		target_and_lockon(M.mob_Furnace)
		coroutine.sleep(1)
	    end
	    last_time = os.time()
	end
    end
end

function BurningCircleFunction(zone, mob)
    if not control.auto or mob == nil then
	return
    end
    if not acitem.inventoryHasItem(M.item_list[1]) and
	not acitem.inventoryHasItem(M.item_list[2]) then
	return
    end
    print("BurningCircleFunction")
    if acitem.inventoryHasItem(M.item_list[1]) and
	acitem.inventoryHasItem(M.item_list[2]) then
	acitem.tradeByItemTable(mob, M.item_table)
    else
	for _, item_id in ipairs(M.item_list) do
	    if acitem.inventoryHasItem(item_id) then
		acitem.tradeByItemId(mob, item_id)
	    end
	end
    end
    coroutine.sleep(10)
    print("----------")
    pushKeys({"down"}) -- ひとつ下を選択。
    coroutine.sleep(1)
    pushKeys({"enter"}) -- BCに入る
end

function GreysonFunctionFunction(zone, mob)
    for _, item_id in ipairs(M.item_list) do
	if acitem.inventoryHasItem(item_id) then
	    acitem.tradeByItemId(mob, item_id)
	    coroutine.sleep(10)
	end
    end
end

function M.incoming_text_handler(text)
end

--- 切り替え

M.npcActionHandlers = {
    ["Burning Circle"] = BurningCircleFunction,
    ["Greyson"] = GreysonFunction,
}

M.listener_id = incoming_text.addListener("", M.incoming_text_handler)


return M
