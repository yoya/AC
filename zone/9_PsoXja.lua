-- ソ・ジヤ

local M = { id = 9 }

M.routes = {
    shroud = {
	{x=-58,y=15,z=40,desc="ShroudMaw(異界の口)"},
	{x=-60.7,y=5,z=40}, {}
    },
}

M.essentialPoints = {
    hp_1 = {x=-58,y=15,z=40},
}

M.automatic_routes = {
    hp_1 = { route="shroud" },
}

return M
