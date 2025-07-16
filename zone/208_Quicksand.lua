-- 流砂洞

local M = { id = 208 }

M.routes = {
    -- 西アルテパ D-12 から
    ent = {
	{x=-738.9,y=-521.8,z=-16}, {x=-742,y=-576,z=-4}, {a="sneak"},
	{x=-744,y=-578}, {x=-776,y=-578}, {x=-778,y=-576},
	{x=-780,y=-460,z=-0.4},
    },
}

M.essentialPoints = {
    ent_d12 = {x=-738.9,y=-521.8,z=-16},
}

M.automatic_routes = {
    ent_d12 = "ent"
}

return M

