-- シルバー・ナイフ

local M = { id = 283 }

M.routes = {
    gama = {
	{x=-44.5,y=46,z=-0.7,desc="Gama-Shama (プライムウェポン仲介人)"},
	{x=-41,y=46,z=-0.6,d=1}, {x=-40,y=44,z=-0.6,d=1},
	-- 階段を降りる
	{x=-40,y=40,z=1.4}, {x=-42,y=38,z=1.3,d=1},
	{x=-44,y=39,z=1.3,d=1}, {x=-44,y=41,z=1.4,d=1},
	{target="Gama-Shama"}, {a="touch"},
    },
}

M.essential_points = {
    entrance = {x=-44.5,y=46,z=-0.7},
}

M.automatic_routes = {
    entrance = { route="gama"},
}

return M
