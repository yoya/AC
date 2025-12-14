-- エスカ-ル・オン

local M = { id = 289 }

M.routes = {
    dremi = {
	{x=-0.4,y=-467,z=-34.3}, {x=-8.2,y=-461.3,z=-34},
	{target="Dremi"}
    },
}

M.essentialPoints = {
    entrance = {x=-0.4,y=-467,z=-34.3},
}


M.automatic_routes = {
    entrance = { route="dremi" },
}

return M
