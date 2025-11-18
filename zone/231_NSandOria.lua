-- 北サンドリア

local M = { id = 231 }

M.routes = {
    -- HP#2
    castle = {  -- 城
	{x=10,y=94,z=-0.2}, {x=6,y=99}, {x=5,y=107}, {}
    },
    phantom = { -- ファントムクォーツ (phantom gem)
	{x=10,y=94,z=-0.2}, {x=26.5,y=85.7,z=-0.2},
	{a="f8touch"}
    },
    -- HP#3
    daiseido = { -- 大聖堂
	{x=69,y=9,z=-0.2}, {x=80,y=60,d=1}, {x=92,y=81,d=1},
	{x=111.9,y=103.8},
    }
}

M.essentialPoints = {
    hp2 = {x=10,y=94,z=-0.2},
    hp3_M = {x=69,y=9,z=-0.2},
}

M.automatic_routes = {
    -- hp2 = { route="castle" },
    hp2 = { route="phantom" },
    hp3_M = { route="daiseido" },
}


return M
