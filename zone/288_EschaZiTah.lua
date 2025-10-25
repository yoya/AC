-- エスカ-ジ・タ

local M = { id = 288 }

M.routes = {
    -- 入り口 from クフィム
    affi = {
	{x=-345.4,y=-178.9,z=1.1}, {x=-353.6,y=-172.3,z=-0.1},
	{w=3}, {a="esc"}, {a="touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-345.4,y=-178.9,z=1.1},
}

M.automatic_routes = {
    entrance = { route="affi" },
}
    
return M
