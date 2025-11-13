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
    print("Usage: ./show.lua <l|p|a|d> <num>")
    print("    ./show.lua l 4 # latest 4 entries")
    print("    ./show.lua p   # point(eminence&unity)")
    print("    ./show.lua e   # point(eminence)")
    print("    ./show.lua p 4 # point(ambus)")
    print("    ./show.lua d 4 # point(dp|mogseg|gallimau)")
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

path = debug.getinfo(1,"S").source:sub(2)
local dirname, filename = path:match('^(.*/)([^/]-)$')
local savedDir = dirname.."/../saved/"

local files = {}
for entry in lfs.dir(savedDir) do
    if entry: match "%.txt$" then
	table.insert(files, entry)
    end
end

-- print("method:"..method.." num:"..num.." files:"..files[1].."...(num:"..#files..")")

local charTable = {}

for i, file in ipairs(files) do
    -- print("file:"..file)
    local f = io.open(savedDir..file)
    if f == nil then
	print("Can't open file:"..savedDir..file)
	exit(1)
    end
    -- 一行目
    local line1 = f:read()
    local table1 = split_multi(line1, {" "})
    local name = table1[1]
    -- 二行目
    local line2 = f:read()
    local line3 = f:read()
    local line4 = f:read()
    local eminence_point = -1
    local unity_point = -1
    local gil = -1
    local hallmark = -1
    local total_hallmark = -1
    local gallantry = -1
    local domain_point = -1
    local mog_segments = -1
    local gallimaufry = -1
    if line2 ~= nil then
	local table2 = split_multi(line2, {"Eminence:", "  Unity:", "  Gil:"})
	if table2 ~= nil then
	    eminence_point = tonumber(table2[2])
	    unity_point = tonumber(table2[3])
	    gil = table2[4]
	end
    end
    if line3 ~= nil then
	local table3 = split_multi(line3, {"Hallmark:", "  Total:", "  Gallantry:"})
	if table3 ~= nil then
	    hallmark = tonumber(table3[2])
	    total_hallmark = tonumber(table3[3])
	    gallantry = tonumber(table3[4])
	end
    end
    if line4 ~= nil then
	local table4 = split_multi(line4, {"DomainP:", "  MogSeg:", "  Gallimau:"})
	if table4 ~= nil then
	    domain_point = tonumber(table4[2])
	    mog_segments = tonumber(table4[3])
	    gallimaufry = tonumber(table4[4])
	end
    end
local time, err = lfs.attributes(savedDir..file, 'modification')
    -- print(name, eminence_point, unity_point, time)
    local char  = {
	line1 = line1,
	line2 = line2,
	name = name,
	eminence_point = eminence_point,
	unity_point = unity_point,
	gil = gil,
	hallmark = hallmark,
	total_hallmark = total_hallmark,
	gallantry = gallantry,
	domain_point = domain_point,
	mog_segments = mog_segments,
	gallimaufry = gallimaufry,
	--
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

function compAmbus(a, b)
    if (a.hallmark + a.gallantry) < (b.hallmark + b.gallantry) then
	return true
    else
	return false
    end
end

function compDomain(a, b)
    if (a.domain_point + a.mog_segments + a.gallimaufry) <  (b.domain_point + b.mog_segments + b.gallimaufry) then
	return true
    else
	return false
    end
end

if method == 'l' then
    table.sort(charTable, function(a,b) return a.time > b.time end)
elseif method == 'e' then
    table.sort(charTable, function(a,b) return a.name > b.name end)
elseif method == 'p' then
    table.sort(charTable, compPoint)
elseif method == 'a' then
    table.sort(charTable, compAmbus)
elseif method == 'd' then
    table.sort(charTable, compDomain)
else
    print("Unknown method:"..method)
    os.exit(1)
end

charTable = array_slice(charTable, 1, num)

if method == 'l' or method == 'e' then
    table.sort(charTable, function(a,b) return a.name < b.name end)
end

total_gil = 0

for i, char in pairs(charTable) do
    local gil_str = string.gsub(char.gil, ',', '')
    gil_num = tonumber(gil_str)
    if gil_num ~= nil and gil_num > 0 then
	total_gil = total_gil + gil_num
    end
    if method == 'l' then
	print(char.line1)
	print(string.format("  Emi:%5s Uni:%5s Gil:%11s", char.eminence_point, char.unity_point, char.gil))
    elseif method == 'e' then
	print(char.line1)
    elseif method == 'p' then
	print(string.format("%7s Emi:%5s Uni:%5s Gil:%11s", char.name, char.eminence_point, char.unity_point, char.gil))
    elseif method == 'a' then
	print(string.format("%7s HM:%5s Total:%5s Gal:%5s", char.name, char.hallmark, char.total_hallmark, char.gallantry))
    elseif method == 'd' then
	print(string.format("%7s DP:%5s MogS:%5s GF:%5s", char.name, char.domain_point, char.mog_segments, char.gallimaufry))
    else
	print("Error: Wrong method:"..method)
    end
end

if method == 'p' then
    local gil3 = utils.string.gil_string(total_gil)
    local gil4 = utils.string.gil_string(total_gil, '_', 4)
    print(string.format("Total Gil:%11s(=%11s)", gil3, gil4))
end

os.exit (0)
