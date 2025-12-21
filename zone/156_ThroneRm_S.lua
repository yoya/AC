-- 王の間〔Ｓ〕

local M = { id = 156 }

M.routes = {
    king = {
	{x=114.3,y=-0.7,z=-6.1}, {x=49,y=0,d=1}, {x=9,y=0,d=1},	{x=-42,y=0},
	{x=-111,y=0,z=-6.1}, {target="Throne Room"}, {a="touch"}
    }
}

M.essentialPoints = {
    entrance = {x=114.3,y=-0.7,z=-6.1},
}

M.automatic_routes = {
    entrance = { route="king" },
}

return M
