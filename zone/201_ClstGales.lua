-- 突風の回廊

local M = { id = 201 }
local contents = require 'contents'

M.routes = {
    proto = {
	{x=-399.5,y=-421.5,z=0},{x=-386,y=-418}, {x=-382,y=-413},
	{x=-378,y=-396}, {x=-372,y=-385}, {x=-362.5,y=-381.4,z=0.8},
	{a="f8touch"}
    },
    bc = contents.trial.bc_route,
}

M.essentialPoints = {
    entrance = {x=-399.5,y=-421.5,z=0},
    bc_in = contents.trial.bc_point,    
}

M.automatic_routes = {
    entrance = { route="proto" },
    bc_in = { route="bc" },
}

return M
