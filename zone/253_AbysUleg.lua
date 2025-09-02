-- アビセア-ウルガラン

local M = { id = 253 }

M.routes = {
    conf = {
	{x=-236,y=-520,z=-40}, {x=-222.6,y=-522.3},
	{x=-222.2,y=-524.9}, {a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-236,y=-520,z=-40},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M

