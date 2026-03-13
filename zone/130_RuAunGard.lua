-- ル・オンの庭

local M = { id = 130 }

M.routes = {
    warp = {
	{x=13, y=-594,z=-54.2,desc="本ワープから中央まで"},
	-- {x=0, y=-271,z=-42.4},
	{x=7,y=-597}, {x=0,y=-588,z=-52}, {x=-1,y=-581,z=-52.4},
	{wait=2}, {a="up"}, {a="enter"},
    },
    center = {
	{x=0, y=-472, z=-34.1}, {x=1,y=-435}, {x=0,y=-362},
	-- x=0,y={-362,-238}
	{x=0,y=-299,z=-42,d=1}, {enemy_filter={"Kirin","Coffer"}}, {auto=true},
	{enemy_range=100}
    },
}

M.essentialPoints = {
    --book = {x=0, y=-271,z=-42.4},
    book = {x=13, y=-594,z=-54.2},
    from_book = {x=0, y=-472, z=-34.1},
}


M.automatic_routes = {
    book = { route="warp" },
    from_book = { route="center" },
}


return M



