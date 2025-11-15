-- トライマライ水路

local M = { id = 169 }

M.routes = {
    -- HP#1 開始
    moon = { -- 満月の泉
	{x=-257.5,y=81,z=24},{x=-259,y=84,z=24}, {}
	--{x=-258,y=83,z=24}, {}
    }
}

M.essentialPoints = {
    hp1 = {x=-257.5,y=81,z=24},
}

M.automatic_routes = {
    hp1 = { route="moon" },
}

return M
