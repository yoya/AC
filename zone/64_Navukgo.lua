-- ナバゴ処刑場

local M = { id = 64 }

M.routes = {
    gate = {
	{x=-660.5,y=-199.4,z=-10,desc="ナバゴ処刑場の門"},
	{x=-656,y=-190}, {x=-640,y=-180},
	{x=-633,y=-178}, {x=-623,y=-168}, {x=-621,y=-150},
	{x=-632,y=-130}, {x=-637,y=-112}, {x=-631,y=-100},
	{x=-605,y=-100,z=9.9},
	{target="Decorative Bronze Gate"}, {a="touch"}
    },
    bc = {
	{x=286.5,y=379.9,z=-124.4}, {x=332,y=379},
	{x=360,y=380,z=-116},
    },
    bc2bc = {
	{x=-539.9,y=24.9,z=-2.9}, {x=-566,y=20}, {x=-597,y=36},
	-- この先分からない。多分左沿いに行って崖を落ちる方。
    },
}

M.essentialPoints = {
    entrance = {x=-660.5,y=-199.4,z=-10},
    bc_in = {x=286.5,y=379.9,z=-124.4},
    bc_out= {x=-539.9,y=24.9,z=-2.9},
}

M.automatic_routes = {
    entrance = { route="gate" },
    bc_in = { route="bc" },
    bc_out= { route="bc2bc" },
}

return M
