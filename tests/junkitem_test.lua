package.path = package.path .. ";../?.lua"

local utils = require 'utils'
local io_console = require 'io/console'
local item_data = require 'item/data'
local JunkItems = item_data.JunkItems
io_console.print(JunkItems)
io_console.print(utils.table.contains(JunkItems, 4164))
