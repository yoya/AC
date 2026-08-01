-- 北グスタベルグ

local M = { id = 106 }

M.routes = {
    maw = {  --  アビセア扉
	{x=-72.9,y=600.1,z=-0.1,desc=""}, {wait=2},
        {target="Cavernous Maw"},
	{a="touch"}, {wait=1}, {a="up"}, {a="touch"}
    },
}

M.essential_points = {
    from_jueno = {x=-72.9,y=600.1,z=-0.1},
}

M.automatic_routes = {
    from_jueno = { route="maw" },
}

return M
