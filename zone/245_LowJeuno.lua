-- ジュノ下層

local M = { id = 245 }

M.routes = {
    -- HP (M)
    neptune = {
	{x=19,y=53,z=-1,desc="天晶堂のはじめのドア"},
	{x=17,y=46}, {x=19,y=33},
	{x=15,y=28}, {x=11,y=26}, {x=5,y=17}, {x=4,y=8},
	{x=12.5,y=-1}, {a="f8touch"}, {x=15,y=-3.3},
	{x=36,y=-15.5}, {a="f8touch"},
    },
    tensho = {
	{x=19,y=53,z=-1,desc="天晶堂の中"},
	{x=17,y=46}, {x=19,y=33},
	{x=15,y=28}, {x=11,y=26}, {x=5,y=17}, {x=4,y=8},
	{x=12.5,y=-1}, {a="f8touch"}, {x=15,y=-3.3},
	{x=36,y=-15.5}, {a="f8touch"},
	--- はじめのドア
	{x=39.5,y=-17.5,z=-0.1}, {x=42,y=-20}, {x=42,y=-22},
	{x=35,y=-35}, {a="opendoor"}, {x=33,y=-38},
    },
    aldo = {
	{x=19,y=53,z=-1,desc="アルド(天晶堂)"},	{x=18,y=47,d=1},
	{x=18,y=33,d=1}, {x=16,y=29,d=1}, {x=11,y=27,d=1},
	{x=5,y=16,d=1}, {x=4,y=8,d=1}, {x=12,y=-1},
	{a="f8"}, {target="Door:\"Neptune's Spire\""}, {a="touch"},
	{x=15.5,y=-3}, {x=36.2,y=-15.6},
	{a="f8"}, {target="Door:\"Neptune's Spire\""}, {a="touch"},
	{x=40,y=-17.8}, {x=42.5,y=-20.5}, {x=36,y=-34},
	{a="f8"}, {target="Door:Tenshodo H.Q."}, {a="touch"},
	{x=33,y=-40}, {x=39,y=-56},
	{a="f8"}, {target="Door:Tenshodo H.Q."}, {a="touch"},
	{x=37,y=-59}, {x=20,y=-51},
	{a="f8"}, {target="Door:Aldo's Room"}, {a="touch"},
	{x=18,y=-54}, {x=20.3,y=-60,d=1},
	{a="f8"}, {target="Aldo"}, {a="touch"}
    },
    -- HP (E)
    gob = { {x=-99.6,y=-183.4}, {x=-93.8,y=-150.4},
	{x=-72,y=-115,z=6}, {x=-62,y=-108}, {x=-59,y=-109},
	{target="Door:Muckvix's Junk Shop"}, {a="opendoor"},
	{x=-54,y=-112}, {x=-38,y=-116},
	{target="Door:Muckvix's Junk Shop"}, {a="opendoor"},
	{x=-35,y=-118}, {x=-44,y=-135},
	{target="Door:\"Goblins' Goblet\""}, {a="opendoor"},
	{x=-42,y=-137}, {x=-36,y=-136}, {x=-30,y=-138,z=5.5,d=1},
	{target="Muckvix"}, {a="touch"}
    },
    grey = { -- grayson (A.M.A.N.トローブ)
	{x=-99.6,y=-183.4,z=0}, {x=-98,y=-172,d=1},
	{x=-94,y=-167,z=0,d=1}, {a="f8"}, {target="Greyson"},
	{auto=true}, {wait=2}, {auto=false},
	{a="touch"}
    },
    nantoto = { -- エミネンスのタル娘
	{x=-99.6,y=-183.4,z=0}, {x=-95,y=-156},
	{x=-59,y=-90,z=6,d=1},
	{x=-39,y=-49,z=0}, {x=-41,y=-47,z=0},
	{x=-42.7,y=-48.5,z=0}, {a="f8touch"}
    },
}

M.essential_points = {
    hp1 = {x=-99.6,y=-183.4,z=0},
}

M.automatic_routes = {
    hp1 = {
	{ route="grey" },
	{ route="gob", contents="Mission" },
    },
}

return M
