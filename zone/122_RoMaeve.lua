-- ロ・メーヴ

local M = { id = 122 }

M.routes = {
    -- 本ワープ
    gods = {
	{x=14,y=54,z=-28.1,desc="神々の間へ"},
	{x=17,y=76,d=1},{x=1,y=106,z=-28.4,d=1}, {x=1,y=122,z=-32,d=1},
	{x=0.4,y=123.5,z=-32.1}, {}
	
    },
}

M.essentialPoints = {
    book = {x=14,y=54,z=-28.1}
}

M.automatic_routes = {
    book = { route="gods" },
}

return M
