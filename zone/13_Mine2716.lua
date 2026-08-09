-- 2716号採石場

local M = { id = 13 }

M.routes = {
    -- 本ワープ
    shaft = {
	{x=-116.6,y=-621.1,z=-119.9}, {x=-109,y=-618}, {x=-103.5,y=-611.5},
	{x=-101,y=-606}, {x=-99,y=-590}, {x=-90,y=-582,d=1},
	{x=-57.2,y=-580,z=-120},
	{target="Shaft Entrance"}, {a="touch"}
    },
    bc = {
	{x=-530.3,y=-100,z=120}, {x=-499,y=-100}, {x=-473,y=-100},
	{x=-465,y=-94}, {x=-461,y=-88}, {x=-460,y=-62},
	{x=-460,y=-8,d=1}
    },
    tsudoe = {
	{x=-50.3,y=-100,z=0,desc=""},
	{x=-18,y=-100}, {x=-4,y=-100}, {x=10,y=-98},
	{x=18,y=-92}, {x=20,y=-83}, {x=20,y=-62,z=-0.3},
    },
    exit = {
	-- {x=-103,y=500},
	{x=-138.7,y=500.9,z=180.1,"BC出口から新市街へ"},
	{x=-155.3,y=500.9,z=180.1}, {}

    }
}

M.essential_points = {
    -- x={-116.6},y={-618.9,-621}.1,z={-119.9}
    entrance = {x=-116.6,y=-620.1,z=-119.9,dy=2},
    bcentrance = {x=-530.3,y=-100,z=120},
    tsudoe = {x=-50.3, y=-100, z=0},
    bcexit = {x=-138.7,y=500.9,z=180.1},
    warp_from_bcexit = {x=-93.7,y=-583.6,z=-120},
}

M.automatic_routes = {
    entrance = { route="shaft" },
    warp_from_bcexit = { route="shaft" },
    bcentrance = { route="bc" },
    tsudoe = { route="tsudoe" },
    -- bcexit = { route="exit" }, 自動で移動するとロット確定できない
}

return M
