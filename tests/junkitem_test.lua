package.path = package.path .. ";../?.lua"

local utils = require 'utils'
local io_console = require 'io/console'
-- JunkItems は item/data ではなく item/junk 側にある
local item_junk = require 'item/junk'
local JunkItems = item_junk.JunkItems
io_console.print(JunkItems)
io_console.print(utils.table.contains(JunkItems, 4164))
