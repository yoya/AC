-- 天象の鎖

local M = { id = 36 }

M.routes = {
    -- エレベーター地下
    radiance = {  -- Transcendental Radiance:
	{x=540,y=-500,z=-1.7}, {x=540,y=-510,z=-0.4},
	{x=540,y=-563,z=0}, {x=540,y=-594,z=0},
    },
}

M.essentialPoints = {
    under = {x=540, y=-500,z=-1.7},
}

M.automatic_routes = {
    under = { route="radiance" },
}

return M
