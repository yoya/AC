-- ラ・カザナル宮天守

local M = { id = 277 }

M.routes = {
    omi = { -- Ominous Postern (最奥)
	{x=70,y=20,z=-30}, {a="f8touch"}, {a="enter"}, {x=80,y=20},
	{x=97.8,y=19.8}, {x=101.5,y=58.4}, {x=218.4,y=58.3,z=15},
	{x=218.3,y=22,z=25}, {x=121.5,y=20.1,z=39.2},
	{a="f8toucb"}
    }
}

return M
