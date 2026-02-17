package.path = package.path .. ";../?.lua"
local data = require 'ac/data'

local total = 0
local next_exemplar_table = data.next_exemplar_table
for level = 0, (#next_exemplar_table+1) do
    local nextpt = next_exemplar_table[level]
    print(level, total, nextpt)
    if nextpt == nil then
	break
    end
    total = total + nextpt
end
