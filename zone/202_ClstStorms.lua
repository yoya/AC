-- 雷鳴の回廊

local M = { id = 202 }

local contents = require 'contents'

M.routes = {
    proto = {
	{x=518,y=539.3,z=-16.2}, {x=531,y=541}, {x=543,y=536},
	{x=541,y=525}, {x=542,y=515}, {x=535.9,y=495.7,z=-13.5},
	{a="f8touch"}
    },
    bc = contents.trial.bc_route,
}

M.essentialPoints = {
    entrance = {x=518,y=539.3,z=-16.2},
    bc_in = contents.trial.bc_point,
}

M.automatic_routes = {
    entrance = { route="proto" },
    bc_in = { route="bc" },
}

return M
