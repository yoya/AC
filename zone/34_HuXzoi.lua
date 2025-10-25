-- フ・ゾイの王宮

local M = { id = 34 }

M.routes = {
    -- 入り口
    nextdoor = {  -- 入り口からまっすぐ行ったドア
	{x=-20,y=-355,z=0.6}, {x=-20,y=-285,z=0},
    },
}

M.essentialPoints = {
    entrance = {x=-20,y=-355,z=0.6},
}

M.automatic_routes = {
    entrance = { route="nextdoor" },
}

return M
