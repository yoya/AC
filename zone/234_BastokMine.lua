-- バストゥーク鉱山区

local M = { id = 234 }

M.routes = {
    -- HP#1 (A)
    gumba = { -- gumbah
	{x=38.2,y=-42.6,z=0}, {x=33,y=-39},
	{x=28,y=-28}, {x=23,y=-25.5}, {x=-3,y=-24}, {x=-4,y=-22},
	{x=-5,y=-5}, {x=-4,y=8.5}, {x=-2,y=10}, {x=8,y=10},
	{x=56,y=6}, {x=58.5,y=4}, {x=58,y=-11}, {x=56,y=-13},
	{x=51,y=-13}, {x=50,y=-15}, {a="opendoor"}, {x=50,y=-18},
	{x=53,y=-28}, {x=53.4,y=-34.8}, {a="f8touch"}
    },
}

M.essentialPoints = {
    hp_1_A = {x=38.2,y=-42.6,z=0},
}

M.automatic_routes = {
--    hp_1_A = "gumbah",
}

return M

