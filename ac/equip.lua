-- 装備関連

local M = {}

local res = require 'resources'

local utils = require 'utils'
local control = require 'control'
local acitem = require 'item'
local acitem_data = require 'item/data'
local io_chat = require 'io/chat'

-- 装束を装着する部位 (slot)
local equip_slots = {
    main = 0, sub = 1, range = 2, ammo = 3,
    head = 4, body = 5, hands = 6, legs = 7, feet = 8,
    neck = 9, waist = 10, left_ear = 11, right_ear = 12,
    left_ring = 13, right_ring = 14, back = 15
}
local equip_slots_keys = utils.table.swap_key_value_table(equip_slots)

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
local equip_bags_keys = utils.table.swap_key_value_table(equip_bags)

-- Usage: equip_item("right_ring")
function M.equip_item_by_slot_name(slot_name)
    local items = windower.ffxi.get_items()
    local id = items.equipment[slot_name]  -- bag 内 id
    local bag = items.equipment[slot_name.."_bag"]  -- どの bag か
    local items = windower.ffxi.get_items(bag)
    if items[id] == nil then
	print("Error: id:"..id.."bag:"..bag)
    end
    if items[id] == nil then
	return nil
    end
    local item_id = items[id].id  --(items[id] が nilのエラーが出た事がある)
    return item_id
end

local equip_set = {}
local equip_set_bank = {}

-- 装備中の装束を記録する
function M.equip_save(arg)
    --    if control.debug then
    if control.debug then
	if arg == nil then
	    -- 表示が多すぎるので arg 指定なしは表示一旦なし
	    -- io_chat.noticef("equip_save:nil", arg)
	else
	    io_chat.noticef("equip_save:%s", arg)
	end
    end
    if arg ~= nil and equip_set_bank[arg] == nil then
	equip_set_bank[arg] = {}
    end
    local items = windower.ffxi.get_items()
    for name, slot  in pairs(equip_slots) do
	local inv_id = items.equipment[name]  -- bag 内 id
	local bag = items.equipment[name.."_bag"]  -- どの bag か
	if inv_id > 0 then  -- 装備している場合
	    local equip_item = { inv_id=inv_id, slot=slot, bag=bag }
	    if arg == nil then
		equip_set[name] = equip_item
	    else
		equip_set_bank[arg][name] = equip_item
	    end
	end
    end
    if control.debug then
	M.equip_show(arg)
    end
end

-- 記録してある装束を装着する
function M.equip_restore(arg)
    if control.debug then
	io_chat.noticef("equip_restore:%s", arg)
    end
    local main_weapon_item_id = M.equip_item_by_slot_name("main")
    if acitem_data.trialWeaponT[main_weapon_item_id] == true then
	return -- トライアル武器はそのまま維持
    end
    if control.debug then
	M.equip_show(arg)
    end
    local _equip_set = equip_set
    if arg ~= nil then
	if equip_set_bank[arg] == nil then
	    io_chat.errorf("equip_restore: no bank: %s", arg)
	    return
	end
	_equip_set = equip_set_bank[arg]
    end
    for name, e in pairs(_equip_set) do
	windower.ffxi.set_equip(e.inv_id, e.slot, e.bag)
    end
end

function M.equip_show(arg)
    local _equip_set = equip_set
    if arg ~= nil then
	if equip_set_bank[arg] == nil then
	    io_chat.errorf("equip_restore: no bank: %s", arg)
	    return
	end
	_equip_set = equip_set_bank[arg]
    end
    for name, e in pairs(_equip_set) do
	local slot_name = equip_slots_keys[e.slot]
	local bag_name = equip_bags_keys[e.bag]
	local items = windower.ffxi.get_items()
	local bag_items = items[bag_name]
	local item = bag_items[e.inv_id]
	local item_ja = res.items[item.id].ja
	io_chat.printf("%s %s %s", slot_name, bag_name, item_ja)
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
	    M.equip_save()
	else
	    M.equip_restore()
	end
    else
	-- equip_set = {}
    end
end

return M
