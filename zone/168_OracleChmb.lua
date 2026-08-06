-- 震動の回廊

local M = { id = 168 }

M.routes = {
    -- HP#1 から
    circle = {  -- 
	{x=-177.1,y=-37.9,z=-0.8,"託宣の間(流砂洞を超えて)"},
	{x=-183,y=-25},
	{x=-191,y=-21}, {x=-213,y=-19}, {x=-218,y=-11},
	{x=-220,y=12.5,z=-0.3}, {x=-220.1,y=20.3,z=-1.9},
	{target="Shimmering Circle"}
    },
    -- HP#2 から
    crystal = {  -- 土の試練
    },
    -- BC
    bc = {
	{x=0,y=-306.5,z=97.1}, {x=0,y=-272,z=97.5},
	{target="Cermet Door"}, {a="opendoor"},
	{x=0,y=-261,z=97.7},
    },
    exit = {
	{x=200.1,y=-22,z=-0.2, "脱出"},
	{x=200,y=-47}, {x=199,y=-53}, {x=196,y=-58}, {x=184,y=-60,z=-0.4},
	-- 穴から落ちる
	{x=181,y=-61,z=3.1}, {x=181,y=-69}, {x=179,y=-77}, {x=185,y=-97}, {}
    },
}

M.essential_points = {
    entrance_h1 = {x=-177.1,y=-37.9,z=-0.8},
    bc_in = {x=0,y=-306.5,z=97.1},
    bc_exit = {x=200.1,y=-22,z=-0.2},
}

M.automatic_routes = {
    entrance_h1 = { route="circle" },
    bc_in = { route="bc" },
    -- bc_exit = { route="exit"},  -- 戦利品があるので自動で移動はしない
}

return M
