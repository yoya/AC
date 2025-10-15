-- 2716号採石場

local M = { id = 13 }

M.routes = {
    -- 本ワープ
    shaft = {
	{x=-116.6,y=-621.1,z=-119.9}, {x=-109,y=-618}, {x=-103.5,y=-611.5},
	{x=-101,y=-606}, {x=-99,y=-590}, {x=-90,y=-582,d=1},
	{x=-57.2,y=-580,z=-120}
    },
    bc = {
	{x=-530.3,y=-100,z=120}, {x=-499,y=-100}, {x=-473,y=-100},
	{x=-465,y=-94}, {x=-461,y=-88}, {x=-460,y=-62},
	{x=-460,y=-8,d=1}
    }
}

M.essentialPoints = {
    entrance = {x=-116.6,y=-621.1,z=-119.9},
    bcentrance = {x=-530.3,y=-100,z=120},
}

M.automatic_routes = {
    entrance = { route="shaft" },
    bcentrance = { route="bc" },
}

return M
