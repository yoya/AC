-- ル・ルデの庭

local M = { id = 243 }

M.routes = {
    -- HP#1
    maat = {
	{x=-6,y=-1,z=3,desc="Maat"}, {x=-3,y=2.4}, {x=-1.6,y=28.6},
	{x=-3.1,y=36.2}, {x=-9.3,y=46.5}, {x=-9.3,y=64.7},
	{x=-2,y=76}, {x=2.9,y=116.7}, {x=8.1,y=119.2}
    },
    trust = {
	{x=-6,y=-1,z=3,desc="フェイスNPC"}, {x=-3,y=2.4}, {x=-1.6,y=28.6},
	{x=-3.1,y=36.2}, {x=-9.3,y=46.5}, {x=-9.3,y=64.7}, {x=-2,y=76},
	{x=0,y=126.5}, {a="opendoor"}, {x=0,y=130}, {x=0,y=134,z=2},
    },
    taiko = {
	{x=-6,y=-1,z=3,desc="太公の間"}, {x=-3.3,y=2.5}, {x=-1, y=27.9},
	{x=-1.7,y=34}, {x=-0.3,y=68.6},
    },
    pheri = {
	{x=-6,y=-1,z=3,desc="Pherimociel"}, {x=-3,y=2.4}, {x=-1.6,y=28.6},
	{x=-3.1,y=36.2}, {x=-9.3,y=46.5}, {x=-14,y=62},
	{x=-23.5,y=63.5}, {a="opendoor"}, {x=-27,y=64},
	{x=-30.5,y=67.1,z=2}, {a="touch"},
    },
    sand = {
	{x=-6,y=-1,z=3,desc="サンド領事館"}, {x=2.8,y=-24.7},
	{x=-11.33,y=-49.8}, {x=-31.2,y=-49.9}
    },
    proto = {
	{x=-6,y=-1,z=3,desc="Proto-Waypoint"}, {x=-22,y=-10,d=1},
	{x=-26,y=-14,z=3,d=1}, {x=-36,y=-40,z=0},
	{a="f8"}, {target="Proto-Waypoint"},
    },
}

M.essentialPoints = {
    hp1 = {x=-6,y=-1,z=3},
}

M.automatic_routes = {
    -- hp1 = { route="trust" },
    hp1 = { route="proto" },
}


return M
