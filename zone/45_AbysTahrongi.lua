-- アビセア-タロンギ

local M = { id = 45 }

M.routes = {
    conf = {
	{x=-23.1,y=-677.4,z=44.3}, {x=-1.7,y=-678.4},
	{x=0,y=-680.3}, {a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-23.1,y=-677.4,z=44.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M

