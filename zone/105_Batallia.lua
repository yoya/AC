-- バタリア丘陵

local M = { id = 105 }

M.routes = {
    vw = { -- voidwatch NPC
	{x=486.3,y=-157.7,z=8.3}, {x=427,y=-145},
	-- 共通
	{x=428,y=-140}
    },
    pec = { -- 珍妙なモンスター
	{x=486.3,y=-155.5,z=8.3}, {x=427,y=-145}, {a="mount"},
	{x=399.8,y=-124.6}, {x=335.1,y=-69.9},
	{x=234.2,y=70.5}, {a="dismount"}
    },
}

M.essentialPoints = {
    from_jueno = {x=486.3,y=-163.3,z=8.3},
}

M.automatic_routes = {
    from_jueno = { route="vw" },
}

return M
