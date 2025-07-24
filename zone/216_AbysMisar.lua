-- アビセア-ミザレオ

local M = { id = 216 }

M.routes = {
    conf = {
	{x=657.2,y=316.3,z=-15.1}, {x=644.1,y=317.4},
	{x=642.8,y=319.4}, {a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=657.2,y=316.3,z=-15.1},
}

M.automatic_routes = {
    entrance = "conf",
}

return M
