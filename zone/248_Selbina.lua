-- セルビナ

local M = { id = 248 }

M.routes = {
    -- HP#1
    conf = {
	{x=35.1,y=33.6,z=-10.7,desc="Veridical Conflux (女神BC)"},
	{x=28,y=34}, {x=22,y=38,z=-10.6}, {x=17,y=58,z=-14.5},
	{x=11,y=69,z=-14.6,d=2}, {target="Veridical Conflux"}, {a="touch"}
    },
}

M.essentialPoints = {
    hp1 = {x=35.1,y=33.6,z=-10.7},
}

M.automatic_routes = {
    hp1 = { route="conf" },
}

return M

