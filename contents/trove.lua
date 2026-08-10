-- AMAN トローブ

local M = {}

local control =  require 'control'
local acitem =  require 'item'
local keyboard = require 'keyboard'
local push_keys = keyboard.push_keys

local last_time = nil

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
    if not acitem.inventory_has_item(M.item_list[1]) and
	not acitem.inventory_has_item(M.item_list[2]) then
	return
    end
    print("BurningCircleFunction")
    if acitem.inventory_has_item(M.item_list[1]) and
	acitem.inventory_has_item(M.item_list[2]) then
	acitem.trade_by_item_table(mob, M.item_table)
    else
	for _, item_id in ipairs(M.item_list) do
	    if acitem.inventory_has_item(item_id) then
		acitem.trade_by_item_id(mob, item_id)
	    end
	end
    end
    -- coroutine.sleep(10)  -- 動く
    coroutine.sleep(9)
    -- coroutine.sleep(8)  -- あとで試す
    -- coroutine.sleep(5)  -- 動かない
    print("----------")
    push_keys({"down"}) -- ひとつ下を選択。
    coroutine.sleep(0.5)
    push_keys({"enter"}) -- BCに入る
end

function GreysonFunction(zone, mob)
    -- print("contents/grove.GreysonFunction(", zone, mob, ")")
    for _, item_id in ipairs(M.item_list) do
	if acitem.inventory_has_item(item_id) then
	    acitem.trade_by_item_id(mob, item_id)
	    -- 「これは使用済みっと」
	    coroutine.sleep(5)
	end
    end
end

function M.incoming_text_handler(text)
end

--- 切り替え

M.npc_action_handlers = {
    ["Greyson"] = GreysonFunction,
    ["Burning Circle"] = BurningCircleFunction,
}

return M
