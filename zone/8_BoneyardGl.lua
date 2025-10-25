-- 千骸谷

local M = { id = 8 }

M.routes = {
    -- HP#1
    miasma  = { -- Dark Miasma (BC 入り口)
	{x=-709.5,y=456.6,z=20.5}, {x=-701,y=446,d=1},
	{x=-697,y=432,d=1}, {x=-686,y=421,d=1}, {x=-674,y=422},
	{x=-654,y=420}, {x=-654,y=420}, {x=-632,y=419}, {x=-624,y=405},
	{x=-618,y=407,d=1}, {x=-605,y=435,d=1}, {x=-600,y=454,d=1},
	{x=-604,y=477,d=1}, {x=-614,y=499}, {x=-616.7,y=502.4,z=-2},
    },
    bc_enemy = {
	{x=-635,y=-524.1,z=0.2}, {x=-624.5,y=-498.5}, {x=-619,y=-494},
	{x=-599,y=-484,d=1}, {x=-579,y=-464,d=1},
    }
}

M.essentialPoints = {
    entrance = {x=-709.5,y=456.6,z=20.5},
    bc_entrance = {x=-635,y=-524.1,z=0.2},
}

M.automatic_routes = {
    entrance = { route="miasma" },
    bc_entrance = { route="bc_enemy" },
}

return M
