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
    }
}

M.essential_points = {
    entrance = {x=579.6,y=-637,z=-24},
}

M.automatic_routes = {
    entrance = { route="gizmo" },
}

return M

