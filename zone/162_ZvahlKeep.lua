-- ズヴァール城内郭

local M = { id = 162 }

M.routes = {
    -- 外郭(bails)から
    common = {
	{x=62,y=-20.4,z=0}, {x=-20,y=-19,z=0},
    },
    thro = {  -- 王の間へ
	{x=62,y=-20.4,z=0}, {x=-20,y=-19,z=0},
	-- 共通
	{x=-24,y=-15}, {x=-29,y=17},
	{x=-30,y=37}, {a="opendoor"}, {x=-30,y=45},
	{x=-14,y=54},
	{x=-11,y=75}, {a="esc"}, {a="enter"}, {a="enter"}, {x=-10,y=82},
	{x=-12,y=87},
	{x=-16,y=89}, {a="esc"}, {a="enter"}, {a="enter"}, {x=-21,y=90},
	{x=-35,y=90}, {a="esc"}, {a="enter"}, {a="enter"}, {x=-41,y=90},
	{x=-50,y=91},
	{x=-50,y=96}, {a="esc"}, {a="enter"}, {a="enter"}, {x=-50,y=101},
	{x=-51,y=108},
    },
}

M.essentialPoints = {
    from_bails = { x=62,y=-20.4,z=0 },
}

M.automatic_routes = {
    from_bails = { route="common" }
}

return M
