-- 海流の回廊

local M = { id = 211 }

local contents = require 'contents'

M.routes = {
    proto = {
	{x=564.8,y=500.8,z=36.4}, {x=574,y=501}, {x=579,y=505},
	{x=577,y=531}, {x=560.5,y=560.2,z=36.5}, {a="f8touch"}
    },
    bc = contents.trial.bc_route,
}

M.essentialPoints = {
    entrance = {x=564.8,y=500.8,z=36.4},
    bc_in = contents.trial.bc_point,
}

M.automatic_routes = {
    entrance = { route="proto" },
    bc_in = { route="bc" },
}

return M
