-- 天の塔

local M = { id = 242 }

M.routes = {
    kupipi = {
	{x=0,y=-22.4,z=0}, {x=-10,y=-4}, {x=-10,y=7},
	{x=-1,y=20.5}, {a="opendoor"}, {x=0,y=25},
	{x=1.5,y=30.1,z=0}, {a="f8touch"}
    },
}

M.essentialPoints = {
    from_win = {x=0,y=-22.4,z=0},

}

M.automatic_routes = {
    from_win = "kupipi",
}

return M

