--- アイテム処理

local packets = require('packets')
local res = require('resources')
local command = require('command')

local M = {}

-- アイテムの量

local inventoryTotalNum = function()
    local items = windower.ffxi.get_items()
    local item = items.inventory
    local totalNum = 0
    for i, e in ipairs(item) do
        totalNum = totalNum + e.count
    end
    return totalNum
end
M.inventoryTotalNum = inventoryTotalNum

local prevInventoryTotalNum = inventoryTotalNum()
local diffInventoryTotalNum = function()
    local next = inventoryTotalNum()
    diff = next - prevInventoryTotalNum 
    prevInventoryTotalNum = next
    return diff
end
M.diffInventoryTotalNum = diffInventoryTotalNum

--- アイテムの空き
M.showInventory = function()
    local items = windower.ffxi.get_items()
    local item = items.inventory
    for i, e in ipairs(item) do
        if e.count > 0 then
            printChat("count:" .. e.count .. " id:" .. e.id)
        end
    end
end

M.checkInventoryFreespace = function()
    local items = windower.ffxi.get_items()
    
    local item = items.inventory
    if item.count < item.max then
        return true
    end
    return false
end

--- かばんの空き数
local inventoryFreespaceNum = function()
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    return inventory.max - inventory.count
end
M.inventoryFreespaceNum = inventoryFreespaceNum



-- 金庫系のkeyリスト
local SafesList = { locker = 4, storage = 2, safe = 1 }
-- ちなみに 3 は Temporary
--- 持ち歩きバッグのkeyリスト
local BagsList = { case = 7, sack = 6, satchel = 5 }



local safesToInventory = function(id)
---    print("safesToInventry")
    local result = false
    for bname, bagid in pairs(SafesList) do
        local items = windower.ffxi.get_items()
        local inventory = items.inventory
        if inventory.count < inventory.max then
            local bag = items[bname]
            for i, item in ipairs(bag) do
                if item.id == id then
                    windower.ffxi.get_item(bagid, item.slot, item.count)
                    result = true
                end
            end
        else
            return true
        end
    end
    return result
end
M.safesToInventory = safesToInventory


--- 持ち歩きバッグの空き
local checkBagsFreespace = function()
    local items = windower.ffxi.get_items()
    for bname, bagid in pairs(BagsList) do
        local bag = items[bname]
        if bag.count < bag.max then
            return true
        end
    end
    return false
end
M.checkBagsFreespace = checkBagsFreespace

local bagsToInventory = function(id)
---    print("bagsToInventory")
    local result = false
    for bname, bagid in pairs(BagsList) do
        local items = windower.ffxi.get_items()
        local inventory = items.inventory
        if inventory.count < inventory.max then
            local bag = items[bname]
            for i, item in ipairs(bag) do
                if item.id == id then
                    windower.ffxi.get_item(bagid, item.slot, item.count)
                    result = true
                end
            end
        else
            return true
        end
    end
    return result
end
M.bagsToInventory = bagsToInventory

M.moveToBags = function(id)
---    print("moveToBags")
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

local inventoryHasItem = function(id)
    local items = windower.ffxi.get_items()
    local inventory = items.inventory
    for i, item in ipairs(inventory) do
        if item.id == id then
            return true
        end
    end
    return false
end
M.inventoryHasItem = inventoryHasItem

M.safesHasItem = function(id)
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

M.bagsHasItem = function(id)
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

M.tradeByItemId = function(mob, id)
---    print("tradeByItemId", target, id)
    if mob == nil then
        print("tradeByItemId: target:"..#target.." not found")
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
    num = #ind
    for i = num+1, 8 do
        ind[#ind+1] = 0
        cnt[#cnt+1] = 0
    end 
    for i, index in ipairs(ind) do
        local item = inventory[index]
    end
    if #ind > 0 then
        local menu_item = 'C4I11C10HI':pack(0x36,0x20,0x00,0x00,mob.id,
               cnt[1],cnt[2],cnt[3],cnt[4],cnt[5],cnt[6],cnt[7],cnt[8],0,0x00,
               ind[1],ind[2],ind[3],ind[4],ind[5],ind[6],ind[7],ind[8],0,0x00,
               mob.index,num)
        windower.packets.inject_outgoing(0x36, menu_item)
    end
    return true
end

M.useItemIncludeBags = function(item_id)
    local ret = false
    if checkBagsFreespace(item_id) then
        bagsToInventory(item_id)
    end
    if inventoryHasItem(item_id) then
        local name = res.items[item_id].name
	command.send('input /item '..name..' <me>')
        ret = true
        coroutine.sleep(math.random(3,4))
    end
    return ret
end

return M

