-- ワールンの祠

local M = { id = 144 }

M.routes = {
    bc = {
	{x=-262.1,y=-139.9,z=60.3},
	{x=-200,y=-142,z=58.4},
    }
}

M.essential_points = {
    bc_in = {x=-262.1,y=-139.9,z=60.3},
}


M.automatic_routes = {
    bc_in = { route="bc"},
}

return M
