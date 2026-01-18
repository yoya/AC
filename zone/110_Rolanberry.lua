-- ロランベリー耕地

local M = { id = 110 }

M.routes = {
    maw = {  -- 過去扉
	{x=-228,y=387,z=4.5}, {x=-217,y=379},
	{x=-198,y=360,z=8},
    },
}

M.essentialPoints = {
    book = {x=-228,y=387,z=4.5},
}

M.automatic_routes = {
    book = { route="maw" },
}

return M
