#! /usr/bin/lua

package.path = package.path .. ";../?.lua"
local res_items = require 'res/items'
local utils = require 'utils'
local io_console = require 'io/console'

if #arg < 2 then
    print("Usage: <chara name> <item name substring>")
    print("ex) lua script/findall.lua Upaupa ヘルクリア")
    return 1
end

local chara_name = arg[1]
local keyword = arg[2]

-- print("chara_name:"..chara_name)
local chara_file = 'findAll/data/'..chara_name
local chara_data = require(chara_file)

local bag_name_ja_list = {
    { name='inventory', ja='マイバッグ'},
    { name='safe', ja='モグ金庫'},
    { name='safe2', ja='モグ金庫2'},
    { name='storage', ja= '収納家具'},
    { name='locker', ja='モグロッカー'},
    { name='satchel', ja='モグサッチェル'},
    { name='sack', ja='モグサック'},
    { name='case', ja='モグケース'},
}

table.insert(bag_name_ja_list, {name='wardrobe', ja='モグワードローブ'})

for i = 2, 8 do
    table.insert(bag_name_ja_list, { name='wardrobe'..i,
				     ja='モグワードローブ'..i})
end

table.insert(bag_name_ja_list, { name='recycle', ja='リサイクル' })

for i = 1, 33 do
    local ii = string.format('%02d', i)
    table.insert(bag_name_ja_list, { name='slip '..ii,
				     ja='モグの預り帳【'..ii..'】' })
end

table.insert(bag_name_ja_list, { name='key items', ja='だいじなもの' })
table.insert(bag_name_ja_list, { name='temporary', ja='テンポラリー' })

for _, bag in ipairs(bag_name_ja_list) do
    local bag_name = bag.name
    local bag_name_ja = bag.ja
    local items = chara_data[bag_name]
    for item_id, count in pairs(items) do
	local id = tonumber(item_id)
	local item = res_items[id]
	if item ~= nil then
	    if string.find(item.ja, keyword) ~= nil then
		print(bag_name_ja..": "..item.ja)
	    end
	end
    end
end
