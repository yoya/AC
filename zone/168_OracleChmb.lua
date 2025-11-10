-- 震動の回廊

local M = { id = 168 }

M.routes = {
    -- HP#1 から
    circle = {  -- 
	{x=-177.1,y=-37.9,z=-0.8}, {x=-183,y=-25},
	{x=-191,y=-21}, {x=-213,y=-19}, {x=-218,y=-11},
	{x=-220,y=12.5,z=-0.3}, {x=-220.1,y=20.3,z=-1.9},
    },
    -- HP#2 から
    crystal = {  -- 土の試練
    }
}

M.essentialPoints = {
    entrance_h1 = {x=-177.1,y=-37.9,z=-0.8},
}

M.automatic_routes = {
    entrance_h1 = { route="circle" },
}

return M
