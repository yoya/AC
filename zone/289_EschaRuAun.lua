-- エスカ-ル・オン

local M = { id = 289 }

M.routes = {
    dremi = {
	{x=-0.4,y=-467,z=-34.3}, {x=-8.2,y=-461.3,z=-34},
	{target="Dremi"}, {a="touch"}
    },
    raja = {
	{x=0,y=-238,z=-43.8}, -- {x=-4,y=-212,z=-43.6,d=3},
	--{x=-2,y=-214,z=-43.6,d=3},
	{x=-4,y=-214,z=-43.6,d=3},
	{enemy_filter="Naga"}, {puller=true}
    }
}

M.essentialPoints = {
    entrance = {x=-0.4,y=-467,z=-34.3},
    domain_in = {x=0,y=-238,z=-43.8},
}


M.automatic_routes = {
    entrance = { route="dremi" },
    domain_in = { route="raja" },  -- Naga Raja
}

return M
