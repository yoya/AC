-- ラ・カザナル宮外郭〔Ｕ２〕

local M = { id = 133 }

M.routes = {
    common = {
	{x=-940,y=-20,z=-191.5,desc="入り口から分かれ道まで"},
	{x=-923,y=-20}, {faith="raise"}, {x=-864,y=-20}
    },
    -- はじめの分かれ道
    north = {
	-- {x=-940,y=-20,z=-191.5}, {route="common"},
	{x=-864,y=-20},
	{x=-861,y=-71,desc="北へ"}, {x=-855,y=138}, {x=-837,y=-140}
    },
}
M.essentialPoints = {
    entrance = {x=-940,y=-20,z=-191.5}, -- 入り口
}

M.automatic_routes = {
    entrance = { route="common" },
    -- entrance = { route="north" },
}

return M
