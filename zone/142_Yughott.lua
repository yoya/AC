-- ユグホトの岩屋

local M = { id = 142 }

M.routes = {
    -- 温泉から入ったところ
    horl = { -- ホルレー
	{x=437.6,y=68.1,z=-40.1},
	{x=429,y=64}, {x=426,y=67.5}, {x=421,y=92},
	{x=410,y=109},{x=405.5,y=125}, {x=403,y=130},
	{x=415,y=146}, {x=427,y=154}, {x=436,y=169},
	--{x=439.8,y=170.1,z=-40}, {}
	{x=441,y=170,z=-40}, {}
    },
}

M.essentialPoints = {
    homepoint_1 = {x=434,y=170,z=-40.1},
}

M.automatic_routes = {
    homepoint_1 = "horl"
}

return M

