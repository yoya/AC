-- ウィンダス港

local M = { id = 240 }

M.routes = {
    -- HP#1
    star = {
	{x=-188,y=100,z=-4,desc="スターオニオン団"},
	{x=-127,y=132,d=1}, {x=-100,y=138,d=1},
	{x=-61,y=136,d=1}, {x=-43,y=137}, {x=-18,y=119},
	{x=-4,y=120}, {x=2,y=129,d=1}, {x=-5,y=145,d=1},
	{x=-2,y=154}, {x=-1,y=183}, {x=-3,y=186},
	{x=-26.7,y=188.1,z=-6}, {a="f8touch"}
    },
    hakku = {
	{x=-188,y=100,z=-4,desc="Hakkuru-Rinkuru (口の院)"},
	{x=-162,y=110}, {x=-127,y=119},
	{target="Door:Orastery"}, {a="opendoor"}, {x=-122,y=119},
	{x=-113,y=106,z=-3.3},
	{target="Hakkuru-Rinkuru"}, {a="touch"}
    },
    -- HP#2(E)
    west = {
	{x=-208,y=209,z=-8,"西サルタバルタへ出る"},
	{x=-231,y=202}, {x=-244.5,y=198.5,z=-8}, {}
    },
    -- HP#3(M)
    yujuju = {
	{x=179,y=226,z=-12,desc="港前の Yujuju"},
	{x=199,y=216}, {x=204,y=193},
	{x=198,y=181}, {x=177.2,y=183.4}, {x=172,y=173},
	{x=173,y=159}, {x=199,y=141}
    },
}

M.essential_points = {
    hp1 = {x=-188,y=100,z=-4},
    hp2E = {x=-208,y=209,z=-8},
}

M.automatic_routes = {
    hp1 = { route="hakku", contents="mission" },  -- 口の院
    hp2E = { route="west" },
}

return M
