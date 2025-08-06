package.path = package.path .. ";../?.lua"
local utils = require "utils"
local get_keys = utils.table.get_keys
local midangle = utils.angle.midangle

print("get_keys:", get_keys({A="123", X="789"})[2])

for i = 0, 7 do
    local t = 2*math.pi*(i/8)
    print("midangle:", i, t, midangle(t, t + 2*math.pi / 8))
end
