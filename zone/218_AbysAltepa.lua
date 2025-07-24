-- アビセア-アルテパ

local M = { id = 218 }

M.routes = {
    conf = {
	{x=430,y=320,z=0.3}, {x=424.4,y=326.9},
	{x=410.1,y=328.6}, {x=410.4,y=330},
	{a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=430,y=320,z=0.3},
}

M.automatic_routes = {
    entrance = "conf",
}

return M
