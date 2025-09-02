-- 北サンドリア

local M = { id = 231 }

M.routes = {
    -- HP#2
    castle = {  -- 城
	{x=10,y=94,z=-0.2}, {x=6,y=99}, {x=5,y=107}, {}
    },
}

M.essentialPoints = {
    hp2 = {x=10,y=94,z=-0.2},
}

M.automatic_routes = {
    hp2 = { route="castle" },
}


return M
