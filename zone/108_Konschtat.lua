-- コンシュタット高地

local M = { id = 108 }

M.routes = {
    -- D.デムリング
    gusgen = { -- グスゲン鉱山へ
	{x=220,y=130,z=19.6}, {x=223,y=141,z=19.1},
	{a="mount"}, {x=289,y=129,d=1}, {x=518,y=167,d=1},
	{x=565,y=172,d=1}, {x=640,y=160,d=1}, {x=663,y=166,d=1},
	{x=678,y=184,d=1}, {x=687,y=206}, -- {x=697,y=214},
	{x=705,y=217}, {}
    },
}

M.essentialPoints = {
    ring = {x=220,y=130,z=19.6},
}

M.automatic_routes = {
    -- hp1 = { route="nana" },
}

return M
