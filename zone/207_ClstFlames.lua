-- 灼熱の回廊

local M = { id = 207 }

local contents = require 'contents'

M.routes = {
    proto = {
	{x=-699.5,y=-646.7,z=0.9}, {x=-704,y=-622},
	{x=-720,y=-600.7,z=0}, {a="f8touch"}
    },
    bc = contents.trial.bc_route
}

M.essentialPoints = {
    entrance = {x=-699.5,y=-646.7,z=0.9},
    bc_in = contents.trial.bc_point,
}

M.automatic_routes = {
    entrance = { route="proto" },
    bc_in = { route="bc" },
}

return M
