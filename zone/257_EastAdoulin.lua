-- 東アドゥリン

local M = { id = 257 }

local io_chat = require 'io/chat'
local acpos = require 'pos'

M.routes = {
    -- HP#2(M)
    moghouse = {
	-- {x=-50.5,y=-95,z=-0.1}, {x=-54,y=-100},
	{x=-50.5,y=-95,z=-0.1}, {x=-55,y=-101},
	{x=-56,y=-109}, {}
    },
    -- SCT
    sct = {
	{x=-77.9,y=-63.9,z=-0.2}, {x=-109,y=-56.8},
	{x=-111.6,y=-54.2}, {x=-112.7,y=-48.9}, {a="f8touch"}
    },
    sctwp = {
	{x=-97.4,y=-51}, {x=-112.7,y=-48.9},
	{x=-111.6,y=-54.2},
	{x=-109,y=-56.8}, {x=-77.9,y=-63.9},
	{a="f8touch"}
    },
    -- pck??
    f7rala = {
	{x=-101.3,y=-10.7,z=-0.1}, {x=-111.8,y=-1.6,z=0},
	{x=-123.5,y=4.2,z=0}, {x=-126.2,y=60.1,z=0},
	{x=-129,y=60.2,z=0.1}, {x=-130,y=57.3,z=0.9},
	{x=-129.7,y=28.9,z=8.1}, {x=-126.5,y=28.4,z=8.1},
	{}
    },
}

M.essentialPoints = {
    homepoint_2_M = {x=-50.5,y=-95,z=-0.1},
}

M.automatic_routes = {
    homepoint_2_M = "moghouse"
}

return M
