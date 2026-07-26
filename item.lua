--- アイテム処理

local packets = require('packets')
local res = require('resources')
local command = require('command')
local io_chat = require('io/chat')
local task = require('task')
local control = require('control')
local utils = require 'utils'

local M = {
    data = require 'item/data',
    junk = require 'item/junk',
    vagary = require 'item/vagary',
    shishin = require 'item/shishin',
}

-- 金庫系のkeyリスト
local SafesList = { locker = 4, storage = 2, safe = 1 }
-- ちなみに 3 は Temporary
--- 持ち歩きバッグのkeyリスト
local BagsList = { case = 7, sack = 6, satchel = 5 }

local WardrobeList = { wardrobe = 8, wardrobe2 = 10,
		       wardrobe3 = 11, wardrobe4 = 12,
		       wardrobe5 = 13, wardrobe6 = 14,
		       wardrobe7 = 15, wardrobe8 = 16 }

local bag_name_ja_list = {
    { name='inventory', ja='バッグ'},
    { name='safe', ja='金庫'},
    { name='safe2', ja='金庫2'},
    { name='storage', ja= '収納家具'},
    { name='locker', ja='ロッカー'},
    { name='satchel', ja='サッチェル'},
    { name='sack', ja='サック'},
    { name='case', ja='ケース'},
}

-- アイテムの量

local inventory_total_num = function()
    local items = windower.ffxi.get_items()
    local item = items.inventory
    local totalNum = 0
    for i, e in ipairs(item) do
        totalNum = totalNum + e.count
    end
    return totalNum
end
M.inventory_total_num = inventory_total_num

function M.inventory_count_by_item_id(item_id)
    local items = windower.ffxi.get_items()
    local item = items.inventory
    local totalNum = 0
    for i, e in ipairs(item) do
	if e.id == item_id then
	    totalNum = totalNum + e.count
	end
    end
    return totalNum
end

function M.inventory_count_by_item_ids(item_ids)
    local totalNum = 0
    for _, item_id in ipairs(item_ids) do
	totalNum = totalNum + M.inventory_count_by_item_id(item_id)
    end
    return totalNum
end

local prevInventoryTotalNum = inventory_total_num()
local diff_inventory_total_num = function()
    local next = inventory_total_num()
    local diff = next - prevInventoryTotalNum
    prevInventoryTotalNum = next
    return diff
end
M.diff_inventory_total_num = diff_inventory_total_num

--- アイテムの空き
M.show_inventory = function()
    local items = windower.ffxi.get_items()
    local item = items.inventory
    for i, e in ipairs(item) do
        if e.count > 0 then
            io_chat.print("count:" .. e.count .. " id:" .. e.id)
        end
    end
end

M.check_inventory_freespace = function()
    local items = windower.ffxi.get_items()
    
    local item = items.inventory
    if item.count < item.max then
        return true
    end
    return false
end

--- かばんの空き数
local inventory_freespace_num = function()
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    return inventory.max - inventory.count
end
M.inventory_freespace_num = inventory_freespace_num

local safes_to_inventory = function(id)
---    print("safesToInventry")
    local count = 0
    for bname, bagid in pairs(SafesList) do
	local items = windower.ffxi.get_items()
	local inventory = items.inventory
        if inventory.count < inventory.max then
            local bag = items[bname]
            for i, item in ipairs(bag) do
                if item.id == id then
                    windower.ffxi.get_item(bagid, item.slot, item.count)
		    count = count + 1
                end
            end
        else
            return count
        end
    end
    return count
end
M.safes_to_inventory = safes_to_inventory

function M.safes_to_inventory_by_set(id_set)
    -- print("safes_to_inventory_by_set")
    local count = 0
    for bname, bagid in pairs(SafesList) do
        local items = windower.ffxi.get_items()
        local inventory = items.inventory
        if inventory.count < inventory.max then
            local bag = items[bname]
            for i, item in ipairs(bag) do
                if id_set[item.id] == true and item.count > 0 then
		    if M.check_inventory_freespace() then
			windower.ffxi.get_item(bagid, item.slot, item.count)
			count = count + 1
			if control.debug then
			    local item_name = "unknown item"
			    if res.items[item.id] ~= nil then
				item_name = res.items[item.id].name
			    end
			    io_chat.printf("safes_to_inventory:%s %s(%d)", bname, item_name, item.id)
			end
		    end
                end
            end
	else
	    return count
	end
    end
    return count
end

--- 持ち歩きバッグの空き
local check_bags_freespace = function()
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(BagsList) do
        local bag = items[bname]
        if bag.count < bag.max then
            return true
        end
    end
    return false
end
M.check_bags_freespace = check_bags_freespace

