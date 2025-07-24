-- アビセア-グロウベルグ

local M = { id = 254 }

M.routes = {
    conf = {
	 {x=-552,y=-760,z=32.4}, {x=-528.2,y=-772.7},
	 {x=-528.9,y=-776.1}, {a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-552,y=-760,z=32.4},
}

M.automatic_routes = {
    entrance = "conf",
}

return M

