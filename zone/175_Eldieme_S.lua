-- エルディーム古墳〔Ｓ〕

local M = { id = 175 }

M.routes = {
    -- book ワープから
    sch = {
	{x=419,y=-99.5,z=-52.2,desc="学者クエNPC"},
	{x=420,y=-77}, {x=420,y=-43},
	{x=418,y=10}, {x=410,y=18}, {x=393,y=20},
	{x=379,y=18,z=-40,d=1},	{touch="Erlene"},
    }
}

M.essential_points = {
    book = {x=419,y=-99.5,z=-52.2},
}

M.automatic_routes = {
    book = { route="sch" },
}

return M
