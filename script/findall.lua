#! /usr/bin/lua

local lfs = require('lfs')

package.path = package.path .. ";../?.lua"
local res_items = require 'res/items'
local res_key_items = require 'res/key_items'
local utils = require 'utils'
local io_console = require 'io/console'
local item_vagary = require 'item/vagary'
local item_shishin = require 'item/shishin'

local bag_name_ja_list = {
    { name='inventory', ja='バッグ'},     -- マイバッグ
    { name='safe',      ja='金庫'},       -- モグ金庫
    { name='safe2',     ja='金庫2'},      -- モグ金庫2
    { name='storage',   ja= '収納家具'},
    { name='locker',    ja='ロッカー'},   -- モグロッカー
    { name='satchel',   ja='サッチェル'}, -- モグサッチェル
    { name='sack',      ja='サック'},     -- モグサック
    { name='case',      ja='ケース'},     -- モグケース
}

-- モグワードローブ
table.insert(bag_name_ja_list, {name='wardrobe', ja='ローブ'})
for i = 2, 8 do
    table.insert(bag_name_ja_list, { name='wardrobe'..i,
				     ja='ローブ'..i})
end

table.insert(bag_name_ja_list, { name='recycle', ja='リサイクル' })

--モグの預り帳
for i = 1, 33 do
    local ii = string.format('%02d', i)
    table.insert(bag_name_ja_list, { name='slip '..ii,
				     ja='預り帳['..ii..']' })
end

-- table.insert(bag_name_ja_list, { name='key items', ja='だいじなもの' })
-- table.insert(bag_name_ja_list, { name='temporary', ja='テンポラリー' })

if #arg < 1 then
    print("Usage: <item name substring> [<chara name>]")
    print("ex) lua script/findall.lua ヘルクリア")
    print("ex) lua script/findall.lua ヘルクリア Upaupa ")
    print("ex) lua script/findall.lua Vagary Upaupa ")
    print("ex) lua script/findall.lua Shishin Upaupa ")
    return 1
end

local keyword = arg[1]
local chara_name = arg[2]

local lacking = false

if chara_name ~= nil and chara_name:sub(1,1) == "-" then
    lacking = true
    chara_name = chara_name:sub(2)
end

-- print("keyword:"..keyword.." chara_name:"..tostring(chara_name))

local chara_name_list = {}
local everyone_item_count = {}

function item_match(item_name, kw)
    if kw == 'Vagary' or kw == 'Shishin' then
	local items = item_vagary.drop_items
	if kw == 'Shishin' then
	    items = item_shishin.items
	end
	for _, id in pairs(items) do
	    local item = res_items[id]
	    if item_name == item.ja then
		return true
	    end
	end
    end
    if string.find(item_name, kw) ~= nil then
	return true
    end
    return false
end

function own_item_count(chara_data)
    local count = 0
    local item_ids = {}
    for _, bag in ipairs(bag_name_ja_list) do
	local items = chara_data[bag.name]
	for item_id, count in pairs(items) do
	    local id = tonumber(item_id)
	    local item = res_items[id]
            if item ~= nil then
		if item_match(item.ja, keyword) then
		    if item_ids[id] == nil then
			item_ids[id] = 0
		    end
		    item_ids[id] = item_ids[id] + count
		end
	    end
	end
    end
    return item_ids  -- {[id] = count, ...}
end

for entry in lfs.dir('findAll/data/') do
    local m = entry: match "(%w+).lua$"
    if m then
	if chara_name == nil or string.find(m, chara_name) ~= nil then
	    table.insert(chara_name_list, m)
	end
	if lacking then
	    local chara_file = 'findAll/data/'..m
	    local chara_data = require(chara_file)
	    for _, bag in ipairs(bag_name_ja_list) do
		local items = chara_data[bag.name]
		for item_id, count in pairs(items) do
		    local id = tonumber(item_id)
		    local item = res_items[id]
		    if item_match(item.ja, keyword) then
			if everyone_item_count[id] == nil then
			    everyone_item_count[id] = 0
			end
			everyone_item_count[id] = everyone_item_count[id] + count
		    end
		end
	    end
	end
    end
end

-- for id, count in pairs(everyone_item_count) do print(id, count) end

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

function show_item_and_bag(name, chara_data, kw)
    for _, bag in ipairs(bag_name_ja_list) do
	local bag_name = bag.name
	local bag_name_ja = bag.ja
	local items = chara_data[bag_name]
	for item_id, count in pairs(items) do
	    local id = tonumber(item_id)
	    local item = res_items[id]
	    if item ~= nil then
		if item_match(item.ja, kw) then
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
		string.find(item.ja, kw) ~= nil then
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
function show_lacking_item(name, chara_data, kw)
    local own_items = own_item_count(chara_data, kw)
    for id, count in pairs(everyone_item_count) do
	if count > 3 then
	    if own_items[id] == nil or own_items[id] == 0 then
		local item = res_items[id]
		io_console.printf("%s %s",
				  strspacepad(name, 7), item.ja)
	    end
	end
    end

end

for _, name in ipairs(chara_name_list) do
    local chara_file = 'findAll/data/'..name
    local chara_data = require(chara_file)
    if not lacking then
	show_item_and_bag(name, chara_data, keyword)
    else
	show_lacking_item(name, chara_data, keyword)
    end
end
