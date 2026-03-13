-- 龍のねぐら

local M = { id = 154 }

M.routes = {
    center = {
	{x=-59.5,y=-39.5,z=-1.1,desc="Fafnir"},
	{x=-56,y=-25}, {x=-61,y=-7}, {x=-61,y=15}, {x=-49,y=21},
	{x=4,y=19}, {x=15,y=17},
	--
	{x=-20,y=20,d=1}
    },
    faf = {
	{x=-59.5,y=-39.5,z=-1.1,desc="Fafnir"},
	{x=-56,y=-25}, {x=-61,y=-7}, {x=-61,y=15}, {x=-49,y=21},
	{x=4,y=19}, {x=15,y=17},
	-- center
	{x=32,y=21}, {x=46,y=19},
	{x=55,y=21}, {x=62,y=24}
    }
}

M.essentialPoints = {
    from_boyahda = {x=-59.5,y=-39.5,z=-1.1},
}


M.automatic_routes = {
    -- from_boyahda = { route="faf" },
}

return M
