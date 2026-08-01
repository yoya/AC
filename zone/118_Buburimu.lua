-- ブブリム半島

local M = { id = 118 }

M.routes = {
    maw = {  --  アビセア扉
	{x=-341.8,y=50.2,z=-24,desc="Cavernous Maw"}, {wait=2},
        {target="Cavernous Maw"},
	{a="touch"}, {wait=1}, {a="up"}, {a="touch"}
    },
}

M.essential_points = {
    from_jueno = {x=-341.8,y=50.2,z=-24},
}

M.automatic_routes = {
    from_jueno = { route="maw" },
}

return M
