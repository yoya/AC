-- ジュノ港

local M = { id = 246 }

M.routes = {
   -- HP (E)
    shemo = { {x=36,y=8.8,z=0},{x=-29,y=3},
	{x=-54.5,y=3.5}, {x=-57,y=8.5}, {x=-55.5,y=10.5},
	{a="esc"}
    },
}

M.essentialPoints = {
    homepoint_2_M = {x=36,y=8.8,z=0}
}

M.automatic_routes = {
    homepoint_2_M = "shemo"
}

return M

