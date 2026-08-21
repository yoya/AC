-- バタリア丘陵

local M = { id = 105 }

M.routes = {
    -- ジュノから
    vw = {
	{x=486.3,y=-157.7,z=8.3, desc="VoidWatch NPC"},
	{x=427,y=-145},
	-- 共通
	{x=428,y=-140}
    },
    pec = {
	{x=486.3,y=-155.5,z=8.3,desc="珍妙なモンスター"},
	{x=427,y=-145}, {a="mount"},
	{x=399.8,y=-124.6}, {x=335.1,y=-69.9},
	{x=234.2,y=70.5}, {a="dismount"}
    },
    -- book
    book2jug = {
	{x=-67,y=448,z=-1.5,desc="本からジャグナーへ"},
	{x=-86,y=436}, {a="mount"},
	{x=-104,y=421}, {x=-143,y=380}, {x=-192,y=289},
	{x=-240,y=214}, {x=-248,y=200}, {x=-296,y=107},
	{x=-350,y=26}, {x=-375,y=-56}, {x=-397,y=-119},
	{x=-407,y=-206}, {x=-420,y=-226},
	{x=-439.4,y=-242.2,z=-8}, {}
    },
    -- eldieme
    levi = {
	{x=166.4,y=-603.4,z=24.2,desc="海の王の小像(サンドリアM)"},
	{x=169,y=-592}, {x=179,y=-581}, {x=188,y=-584},
	{x=207,y=-606}, {x=214,y=-610}, {x=213,y=-612,z=16.5},
	{target="???"} -- , {a="touch"}
    },
}

M.essential_points = {
    from_jueno = {x=486.3,y=-163.3,z=8.3},
    book = {x=-67,y=448,z=-1.5},
    from_jugner = {x=-439.4,y=-242.2,z=-8},
    from_eldieme = {x=166.4,y=-603.4,z=24.2},
}

M.automatic_routes = {
    from_jueno = { route="vw" },
    from_eldieme = { route="levi", contents="mission"},
}

return M
