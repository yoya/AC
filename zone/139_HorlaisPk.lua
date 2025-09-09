-- ホルレーの岩峰

local contents = require 'contents'

local M = { id = 139 }

M.routes = {
    -- 入り口
    circle = {
	{x=-536,y=-211.6,z=160.5}, {x=-518,y=-210,d=1},
	{x=-508.4,y=-211.6,z=158.6,d=1},
    },
    -- AMAN トローブ
    trove = {
	{x=-316.3,y=-102.5}, {x=-346.8,y=-127},
	{x=-366,y=-121.7}, {x=-381,y=-98},
	{x=-392.9, y=-71.3},
    },
    trove2 = {  -- AMAN トローブ
	{x=-75.3,y=77.4}, {x=-107.26, y=52.38},
	{x=-131,y=64}, {x=-147,y=95},
	{x=-152.9,y=108.5}
    },
    trove3 = {  -- AMAN トローブ
	{x=163.6,y=257.2}, {x=133.2,y=232.6},
	{x=110.6,y=242.9}, {x=92.6,y=276.5}, {x=87.1,y=288.4}
    },
}

function M.warp_in()
    if M.parent.isNear(139, "entrance", 10) then
	contents.type = contents.Trove
    end
end

M.essentialPoints = {
    entrance = {x=-536,y=-211.6,z=160.5},  -- ホルレーに入ったところ
    -- トローブ
    trove_in = {x=-316.3, y=-102.6,z=113.1,w=15},
    trove2_in = {x=-75.3,y=77.4,z=-7.1},
    trove3_in = {x=163.6,y=257.2},
}

M.automatic_routes = {
    entrance = { route="circle" },
    trove_in = { route="trove" },
    trove2_in = { route="trove2" },
    trove3_in = { route="trove3" },
}

return M

