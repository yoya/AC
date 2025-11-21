-- 装備関連

local M = {}

local control = require 'control'
local acitem = require 'item'
local io_chat = require 'io/chat'

-- 装束を装着する部位 (slot)
local equip_slots = {
    main = 0, sub = 1, range = 2, ammo = 3,
    head = 4, body = 5, hands = 6, legs = 7, feet = 8,
    neck = 9, waist = 10, left_ear = 11, right_ear = 12,
    left_ring = 13, right_ring = 14, back = 15
}

-- 装束の装着を指定できる bag の種類
local equip_bags = {
    inventory = 0,
    wardrobe = 8,
    wardrobe2 = 10,
    wardrobe3 = 11,
    wardrobe4 = 12,
    wardrobe5 = 13,
    wardrobe6 = 14,
    wardrobe7 = 15,
    wardrobe8 = 16,
}

-- Usage: equip_item("right_ring")
function M.equip_item_by_slot_name(slot_name)
    local items = windower.ffxi.get_items()
    local id = items.equipment[slot_name]  -- bag 内 id
    local bag = items.equipment[slot_name.."_bag"]  -- どの bag か
    local items = windower.ffxi.get_items(bag)
    local item_id = items[id].id
    return item_id
end

local equip_set = {}

-- 装備中の装束を記録する
function M.equip_save(force)
    if force then
	if control.debug then
	    io_chat.setNextColor(6)
	    io_chat.print("equip_save", force)
	end
    end
    local items = windower.ffxi.get_items()
    for name, slot  in pairs(equip_slots) do
	local id = items.equipment[name]  -- bag 内 id
	local bag = items.equipment[name.."_bag"]  -- どの bag か
	if id > 0 then  -- 装備している場合
	    if force then
		equip_set[name] = { inv_id=id, slot=slot, bag=bag }
	    else
		if equip_set[name] == nil then  -- 保存されてない装備だけ
		    equip_set[name] = { inv_id=id, slot=slot, bag=bag }
		end
	    end
	end
    end
end

-- 記録してある装束を装着する
function M.equip_restore()
    if control.debug then
    io_chat.setNextColor(6)
	io_chat.print("equip_restore")
    end
    for name, e in pairs(equip_set) do
	windower.ffxi.set_equip(e.inv_id, e.slot, e.bag)
    end
end

function M.equip_item(slot, item_id)
    bag, inv_id = M.searchEquipItem(item_id)
    -- print("ac/equip", slot, item_id, bag, inv_id)
    windower.ffxi.set_equip(inv_id, slot, bag)
end

function M.searchEquipItem(item_id)
    local items = windower.ffxi.get_items()
    for name, bag_id in pairs(equip_bags) do
	bag = items[name]
	if bag ~= nil then
	    for i, e in ipairs(bag) do
		if e.id == item_id then
		    return equip_bags[name], e.slot
		end
	    end
	end
    end
end

function M.tick(player)
    if player == nil then return end
    if player.status == 1 then
	-- 118 は 妖蟲の髪飾り+1 用に許容する
	if player.item_level >= 118 then
	    M.equip_save(false)
	else
	    M.equip_restore()
	end
    else
	equip_set = {}
    end
end

return M
