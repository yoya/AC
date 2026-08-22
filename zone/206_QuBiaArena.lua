-- ク・ビアの闘技場

local M = { id = 206 }

M.routes = {
    circle = {
	{x=-241,y=19.7,z=-24.2},
	{x=-216,y=20,z=-24.6,d=1},
	{target="Burning Circle"}, {a="touch"}
    },
    bc = {
	{x=0,y=96.6,z=0.5}, {x=0,y=22,z=-2.1},
	{faith="balance"}
    },
    bc2 = {
	{x=-400.1,y=496.5,z=-199.5},  {x=-400,y=423,z=-202.1},
	{faith="balance"}
    },
}

M.essential_points = {
    entrance = {x=-241,y=19.7,z=-24.2},
    bc_in = {x=0,y=96.6,z=0.5},
    bc_in2 = {x=-400.1,y=496.5,z=-199.5},
}

M.automatic_routes = {
    entrance = { route="circle" },
    bc_in = { route="bc" },
    bc_in2 = { route="bc2" },
}

return M
