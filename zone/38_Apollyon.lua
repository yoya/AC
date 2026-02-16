-- アポリオン 

local M = { id = 38 }

M.routes = {
    ope = {
	{x=-668.4,y=-665.8,z=0}, {x=-655,y=-638},
	{x=-645,y=-602,z=0}, {target="Apollyon Operator"},
	{a="touch"}
    },
    vortex = {
	{x=-668.4,y=-665.8,z=0}, {x=-648,y=-634},
	{x=-633,y=-610}, {x=-627,y=-605},
	{x=-604,y=-600}, {target="Swirling Vortex"}, {a="touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-668.4,y=-665.8,z=0},
}

M.automatic_routes = {
    -- entrance = { route="ope" },
    entrance = { route="vortex" },
}

return M
