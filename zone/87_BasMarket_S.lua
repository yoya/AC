-- バストゥーク商業区〔Ｓ〕

local M = { id = 87 }

M.routes = {
    -- HP#1
    daikobo = {  -- 大工房入り口前
	{x=-292,y=-102.6,z=-10}, {x=-284,y=-102}, {x=-269,y=-95},
	{x=-240,y=-36}, {x=-204,y=-28}, {x=-201,y=-1}
    }
}

M.essentialPoints = {
    hp1 = {x=-292,y=-102.6,z=-10},
}

M.automatic_routes = {
}

return M
