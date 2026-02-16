-- アル・タユ

local M = { id = 33 }

M.routes = {
    -- 海獅子の巣窟
    huxzoi = {  -- フ・ゾイの王宮、正面の門
	{x=-27.5,y=-613.2,z=0}, {x=-1,y=-566,z=0,d=1},
	{x=-1,y=-547,z=0}, {}
    },
    vortex2 = {
	{x=-531,y=447,z=0}, {x=-560,y=444,z=0},
	{target="Swirling Vortex"}, {a="touch"}
    },
}

M.essentialPoints = {
    from_umijishi = {x=-27.5,y=-613.2,z=0},  -- H-12
    from_dem = {x=-531,y=447,z=0}, -- E-6
}

M.automatic_routes = {
    from_umijishi = { route="huxzoi" },
    from_dem = { route="vortex2" },
}

return M
