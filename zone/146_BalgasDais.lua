-- バルガの舞台

local M = { id = 146 }

M.routes = {
    circle = {
	{x=317.8,y=379,z=-124,desc="BCへ移動"},
	{x=305,y=379}, {x=301,y=376}, {x=300,y=371},
	{x=299,y=343,z=-124.1,d=1}, {touch="Burning Circle"}
    },
    bc = {
	{x=21,y=59.3,z=-4.1}, {x=21,y=0,z=-4.9}, {faith="balance"}
    },
}

M.essential_points = {
    entrance = {x=317.8,y=379,z=-124},
    bc_in = {x=21,y=59.3,z=-4.1},
    bc_out = {x=-299.1,y=-339,z=116.4},
}

M.automatic_routes = {
    entrance = { route="circle" },
    bc_in = { route="bc" },
}

return M
