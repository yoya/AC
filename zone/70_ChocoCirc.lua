-- チョコボサーキット

local M = { id = 70 }

M.routes = {
    ent = {
	{x=-320,y=-475,z=-0.3}, {x=-326,y=-464},
	{x=-327.1,y=-456.2}, {x=-329,y=-454},
	{x=-330,y=-448},
	{x=-330.3,y=-413}, {a="f8touch"}, {a="wait"},
	{a="wait"},{a="up"}, {a="wait"}, {a="enter"}
    }
}

M.essentialPoints = {
    wand_warp_point = {x=-320,y=-475,z=-0.3},
}

M.automatic_routes = {
    wand_warp_point = { route="ent" },
}

return M

