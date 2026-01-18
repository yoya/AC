-- 翡翠廟

local M = { id = 67 }

M.routes = {
    door = {
	{x=340.4,y=-157.4,z=-11.9,desc="Ornamental Door(少女の傀儡)"},
	{x=340,y=-145}, {x=336,y=-139},
	{x=331,y=-138}, {x=325,y=-139}, {x=317,y=-140}, {x=303,y=-135},
	{x=297.5,y=-135.6,z=-4.2}, {x=294,y=-143}, {x=300,y=-157},
	{x=300,y=-186},
	{x=300,y=-196,z=-0.3,d=1}, {target="Ornamental Door"}, {a="touch"}
    },
    bc = {
	{x=219.1,y=274.2,z=-31}, {x=222,y=263}, {x=228,y=252},
    },
    ['bc-loop'] = {
	{x=260,y=-236,z=8.5}, {x=259,y=-195}, {x=258,y=-184},
	{x=275,y=-179}, {x=295,y=-180},{x=300,y=-186},
	{x=300,y=-196,z=-0.3,d=1}, {target="Ornamental Door"}, {a="touch"}
    },
}

M.essentialPoints = {
    entrance = {x=340.4,y=-157.4,z=-11.9}, -- バフラウから入る
    bc_in = {x=219.1,y=274.2,z=-31},
    bc_out = {x=260,y=-236,z=8.5},
}

M.automatic_routes = {
    entrance = { route="door" },
    bc_in = { route="bc" },
    bc_out = { route="bc-loop" },
}

return M
