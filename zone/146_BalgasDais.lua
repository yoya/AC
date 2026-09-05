-- バルガの舞台

local M = { id = 146 }

M.routes = {
    circle = {
	{x=317.8,y=379,z=-124,desc="BCへ移動"},
	{x=305,y=379}, {x=301,y=376}, {x=300,y=371},
	{x=299,y=343,z=-124.1,d=1}, {touch="Burning Circle"}
    },
    bc1 = {
	{x=21,y=59.3,z=-4.1}, {x=21,y=0,z=-4.9}, {faith="balance"}
    },
    bc2 = {
	{x=-139.2,y=-140.6,z=55.9}, {x=-139,y=-201,z=54.8},
	{faith="balance"}
    },
}

M.essential_points = {
    entrance = {x=317.8,y=379,z=-124},
    bc_in1 = {x=21,y=59.3,z=-4.1},
    bc_in2 = {x=-139.2,y=-140.6,z=55.9},
    bc_out = {x=-299.1,y=-339,z=116.4},
}

M.automatic_routes = {
    entrance = { route="circle" },
    bc_in1 = { route="bc1" },
    bc_in2 = { route="bc2" },
}

return M
