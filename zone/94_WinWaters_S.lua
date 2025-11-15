-- ウィンダス水の区〔Ｓ〕

local M = { id = 94 }

M.routes = {
    -- HP#1
    velda = {  -- 石の区の交通止めの場所
	{x=-32,y=130.7,z=-5}, {x=-39,y=125}, {x=-39,y=99}, {x=-15,y=87},
	{x=-5,y=70},
	-- だいたい共通
	{x=1,y=52}, {x=34,y=49}, {x=71,y=30}, {x=85,y=31},
	{x=136.4,y=60.3}, {a="f8touch"}
    }
}

M.essentialPoints = {
    hp1 = {x=-32,y=130.7,z=-5},
}

M.automatic_routes = {
}

return M
