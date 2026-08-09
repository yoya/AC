-- タロンギ大峡谷

local M = { id = 117 }

M.routes = {
    -- D.メアリング
    ring2dim = {
	{x=270,y=340,z=35.7,desc="Dimensional Portal(醴泉島)"},
	{x=263,y=340,z=35.2,d=1}, {wait=2},
	{target="Dimensional Portal"}, {a="touch"}
    },
    maw = {
        {x=-28.7,y=-682.3,z=46.2,desc="Cavernous Maw(アビセア扉)"}, {wait=2},
        {target="Cavernous Maw"},
        {a="touch"}, {wait=1}, {a="up"}, {a="touch"}
    },
}
M.essential_points = {
    ring = {x=270,y=340,z=35.7},
    from_jueno = {x=-28.7,y=-682.3,z=46.2},
}

M.automatic_routes = {
    ring = { route="ring2dim" },
    from_jueno = { route="maw" },
}

return M
