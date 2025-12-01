-- チョコボサーキット

local M = { id = 70 }

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
}

M.essentialPoints = {
    wand_warp_point = {x=-320,y=-475,z=-0.3},
    from_aht = {x=-149.9,y=-386.4,z=0},
    from_aht_warp = {x=-280,y=-463,z=-4},
}

M.automatic_routes = {
    wand_warp_point = { route="ent" },
    from_aht = { route="aht2warp" },
    from_aht_warp = { route="aht2warp2ent" },
}

return M
