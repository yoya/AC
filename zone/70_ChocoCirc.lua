-- チョコボサーキット

local M = { id = 70 }

local incoming_text = require 'incoming/text'
local task = require 'task'

M.routes = {
    ent = {
	{x=-320,y=-475,z=-0.3}, {x=-326,y=-464},
	{x=-327.1,y=-456.2}, {x=-329,y=-454},
	{x=-330,y=-448},
	{x=-330.3,y=-413},
	{a="f8touch"}, {a="wait"}, {a="up"}, {a="enter"}
	--{x=-330.3,y=-413}, {a="f8touch"}, {a="wait"},
	--{a="wait"},{a="up"}, {a="wait"}, {a="enter"}
    },
    -- アトルガンから入った場所
    aht2warp = {  -- ワープで飛ぶ
	{x=-149.9,y=-386.4,z=0}, {x=-160,y=-378},
	{x=-162.5,y=-372,z=0}, {}, {w=3},
	{a="up"}, {a="enter"}
	--{a="up"}, {a="wait"}, {a="enter"}
    },
    aht2warp2ent = {
	{x=-280,y=-463,z=-4}, {x=-276,y=-466}, {x=-253.1,y=-469.2,z=-5},
	{a="f8touch"}, {a="wait"}, {a="up"}, {a="enter"}
	--{a="f8touch"}, {a="wait"},
	--{a="wait"}, {a="up"}, {a="wait"}, {a="enter"}
    },
    -- 観客席
    seats = {
	{x=-35.6,y=-125.6,z=-14.5},
	{x=-37,y=-112,z=-12.4,d=5} -- d=10 だと壁にめり込む事がある
    }
}

M.essential_points = {
    wand_warp_point = {x=-320,y=-475,z=-0.3},
    from_aht = {x=-149.9,y=-386.4,z=0},
    from_aht_warp = {x=-280,y=-463,z=-4},
    audience_in = {x=-35.6,y=-125.6,z=-14.5}
}

M.automatic_routes = {
    wand_warp_point = { route="ent" },
    from_aht = { route="aht2warp" },
    from_aht_warp = { route="aht2warp2ent" },
    audience_in = { route="seats" },
}

return M
