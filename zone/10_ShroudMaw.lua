-- 異界の口

local M = { id = 10 }

M.routes = {
    circle = {
	{x=-300.4,y=-219.9,z=0}, {x=-300,y=-252,z=0},
	{x=-300,y=-259,z=-2.5,d=2}, {target="Memento Circle"},
	{a="touch"},
    },
    bc = {
	{x=-300.2,y=220.1,z=-48}, {x=-254,y=222}, {x=-251,y=226},
	{x=-250,y=240}, {x=-242,y=251}, {x=-240,y=275,z=-48,d=2},
    }
}

M.essentialPoints = {
    entrance = {x=-300.4,y=-219.9,z=0},
    bc_in = {x=-300.2,y=220.1,z=-48},
}

M.automatic_routes = {
    entrance = { route="circle" },
    bc_in  = { route="bc" },
}

return M
