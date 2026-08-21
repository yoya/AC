-- 慟哭の谷

local M = { id = 128 }

M.routes = {
    titan = {
	{x=-167,y=23,z=-8,desc="[I-8] 陸の王の小像(サンドリアM)"},
	{x=-142,y=19}, {faith="balance"}, {a="mount"},
	{x=-132,y=8}, {x=-110,y=-29}, {x=-96,y=-35},
	{x=-58,y=-25}, {x=29,y=-6}, {x=84,y=-11}, {a="dismount"},
	{x=90,y=-15,z=-3.1}, {target="???"}, {a="touch"}
    },
}

M.essential_points = {
    book = {x=-167,y=23,z=-8},
}

M.automatic_routes = {
    book = { route="titan", contents="mission" }
}

return M

