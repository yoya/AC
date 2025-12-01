-- アビセア-ブンカール

local M = { id = 217 }

M.routes = {
    conf = {
	{x=-351.3,y=699.8,z=-46.3}, {x=-339.7,y=696.7},
	{x=-318.5,y=680.9}, {x=-317.2,y=682.4},
	{a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-351.3,y=699.8,z=-46.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M
