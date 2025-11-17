-- ラ・ロフの劇場

local M = { id = 180 }

M.routes = {
    circle = {
	{x=527.3,y=559.2,z=-39.3}, {x=553.3,y=524.3,z=-38.2},
	{a="f8touch"}
    },
    bc = {
	{x=8.1,y=-108.4,z=-33.3}, {x=23,y=-82}, {x=21,y=-77},
	{x=15,y=-70}, {x=12,y=-64}, {x=19,y=-49}, {x=19,y=-45},
	{x=5.6,y=-20.1,z=-25.4}
    },
}

M.essentialPoints = {
    entrance = {x=527.3,y=559.2,z=-39.3},
    bc_in = {x=8.1,y=-108.4,z=-33.3},
}

M.automatic_routes = {
    entrance = { route="circle" },
    bc_in = { route="bc" },
}

return M
