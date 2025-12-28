-- アポリオン 

local M = { id = 38 }

M.routes = {
    ope = {
	{x=-668.4,y=-665.8,z=0}, {x=-655,y=-638},
	{x=-645,y=-602,z=0}, {target="Apollyon Operator"},
	{a="touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-668.4,y=-665.8,z=0},
}

M.automatic_routes = {
    entrance = { route="ope" },
}

return M
