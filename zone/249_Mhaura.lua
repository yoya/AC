-- マウラ

local M = { id = 249 }

M.routes = {
    -- #HP(1)
    ambus = { -- アンバスケード
	{x=-12.7,y=86.3,z=-15.7},
	{x=-13,y=72,d=1}, {x=-16,y=69,d=2},
	{x=-21,y=64,d=2},
	{x=-27,y=56,d=1},
	{target="Ambuscade Tome"}, {a="touch"}
    },
    -- アンバスを出たとこ
    hp1 = { -- #HP(1) へ
	{x=-34.2,y=58.1,y=-16},
	{x=-16,y=69,d=1}, {x=-13,y=72,d=1},
	{x=-13,y=85.5}, {target="Home Point #1"}
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
