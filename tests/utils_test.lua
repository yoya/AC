package.path = package.path .. ";../?.lua"
local utils = require "utils"

print(utils.get_keys({A="123", X="789"})[2])
