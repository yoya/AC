#! /usr/bin/lua

local lfs = require('lfs')

package.path = package.path .. ";../?.lua"
local res_items = require 'res/items'
local res_key_items = require 'res/key_items'
local utils = require 'utils'
local io_console = require 'io/console'

local bag_name_ja_list = {
    -- { name='inventory', ja='マイバッグ'},
    { name='inventory', ja='バッグ'},
    --{ name='safe', ja='モグ金庫'},
--     { name='safe2', ja='モグ金庫2'},
    { name='safe', ja='金庫'},
    { name='safe2', ja='金庫2'},
    { name='storage', ja= '収納家具'},
    --{ name='locker', ja='モグロッカー'},
    --{ name='satchel', ja='モグサッチェル'},
    --{ name='sack', ja='モグサック'},
    --{ name='case', ja='モグケース'},
    { name='locker', ja='ロッカー'},
    { name='satchel', ja='サッチェル'},
    { name='sack', ja='サック'},
    { name='case', ja='ケース'},
}

--table.insert(bag_name_ja_list, {name='wardrobe', ja='モグワードローブ'})
table.insert(bag_name_ja_list, {name='wardrobe', ja='ローブ'})
for i = 2, 8 do
    table.insert(bag_name_ja_list, { name='wardrobe'..i,
				     ja='ローブ'..i})
				     -- ja='モグワードローブ'..i})
end
table.insert(bag_name_ja_list, { name='recycle', ja='リサイクル' })
for i = 1, 33 do
    local ii = string.format('%02d', i)
    table.insert(bag_name_ja_list, { name='slip '..ii,
				     ja='預り帳['..ii..']' })
				     -- ja='モグの預り帳【'..ii..'】' })
end
-- table.insert(bag_name_ja_list, { name='key items', ja='だいじなもの' })
-- table.insert(bag_name_ja_list, { name='temporary', ja='テンポラリー' })

if #arg < 1 then
    print("Usage: <item name substring> [<chara name>]")
    print("ex) lua script/findall.lua ヘルクリア")
    print("ex) lua script/findall.lua ヘルクリア Upaupa ")
    return 1
end

local keyword = arg[1]
local chara_name = arg[2]

-- print("keyword:"..keyword.." chara_name:"..tostring(chara_name))

local chara_name_list = {}

for entry in lfs.dir('findAll/data/') do
    local m = entry: match "(%w+).lua$"
    if m then
	if chara_name == nil or string.find(m, chara_name) ~= nil then
	    table.insert(chara_name_list, m)
	end
    end
end

function strspacepad(s, n)
    local l = string.len(s)
    while l < n do
	s = s..' '
	l = l + 1
    end
    return s
end

local key_items_category_list = {
    {name='Temporary Key Items', name2="一時"},
    {name='Permanent Key Items', name2="継続"},
    {name='Abyssea', name2='アビセア'},
    {name='Voidwatch', name2='VW'},
    {name='Geas Fete', name2='ギアス'},
    {name='Mounts', name2='mount'},
    {name='Mog Garden', name2='garden'},
    {name='Magical Maps', name2='地図'},
    {name='Claim Slips', name2='預り証'},
    {name='Active Effects', name2="応援"},
}

for _, name in ipairs(chara_name_list) do
    local chara_file = 'findAll/data/'..name
    local chara_data = require(chara_file)
    for _, bag in ipairs(bag_name_ja_list) do
	local bag_name = bag.name
	local bag_name_ja = bag.ja
	local items = chara_data[bag_name]
	for item_id, count in pairs(items) do
	    local id = tonumber(item_id)
	    local item = res_items[id]
	    if item ~= nil then
		if string.find(item.ja, keyword) ~= nil then
		    local count_str = ""
		    if count > 1 then
			count_str = "("..count..")"
		    end
		    io_console.printf("%s %s %s%s",
				      strspacepad(name, 7),
				      strspacepad(bag_name_ja, 12),
				      item.ja, count_str)
		end
	    end
	end
    end
    for _, key_item_category in ipairs(key_items_category_list) do
	local items = chara_data['key items']
	for item_id, count in pairs(items) do
	    local id = tonumber(item_id)
	    local item = res_key_items[id]
	    -- print(item.id, item.ja, item.category)
	    if item.category == key_item_category.name and
		string.find(item.ja, keyword) ~= nil then
		-- だいじと()をまとめた文字列に対して pad かけたいので。
		-- あらかじめ一つの文字列にする
		local name_with_category = string.format(
		    'だいじ(%s)',
		    key_item_category.name2
		)
		io_console.printf("%s %s %s",
				  strspacepad(name, 7),
				  strspacepad(name_with_category, 12),
				  item.ja)
	    end
	end
    end
end
