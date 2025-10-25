-- 海獅子の巣窟

local M = { id = 32 }

M.routes = {
    -- 入り口
    gate = {
	{x=599.4,y=797.4,z=132.9}, {x=610,y=786,d=1},
	{x=611,y=774,z=132.8,d=1},
    },
}

M.essentialPoints = {
    entrance = {x=599.4,y=797.4,z=132.9},
}

M.automatic_routes = {
    entrance = { route="gate" },
}

return M
