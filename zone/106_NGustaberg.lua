-- 北グスタベルグ

local M = { id = 106 }

M.routes = {
    maw = {  --  アビセア扉
	{wait=3},
        {x=-72.9,y=600.1,z=-0.1}, {target="Cavernous Maw"},
	{a="touch"}, {a="up"}, {a="touch"}
    },
}

M.essentialPoints = {
    from_jueno = {x=-72.9,y=600.1,z=-0.1},
}

M.automatic_routes = {
    from_jueno = { route="maw" },
}

return M
