-- ゴユの空洞

local M = { id = 129 }

M.routes = {
    green = {  -- NPC に話しかけるとこまで。あとは手動
	{x=-152.9,y=-62,z=-1}, {x=-143,y=-60}, {x=-140,y=-71},
	{x=-137.7,y=-86.5,z=-0,6},
	{a="esc"}, {wait=1}, {a="touch"}, {a="touch"}
    },
    blue = {
	{x=-236.2,y=-122.6,z=-0.2}, {x=-245,y=-116},
	{target="Antje"}, {a="enter"}, {wait=5},
	{a="enter"}, {wait=3},
	{x=-223,y=-143}, {x=-223,y=-143}, {x=-213,y=-185},
	{x=-196,y=-197}, {x=-173,y=-205},
	-- 1
	{x=-173.2,y=-209.6}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-163,y=-214}, {x=-151,y=-231}, {x=-141,y=-237}, {x=-132,y=-233},
	-- 2
	{x=-124,y=-231.8}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=-103,y=-265}, {x=-94,y=-303}, {x=-77,y=-325,z=0},
	-- 3
	{x=-66.1,y=-328.8,z=-3.4}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-49,y=-302}, {x=-48,y=-287},
	-- 4
	{x=-41.6,y=-273.6}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=-15,y=-259}, {x=6,y=-238,z=0}, {x=4,y=-226,z=-3.1},
	-- 5
	{x=-1.4,y=-228.7,z=-3.6}, {target="7th Cohors Engineer"}, {a="enter"},
	
	{x=-17,y=-207,z=-4}, {x=-34,y=-207,z=0.3}, {x=-56,y=-178},
	-------
	-- 6
	{x=-66.2,y=-140.9,z=0.1}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=-56,y=-178}, {x=-48,y=-188}, {x=-29,y=-185},
	-- 7
	{x=-5.2,y=-173.1,z=-2.6}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=39,y=-164,z=0}, {x=71,y=-159,z=0.2}, {x=73,y=-153,z=0.1},
	-- 8
	{x=46.4,y=-150.2,z=-4.2}, {target="2nd Legion Scout"}, {a="enter"},
	{x=35,y=-133},
	{x=26,y=-93},  -- 虎回避
	-- 9
	{x=32.1,y=-75.5,z=-0.2}, {target="2nd Legion Scout"}, {a="enter"},
	{x=26,y=-93},  -- 虎回避 {x=30,y=-94},
	{x=16,y=-100}, {x=-14,y=-103},
	-- 10
	{x=-21,y=-107.4,z=-0.2}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=-20,y=-86}, {x=-23,y=-66}, {x=-19,y=-42}, {x=-12,y=-17},
	-- 11
	{x=1.6,y=-3,z=-10}, {target="2nd Legion Scout"}, {a="enter"},
	{x=2,y=5}, {x=16,y=23}, {x=20,y=55},
	-- 12
	{x=23,y=85.1}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=14,y=96}, {x=-13,y=104}, {x=-18,y=113}, {x=-25,y=134},
	{x=-34,y=139}, {x=-56,y=136},
	-- 13
	{x=-76,y=125,z=0}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-129,y=134}, {x=-137,y=140},
	-- 14
	{x=-138.5,y=149.6,z=0.1}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-148,y=132}, {x=-165,y=133},
	-- 15
	{x=-189.2,y=139.4,z=-0.2}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-165,y=133}, {x=-151,y=126,z=-0.4}, {x=-153,y=112,z=0.1},
	-- 16
	{x=-124.8,y=107.8,z=-3.4}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=-116,y=92}, {x=-90,y=19}, {x=-87,y=12}, {x=-79,y=6},
	-- 17
	{x=-65.9,y=18.2,z=0}, {target="7th Cohors Engineer"}, {a="enter"},
	-- 18 (19 の 2nd とごっちゃになりやすい)
	{x=-79.5,y=-17.1,z=1}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-99,y=-1},
	-- 19
	{x=-124.4,y=-0.3,z=0}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-160,y=-4},
	-- 20
	{x=-175.5,y=-19.9,z=-0.4}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-160,y=-1}, {x=-163,y=6}, {x=-179,y=8},
	-- 21
	{x=-212,y=16,z=0.5}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-211,y=-7},
	{x=-204,y=-22}, {x=-210,y=-36}, {x=-217,y=-38},
	-- 22
	{x=-236.2,y=-33,z=0.3}, {target="7th Cohors Engineer"}, {a="enter"},
	{x=-212,y=-47}, {x=-163,y=-61},
	-- 23
	{x=-145,y=-58.3,z=-1.8}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-139,y=-70}, {x=-146,y=-102}, {x=-158,y=-116},
	-- 24
	{x=-160.6,y=-130.1,z=-0.4}, {target="2nd Legion Scout"}, {a="enter"},
	{x=-168,y=-122}, {x=-172,y=-112}, {x=-182,y=-104}, {x=-196,y=-102},
	{x=-209,y=-103}, {x=-244.1,y=-112.8,z=-0.3},
	{target="Antje"}, {a="enter"}, {wait=5},
    },
}

M.essentialPoints = {
    green_in = {x=-152.9,y=-62,z=-1},
    blue_in = {x=-236.2,y=-122.6,z=-0.2},
}

M.automatic_routes = {
    green_in = { route="green" },
    blue_in = { route="blue" },
}

return M
