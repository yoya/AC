#! /usr/bin/lua

local lfs = require('lfs')

package.path = package.path .. ";../?.lua"
local utils = require('utils')
local split_multi = utils.string.split_multi

function array_slice(arr, i1, i2)
    local a = {}
    for i = i1, i2 do
	a[i-i1+1] = arr[i]
    end
    return a
end

function usage()
    print("Usage: ./show.lua <order> <num>")
    print("    ./show.lua l 4 # latest 4 entries")
    print("    ./show.lua p 4 # point(eminence&unity ) least 4 entries")
end

function parseArgs()
    if #arg == 0 then
	return nil
    end
    local a1 = arg[1]
    local a2 = (#arg == 2) and tonumber(arg[2]) or 99999
    return a1, a2
end

local method, num = parseArgs()

if method == nil then
    usage()
    os.exit (1)
end

local files = {}
for entry in lfs.dir(".") do
    if entry: match "%.txt$" then
	table.insert(files, entry)
    end
end

-- print("method:"..method.." num:"..num.." files:"..files[1].."...(num:"..#files..")")

local charTable = {}

for i, file in ipairs(files) do
    -- print("file:"..file)
    local f = io.open(file)
    -- 一行目
    local line1 = f:read()
    local table1 = split_multi(line1, {" "})
    local name = table1[1]
    -- 二行目
    local line2 = f:read()
    local eminence_point = -1
    local unity_point = -1
    local gil = -1
    if line2 ~= nil then
	local table2 = split_multi(line2, {"Eminence:", "  Unity:", "  Gil:"})
	if table2 ~= nil then
	eminence_point = tonumber(table2[2])
	unity_point = tonumber(table2[3])
	gil = table2[4]
	elseif table2 == nil then
	    table2 = split_multi(line2, {"Eminence:", "  Unity:"})
	    eminence_point = tonumber(table2[2])
	    unity_point = tonumber(table2[3])
	    gil = -1
	end
    end
    local time, err = lfs.attributes(file, 'modification')
    -- print(name, eminence_point, unity_point, time)
    local char  = {
	line1 = line1,
	line2 = line2,
	name = name,
	eminence_point = eminence_point,
	unity_point = unity_point,
	gil = gil,
	time = time,
    }
    charTable[i] = char
end

function compPoint(a, b)
--    print(a.eminence_point.." < "..b.eminence_point)
    if (a.eminence_point + a.unity_point) < (b.eminence_point+ b.unity_point) then
	return true
    else
	return false
    end
end

if method == 'p' then
    table.sort(charTable, compPoint)
elseif method == 'l' then
    table.sort(charTable, function(a,b) return a.time > b.time end)
else
    print("Unknown method:"..method)
    os.exit(1)
end

charTable = array_slice(charTable, 1, num)


if method == 'l' then
    table.sort(charTable, function(a,b) return a.name < b.name end)
end

for i, char in pairs(charTable) do
    if method == 'p' then
	print(char.name.." E:"..char.eminence_point.." U:"..char.unity_point.." G:"..char.gil)
    else
	print("  "..char.line1)
	print(char.line2)
    end
end

os.exit (0)

