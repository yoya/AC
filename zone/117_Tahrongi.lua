-- タロンギ大峡谷

local M = { id = 117 }

M.routes = {
    -- D.メアリング
    ring2dim = {
	{x=270,y=340,z=35.7,desc="Dimensional Portal(醴泉島)"},
	{x=263,y=340,z=35.2,d=1}, {wait=2},
	{target="Dimensional Portal"}, {a="touch"}
    },
}

M.essentialPoints = {
    ring = {x=270,y=340,z=35.7},
}

M.automatic_routes = {
    ring = { route="ring2dim" }
}

return M
