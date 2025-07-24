-- アビセア-ラテーヌ

local M = { id = 132 }

M.routes = {
    conf = {
	{x=-480,y=792,z=0.2}, {x=-476,y=785.1},
	{x=-472.9,y=785.4}, {a="f8touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-480,y=792,z=0.2},
}

M.automatic_routes = {
    entrance = "conf",
}

return M

