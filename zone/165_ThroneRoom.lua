-- 王の間

local M = { id = 165 }

M.routes = {
    king = {
	{x=114.3,y=-0.5,z=-6.1, "王の間"},
	{x=100,y=0,d=1}, {x=50,y=0,d=1}, {x=0,y=0,d=1},
	{x=-45,y=0,d=1}, {x=-114,y=0,z=-6.1,d=1},
	{target="Throne Room"}
    },
}

M.essential_points = {
    entrance = {x=114.3,y=-0.5,z=-6.1},
    
}

M.automatic_routes = {
    entrance = { route="king" },
}

return M