local bags_to_inventory = function(id)
---    print("bags_to_inventory")
    local count = 0
    for bname, bagid in pairs(BagsList) do
        local items = windower.ffxi.get_items()
        local inventory = items.inventory
        if inventory.count < inventory.max then
            local bag = items[bname]
            for i, item in ipairs(bag) do
                if item.id == id then
                    windower.ffxi.get_item(bagid, item.slot, item.count)
		    count = count + 1
		    if control.debug then
			local item_name = "unknown item"
			if res.items[item.id] ~= nil then
			    item_name = res.items[item.id].name
			end
			io_chat.printf("bags_to_inventory:%s %s(%d)", bname, item_name, item.id)
		    end
                end
            end
        else
            return count
        end
    end
    return count
end
M.bags_to_inventory = bags_to_inventory

function M.bags_to_inventory_by_set(id_set)
    -- print("bags_to_inventory_by_set")
    local count = 0
    for bname, bagid in pairs(BagsList) do
        local items = windower.ffxi.get_items()
        local inventory = items.inventory
        if inventory.count < inventory.max then
            local bag = items[bname]
            for i, item in ipairs(bag) do
                if id_set[item.id] == true and item.count > 0 then
		    if M.check_inventory_freespace() then
			windower.ffxi.get_item(bagid, item.slot, item.count)
			count = count + 1
		    end
                end
            end
	else
	    return count
        end
    end
    return count
end

M.move_to_bags = function(id)
---    print("move_to_bags")
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(BagsList) do
        local bag = items[bname]
        if bag.count < bag.max then
            for i, item in ipairs(items.inventory) do
                --- 1D揃ったらバッグに退避
                if item.id == id and item.count == 12 then
                    windower.ffxi.put_item(bagid, item.slot, item.count)
                    return true
                end
            end
        end
    end
end

local inventory_has_item = function(id)
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    for i, item in ipairs(inventory) do
        if item.id == id then
            return true
        end
    end
    return false
end
M.inventory_has_item = inventory_has_item

function M.inventory_has_item_in_set(id_set)
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    for i, item in ipairs(inventory) do
        if id_set[item.id] == true then
            return true
        end
    end
    return false
end

M.safes_has_item = function(id)
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(SafesList) do
        local bag = items[bname]
        for i, item in ipairs(bag) do
            if item.id == id then
                return true
            end
        end
    end
    return false
end

M.safes_has_item_in_set = function(id_set)
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(SafesList) do
        local bag = items[bname]
        for i, item in ipairs(bag) do
            if id_set[item.id] == true then
                return true
            end
        end
    end
    return false
end

M.bags_has_item = function(id)
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(BagsList) do
        local bag = items[bname]
        for i, item in ipairs(bag) do
            if item.id == id then
                return true
            end
        end
    end
    return false
end

M.bags_has_item_in_set = function(id_set)
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(BagsList) do
        local bag = items[bname]
        for i, item in ipairs(bag) do
            if id_set[item.id] == true then
                return true
            end
        end
    end
    return false
end

M.wardrobe_has_item = function(id)
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(WardrobeList) do
	-- print("item.wardrobe_has_item", bname, bagid)
        local bag = items[bname]
        for i, item in ipairs(bag) do
            if item.id == id then
                return true
            end
        end
    end
    return false
end

M.wardrobe_has_item_in_set = function(id_set)
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(WardrobeList) do
        local bag = items[bname]
        for i, item in ipairs(bag) do
            if id_set[item.id] == true then
                return true
            end
        end
    end
    return false
end

