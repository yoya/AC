#! /usr/bin/lua

local lfs = require('lfs')
local json = require('cjson')

function table_union(t1, t2)
    local t = {}
    for k, v in pairs(t1) do
	t[k] = v
    end
    for k, v in pairs(t2) do
	if t[k] == nil then
	    t[k] = v
	else
	    -- print("Warning: duplicate key:"..k.." v:"..v)
	end
    end
    return t
end

function table_diff(t1, t2)
    local t = {}
    for k, v in pairs(t1) do
	if t2[k] == nil then
	    t[k] = v
	end
    end
    return t
end

function get_ordered_key_array(t)
    local a = {}
    for k, v in pairs(t) do
	table.insert(a, k)
    end
    table.sort(a, function(a, b) return tonumber(a) < tonumber(b) end)
    return a
end

function usage()
    print("Usage: ./spell.lua <spell type> <chara name>")
    print("    ./spell.lua trust  # lack of trust(face)")
end

if #arg ~= 2 then
    usage()
    os.exit (1)
end

local spell_type = arg[1]
local chara_name = arg[2]

path = debug.getinfo(1,"S").source:sub(2)
local dirname, filename = path:match('^(.*/)([^/]-)$')

-- print("spell_type:"..spell_type, "chara_name:"..chara_name, "dirname:"..dirname)


local files = {}
for entry in lfs.dir(dirname) do
    if entry: match "%-spells.json$" then
	table.insert(files, entry)
    end
end

local all_spell_table = {}

for i, file in ipairs(files) do
    -- print("file:"..file)
    local f = io.input(dirname..file);
    local text = f:read("*all")
    local data = json.decode(text)
    all_spell_table = table_union(all_spell_table, data[spell_type])
    io.close(f)
end

for i, file in ipairs(files) do
    if string.find(file, chara_name) then
	print("==== "..file)
	local f = io.input(dirname..file);
	local text = f:read("*all")
	local data = json.decode(text)
	spell_table = table_diff(all_spell_table, data[spell_type])	
	--for k, v in pairs(spell_table) do
	--    print(k, v)
	--end
	local spell_keys = get_ordered_key_array(spell_table)
	for i, k in pairs(spell_keys) do
	    local v = spell_table[k]
	    print(k, v)
	end
	io.close(f)
    end
end

os.exit (0)
