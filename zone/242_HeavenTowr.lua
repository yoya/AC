-- 天の塔

local M = { id = 242 }

M.routes = {
    kupipi = {
	{x=0,y=-22.4,z=0}, {x=-10,y=-4}, {x=-10,y=7},
	{x=-1,y=20.5}, {a="opendoor"}, {x=0,y=25},
	{x=1.5,y=30.1,z=0}, {a="f8touch"}
    },
    chumimi = {
	{x=0,y=-22.4,z=0}, {x=10,y=-9,z=0.6}, {x=13,y=14,z=0.5},
	{x=22,y=21,z=0},
	--- 階段を降りる
	{x=31,y=6,z=2.5}, {x=26,y=-17,z=7.5}, {x=8,y=-30,z=12},
	{x=-12,y=-30,z=16.3}, {x=-28,y=-13,z=21}, {x=-30,y=7,z=25.3},
	-- 下の階
	{x=-17,y=27,z=30}, {x=-1.6,y=20.7,z=30.8}, {a="f8touch"}
    },
}

M.essentialPoints = {
    from_win = {x=0,y=-22.4,z=0},
}

M.automatic_routes = {
    -- from_win = { route="kupipi" },
}

return M
