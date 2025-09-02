-- マウラ

local M = { id = 249 }

M.routes = {
    -- #HP(1)
    ambus = { -- アンバスケード
	{x=-12.7,y=86.3,z=-15.7},
	{x=-13,y=72,d=1}, {x=-16,y=69,d=1},
	{x=-34.2,y=58.1,z=-16},
	{x=-30,y=54,z=-16,d=1}, {a="f8touch"}
    },
    -- アンバスを出たとこ
    hp1 = { -- #HP(1) へ
	{x=-34.2,y=58.1,y=-16},
	{x=-16,y=69,d=1}, {x=-13,y=72,d=1},
	{x=-13,y=85.5}, {a="f8touch"}
    },
}

M.essentialPoints = {
    hp1 = {x=-12.7,y=86.3,z=-15.7},
    from_legion = {-34.2,y=58.1,y=-16},
}

M.automatic_routes = {
    hp1 = { route="ambus", leader_only=true},
}

return M
