-- フェ・イン

local M = { id = 204 }

M.routes = {
    bc = {
	{x=242,y=62,z=-24.4}, {x=244,y=61,z=-24.4}, {}
	-- {x=242.1,y=60.8,z=-24.2},
    },
}

M.essential_points = {
    hp1 = {x=242,y=62,z=-24.4},
}

M.automatic_routes = {
    hp1 = { route="bc", contents="mission" },
		
}

return M
