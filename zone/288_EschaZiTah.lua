-- エスカ-ジ・タ

local M = { id = 288 }

M.routes = {
    -- 入り口 from クフィム
    affi = {
	{x=-345.4,y=-178.9,z=1.1}, {x=-353.6,y=-172.3,z=-0.1},
	{w=3}, {a="esc"}, {target="Affi"}, {a="touch"},
    },
    dahaka = {
	{x=-2,y=59.5,z=1}, {x=-8,y=46}, -- {x=2,y=37,z=0,d=4},
	-- {x=0,y=35,z=0,d=3},
	{x=2,y=38,z=0,d=2},  -- 右足小指
	-- {x=-5,y=38,z=0.1,d=2},  -- 左足小指
	{enemy_filter="Azi"}, {puller=true}
    },
}

M.essentialPoints = {
    entrance = {x=-345.4,y=-178.9,z=1.1},
    domain_in = {x=-2,y=59.5,z=1},
}

M.automatic_routes = {
    entrance = { route="affi" },
    domain_in = { route="dahaka"},  -- Azi Dahaka
}
    
return M
