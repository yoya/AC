-- 震動の回廊

local M = { id = 209 }

M.routes = {
    -- HP#1 から
    proto = {  -- proto crystal
	{x=-581.1,y=-564,z=1}, {x=-578,y=-548}, {x=-564,y=-543},
	{x=-549,y=-540}, {x=-541,y=-533}, {x=-540.1,y=-497.9,z=1.9},
    },
}

M.essentialPoints = {
    entrance = {x=-581.1,y=-564,z=1},
}

M.automatic_routes = {
    entrance = { route="proto" },
}

return M
