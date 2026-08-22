-- 北サンドリア

local M = { id = 231 }

M.routes = {
    -- HP#2
    castle = {
	{x=10,y=94,z=-0.2,desc="ドラギーユ城"},
	{x=6,y=99}, {x=5,y=107}, {}
    },
    phantom = {
	{x=10,y=94,z=-0.2,desc="Trisvain(ファントムクォーツ)"},
	{x=26.5,y=85.7,z=-0.2},	{a="f8touch"}
    },
    -- HP#3(M)
    daiseido = {
	{x=69,y=9,z=-0.2,desc="大聖堂の入り口"},
	{x=80,y=60,d=1}, {x=92,y=81,d=1},
	{x=111.9,y=103.8},
    },
    papal = {
	{x=69,y=9,z=-0.2,desc="教皇の部屋"},
	{x=80,y=60,d=1}, {x=92,y=81,d=1},
	{x=111.9,y=103.8},
	--- 大聖堂の入り口
	{x=116,y=107,z=0}, {x=127,y=110,z=0}, {x=138,y=99,z=-6.5},
	{x=137,y=96,z=-6.5}, {x=134,y=96,z=-6.5},
	{x=124,y=105,z=-6.5}, {x=124,y=107,z=-6.5},
	{x=135,y=119,z=-11}, {x=135,y=121,z=-11},
	{x=132,y=123,z=-11,d=1}, {a="f8"},
	{target="Door:Papal Chambers"}, {a="touch"}
    },
    -- お城から
    castle_to_HP2 = {
	{x=0,y=108.6,z=-2}, {x=8,y=97,z=-0.3},
	{target="Home Point #2"}, {wait=2}, {a="touch"},
    },
}

M.essential_points = {
    hp2 = {x=10,y=94,z=-0.2},
    hp3_M = {x=69,y=9,z=-0.2},
    from_castle = {x=0,y=108.6,z=-2},
}

M.automatic_routes = {
    hp2 = {
	{ route="castle", contents="mission" },
	{ route="phantom" },
    },
    hp3_M = {
	{ route="daiseido" },
	{ route="papal", contents="mission" },
    },
    from_castle = { route="castle_to_HP2" },
}


return M
