-- 東アドゥリン

local M = { id = 257 }

local io_chat = require 'io/chat'

M.routes = {
    -- モグハウス
    hp2m = {
	{x=-53.7,y=-128.5,z=-0.1}, {x=-54,y=-100,z=0,d=2},
	{x=-54,y=-91,d=1}, {x=-48,y=-90,d=1}, {x=-50,y=-92,d=1},
	{a="f8"}, {target="Home Point #2"}, {a="touch"}
    },
    auction = {
	{x=-56,y=-128.5,z=-0.1}, {x=-54,y=-99}, {x=-48,y=-94},
	{x=-24.5,y=-92.3,z=-0.6}, {target="Auction Counter"}
    },
    -- HP#2(M)
    moghouse = {
	-- {x=-50.5,y=-95,z=-0.1}, {x=-54,y=-100},
	{x=-50.5,y=-95,z=-0.1}, {x=-55,y=-101},
	{x=-56,y=-109}, {}
    },
    -- PCK
    pck = {
	{x=-101.3,y=-10.7,z=-0.1}, {x=-83,y=-2}, {x=-83,y=5},
	{x=-86,y=8}, {x=-110,y=10}, {x=-112,y=14},
	{x=-113,y=19.1,z=-0.7}, {a="f8touch"}
    },
    pckwp = {
	{x=-113,y=19.1,z=-0.7}, {x=-112,y=14}, {x=-110,y=10},
	{x=-86,y=8}, {x=-83,y=5}, {x=-83,y=-2},
	{x=-100.5,y=-9.4,z=-0.1}, {a="f8touch"}
    },
    f7rala = {
	{x=-101.3,y=-10.7,z=-0.1}, {x=-111.8,y=-1.6,z=0},
	{x=-123.5,y=4.2,z=0}, {x=-126.2,y=60.1,z=0},
	{x=-129,y=60.2,z=0.1}, {x=-130,y=57.3,z=0.9},
	{x=-129.7,y=28.9,z=8.1}, {x=-126.5,y=28.4,z=8.1},
	{}
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
    -- ヤッセの船着場
    ionis = {
	{x=-57.8,y=85.2,z=-0.1}, {x=-54.3,y=85,z=-0.1,d=1},
	{target="Quiri-Aliri"},
	{a="enter"}, {wait=1}, {a="enter"},
	{a="up"}, {a="enter"},
	{wait=2}, {x=-57.6,y=85.1,d=1}, -- {a="f8touch"},
	{target="Waypoint"}, {a="touch"}
    },
    -- 太陽の広場 (Coronal Esplanade)
    bayld = { -- ベヤルド交換
	{x=27.1,y=-60.8,z=-40.2}, {x=62,y=-74}, {x=66,y=-76}, {x=66,y=-109},
	{x=63,y=-113,z=-40.3,d=1}, {target="Runje Desaali"}
    }
}

M.essentialPoints = {
    pck = {x=-101.3,y=-10.7,z=-0.1},
    -- x=(-59.4,-51.5),y=-128.5
    from_moghouse = {x=-56,y=-128.5,z=-0.1, dx=5,dy=1},
    -- HP#2(M) x=(-51.3,-50.5), y=(-95.7-93.9)
    homepoint_2_M = {x=-50.5,y=-95.5,z=-0.1, d=1.5},
    yahse_dock = {x=-57.8,y=85.2,z=-0.1},
    sun_square = {x=27.1,y=-60.8,z=-40.2}, -- 太陽の広場 (Coronal Esplanade)
}

M.automatic_routes = {
    pck = { route="pck" },
    from_moghouse = { route="hp2m" },
    homepoint_2_M = { route="moghouse" },
    yahse_dock = { route="ionis" },
    sun_square = { route="bayld" }, -- ベヤルド交換
}

return M
