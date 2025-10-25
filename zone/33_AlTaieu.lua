-- アル・タユ

local M = { id = 33 }

M.routes = {
    -- 海獅子の巣窟
    huxzoi = {  -- フ・ゾイの王宮、正面の門
	{x=-27.5,y=-613.2,z=0}, {x=-1,y=-566,z=0,d=1},
	{x=-1,y=-547,z=0}, {}
    },
}

M.essentialPoints = {
    from_umijishi = {x=-27.5,y=-613.2,z=0},  -- h12
}

M.automatic_routes = {
    from_umijishi = { route="huxzoi" },
}

return M
