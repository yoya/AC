-- 外ホルトト遺跡

local M = { id = 194 }

M.routes = {
    gizmo = {
	{x=579.6,y=-637,z=-24},
	{x=579,y=-656,z=-20.5}, {x=575,y=-659,z=-19.7},
	{x=468,y=-662,z=0}, {x=465,y=-664,z=0},
	{x=465,y=-687,z=0}, {x=472,y=-694}, {x=529,y=-694},
	{x=543,y=-679}, {x=546,y=-661},
	{target="Cracked Wall"}, {a="opendoor"}, {x=550,y=-660},
	{x=588,y=-660,z=0}, {target="Gate: Magical Gizmo"},
	{a="touch"}
    },
    xxx = {
	{x=579.6,y=-637,z=-24,desc="ウィンダスM 満月の泉"},
	{x=-578,y=-651}, {faith="balance"}, {x=-571,y=-658},
	-- 階段を降りる
	{x=-509,y=-662,z=0}, {x=-502,y=-668},
	{x=-498,y=-691}, {x=-491,y=-698},
	{x=-469,y=-698}, {x=-462,y=-691},
	{x=-458,y=-629}, {x=-451,y=-622},
	{x=-429,y=-622}, {x=-422,y=-629},
	{x=-417,y=-652}, {x=-412,y=-658},
	{touch="Cracked Wall"}, {wait=1},
	{x=-408,y=-660}, {x=-339,y=-660},
	{touch="Cracked Wall"}, {wait=1},
	{x=-334,y=-660}, {x=-292,y=-660},
	{target="Gate: Magical Gizmo"},
    }
}

M.essential_points = {
    entrance = {x=579.6,y=-637,z=-24},
    from_F11 = {x=-580,y=-637,z=-8},
}

M.automatic_routes = {
    entrance = { route="gizmo" },
    from_F11 = { route="xxx" },
}

return M

