-- チョコボサーキット

local M = { id = 70 }

M.routes = {
    ent = {
	{x=-320,y=-475,z=-0.3}, {x=-326.1,y=-463.9},
	{x=-327.1,y=-456.2}, {x=-329.1,y=-453.5},
	{x=-330.4,y=-412.9}, {a="f8touch"}, {a="wait"},
	{a="wait"},{a="up"}, {a="wait"}, {a="enter"}
    }
}

return M

