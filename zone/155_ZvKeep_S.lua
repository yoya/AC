-- ズヴァール城内郭〔Ｓ〕

local M = { id = 155 }

M.routes = {
    king = {
	{x=62,y=-20.7,z=0},
	{x=0,y=-20}, {target="Iron Bar Gate"}, {a="touch"}, {x=-5,y=-20},
	{x=-22,y=-18}, {x=-29,y=16},
	{x=-30,y=39}, {target="Iron Bar Gate"}, {a="touch"}, {x=-30,y=43},
	{x=-15,y=54},
	{x=-11,y=76}, {target="Iron Bar Gate"}, {a="touch"}, {x=-10,y=81},
	{x=-16,y=90}, {target="Ore Door"}, {a="touch"}, {x=-21,y=90},
	{x=-36,y=90}, {target="Ore Door"}, {a="touch"}, {x=-42,y=90},
	{x=-50,y=95}, {target="Ore Door"}, {a="touch"}, {x=-50,y=101},
	{x=-57,y=110}, {target="Ore Door"}, {a="touch"}, {x=-62,y=110},
	{x=-69,y=115,z=0}, {target="Iron Bar Gate"}, {a="touch"}, {x=-70,y=123,z=0},
	{x=-68,y=142,z=-8.1}, {x=-51,y=142,z=-8},
	{x=-50,y=121,z=-16}, {target="Iron Bar Gate"}, {a="touch"}, {x=-50,y=116,z=-16},
	{x=-58,y=110}, {target="Ore Door"}, {a="touch"}, {x=-64,y=110,z=-15.5},
	-- 上の階
	{x=-69,y=83,z=-15.8}, {target="Iron Bar Gate"}, {a="touch"}, {x=-69,y=78,z=-16},
	{x=-61,y=45,z=-15.4}, {target="Iron Bar Gate"}, {a="touch"}, {x=-60,y=38,z=-16},
	{x=-62,y=16,z=-16}, {x=-92,y=13,z=-16}, {x=-97,y=-16,z=-16},
	{x=-101,y=-18,z=-16}, {target="Iron Bar Gate"}, {a="touch"}, {x=-108,y=-20,z=-16},
	-- 階段をのぼる
	{x=-139,y=-18,z=-20}, {x=-141,y=19,z=-28}, {x=-179,y=18,z=-36},
	{x=-182,y=-18,z=-44}, {x=-253,y=-20,z=-48},
	{x=-301,y=-21,z=-49.1},
    }
}

M.essentialPoints = {
    entrance = {x=62,y=-20.7,z=0},
}

M.automatic_routes = {
}

return M

