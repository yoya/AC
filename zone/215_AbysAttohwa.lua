-- アビセア-アットワ

local M = { id = 215 }

M.routes = {
    conf = {
	{x=-139.2,y=-180.6,z=20.3}, {x=-144.7,y=-178.8},
	{x=-146.3,y=-176.9}, {a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-139.2,y=-180.6,z=20.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M

