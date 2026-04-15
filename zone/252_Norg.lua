-- ノーグ

local M = { id = 252 }

M.routes = {
    gilga = { {x=-25.9,y=-46.2}, {x=6.9,y=-2.4},
	{x=40,y=-0.2}, {x=52.4,y=-2.4}, {x=73.4,y=-9.9},
	{x=99.4,y=-9.4}, {a="esc"}, {target="Oaken Door"},
	{a="touch"}
    },
    oseem = { {x=-25.9,y=-46.2}, {x=-5.8,y=-20.1}, {x=1,y=-4},
	{x=13.2,y=22.4}
    },
    foot_of_stairs = {
	{x=-25.9,y=-46.2}, {x=0,y=-11},
    }
}

M.essentialPoints = {
    hp_1 = {x=-25.9,y=-46.2},
}

M.automatic_routes = {
    hp_1 = { route="foot_of_stairs" },
    -- hp_1 = { route="gilga" },
}

return M