M.trade_by_item_id = function(mob, id)
---    print("trade_by_item_id", mob, id)
    if mob == nil then
        print("trade_by_item_id: mob not found. id:"..tostring(id))
        return false
    end
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    local ind = {}
    local cnt = {}
    for i, item in ipairs(inventory) do
        if item.id == id and #ind < 8 then
            ind[#ind+1] = i
            cnt[#cnt+1] = item.count
        end
    end
    local num = #ind
    if num == 0 then
	io_chat.warnf("you have not item id:%d", id)
	return
    end
    for i = num+1, 8 do
        ind[#ind+1] = 0
        cnt[#cnt+1] = 0
    end
--    for i, index in ipairs(ind) do
--        local item = inventory[index]
--    end
    if #ind > 0 then
        local menu_item = ('C4I11C10HI'):pack(0x36,0x20,0x00,0x00,mob.id,
               cnt[1],cnt[2],cnt[3],cnt[4],cnt[5],cnt[6],cnt[7],cnt[8],0,0x00,
               ind[1],ind[2],ind[3],ind[4],ind[5],ind[6],ind[7],ind[8],0,0x00,
               mob.index,num)
        windower.packets.inject_outgoing(0x36, menu_item)
    end
    return true
end

-- item_table = { { item_id = count }, ... }
M.trade_by_item_table = function(mob, item_table)
---    print("trade_by_item_table", mob, item_table)
    if mob == nil then
        print("trade_by_item_table: mob not found")
        return false
    end
    item_table = utils.table.deepclone(item_table)  -- 非破壊的にする
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    local ind = {}
    local cnt = {}
    for i, item in ipairs(inventory) do
	local c = item_table[item.id]  -- item count
        if c ~= nil and c > 0 and item.count > 0 then
	    if item.count < c then
		c = item.count
	    end
	    if #ind < 8 then
		ind[#ind+1] = i
		cnt[#cnt+1] = c
		item_table[item.id] = item_table[item.id] - c
	    end
        end
    end
    local num = #ind
    if num == 0 then
	io_chat.warn("you have not item", item_table)
	return
    end
    for i = num+1, 8 do
        ind[#ind+1] = 0
        cnt[#cnt+1] = 0
    end 
--    for i, index in ipairs(ind) do
--        local item = inventory[index]
--    end
    if #ind > 0 then
        local menu_item = ('C4I11C10HI'):pack(0x36,0x20,0x00,0x00,mob.id,
               cnt[1],cnt[2],cnt[3],cnt[4],cnt[5],cnt[6],cnt[7],cnt[8],0,0x00,
               ind[1],ind[2],ind[3],ind[4],ind[5],ind[6],ind[7],ind[8],0,0x00,
               mob.index,num)
        windower.packets.inject_outgoing(0x36, menu_item)
    end
    return true
end

-- アイテムの使用。スクロールの学習など
M.use_item_include_bags = function(item_id, duration)
    if duration == nil then
	duration = 5
    end
    local ret = false
    if check_bags_freespace(item_id) then
        bags_to_inventory(item_id)
    end
    if inventory_has_item(item_id) then
        local name = res.items[item_id].name
	local c = 'input /item '..name..' <me>'
	task.set_task_simple(c, 0, duration)
        ret = true
        coroutine.sleep(duration)
    end
    return ret
end

-- use_equip_item(14, 28540, 'デジョンリング', 9)
-- 右指にデジョンリングをつけて使用

local EQUIP_ITEM_BANK_KEY = 'use_equip_item'

function M.use_equip_item(slot, item_id, item_name, delay)
    local ac_equip = require('ac/equip')
    local task = require('task')
    task.all_clear() -- 他タスクが邪魔しないよう全消去
    ac_equip.equip_save(EQUIP_ITEM_BANK_KEY) -- 今の装備を記録
    coroutine.sleep(1)
    ac_equip.equip_item(slot, item_id)  -- 装備する
    windower.ffxi.run(false) -- 足を止める
    coroutine.sleep(delay + 1)  -- delay ぴったりだと50%程度失敗する
    local c = "input /item "..item_name.." <me>"
    -- command, delay, duration
    task.set_task_simple(c, 0, 5)  -- delay が信用できないので一旦 sleep で。
    coroutine.sleep(2)
    ac_equip.equip_restore(EQUIP_ITEM_BANK_KEY)  -- 前の装備に戻す
    -- coroutine.sleep(2)
    -- ac_equip.equip_restore(EQUIP_ITEM_BANK_KEY)
end

function M.use_equip_item_sequence(slot, item_list, delay)
    for _, item in ipairs(item_list) do
	local id = item.id
	if M.inventory_has_item(id) or M.wardrobe_has_item(id)  then
	    io_chat.print("use_equip_item_sequence", id, item.name)
	    M.use_equip_item(slot, id, item.name, delay)
	end
    end
end

function M.show_own_items(item_list)
    io_chat.info("=== Important Items I have ===")
    local items = windower.ffxi.get_items()
    for i, item_id in ipairs(item_list) do
	local name = res.items[item_id].name
	local line = string.format("[%d] %s:", item_id, name)
	for _, bag in ipairs(bag_name_ja_list) do
	    local bag_name = bag.name
	    local bag_name_ja = bag.ja
	    local bag = items[bag_name]
	    for _, b in ipairs(bag) do
		if b.id == item_id and b.count > 0 then
		    line = string.format("%s %s(%d)", line, bag_name_ja, b.count)
		end
	    end
        end
	io_chat.print(line)
    end
end

function M.show_own_key_items(key_item_list)
    io_chat.info("=== Important Key Items I have ===")
    local key_items = windower.ffxi.get_key_items()
    for i, key_item_id in ipairs(key_item_list) do
	local name = res.key_items[key_item_id].name
	local line = string.format("[%d] %s:", key_item_id, name)
	for _, id in ipairs(key_items) do
	    if key_item_id == id then
		line = string.format("%s 有", line)
	    end
	end
	io_chat.print(line)
    end
end

return M
