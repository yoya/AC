-- ジュノ港

local M = { id = 246 }

M.routes = {
   -- HP (E)
    shemo = { {x=36,y=8.8,z=0},{x=-29,y=3},
	{x=-54.5,y=3.5}, {x=-57,y=8.5}, {x=-55.5,y=10.5},
	{a="esc"}
    },
    -- HP (M)
    oboro = {
	{x=-155,y=-3,z=-1}, {x=-153,y=3}, {x=-151,y=6},
	-- 階段を降りる
	{x=-153,y=31,d=1}, {x=-159,y=52,d=1}, {x=-173,y=79,d=1},
	{x=-178.4,y=84.5,z=11}
    },
}

M.essentialPoints = {
    homepoint_2_M = {x=36,y=8.8,z=0}
}

M.automatic_routes = {
    homepoint_2_M = "shemo"
}

return M

