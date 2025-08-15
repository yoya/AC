package.path = package.path .. ";../?.lua"
local io_console = require "io/console"
local utils = require "utils"

print("## table test")
local get_keys = utils.table.get_keys
print("get_keys:", get_keys({A="123", X="789"})[2])

print("## angle test")
local midangle = utils.angle.midangle
for i = 0, 7 do
    local t = 2*math.pi*(i/8)
    print("midangle:", i, t, midangle(t, t + 2*math.pi / 8))
end

print("## string test")
local split_multi = utils.string.split_multi
local text = "Upachanのファイターズロール→合計値が5になった！"
local s = split_multi(text, {'の', 'ロール', 'が', 'に'})
io_console.print(s)

local gil_str = utils.string.gil_string(123456)
local gil_str2 = utils.string.gil_string(12345678)
io_console.print(gil_str, gil_str2)
