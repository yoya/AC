-- クゥルンの大伽藍 (ベドー深部)

local M = { id = 148 }

M.routes = {
    stone = {
	{x=2.9, y=60.5,desc="魔晶石ミッション"},
	{x=56,y=57.3}, {x=58.1,y=49.4},
	{x=61.7,y=22}, {x=60.2,y=-4.4},
	{touch="Door"}, {wait=1},
	{keys={"up", "enter"}}, {wait=5},
	{x=60.2,y=-10.6}, {x=37.6,y=-41.5},
	{x=25.2,y=-54.4}, {x=19.9,y=-69.7},
	{x=11.2,y=-81.2},
	{touch="Magicite"}
    },
}

M.essential_points = {
    entrance = {x=2.9, y=60.5},
}

M.automatic_routes = {
    entrance = { route="stone" },
}

return M
