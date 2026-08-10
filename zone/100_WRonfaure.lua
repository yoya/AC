-- 西ロンフォール

local M = { id = 100 }

M.routes = {
    -- book
    --    lathe = {
    xxx = {
	{x=-451.6,y=-218,z=-19.9,desc="ラテーヌへ移動"},
	{x=-452,y=-229}, {a="mount"}, {x=-464,y=-237},
	{x=-471,y=-339}, {x=-489,y=-380}, {x=-504,y=-410},
	{x=-516,y=-438}, {x=-535,y=-473}, {x=-540,y=-486},
	{x=-538,y=-540}, {x=-556,y=-581}, {x=-558.2,y=-602.5,z=-0.1}, {}
    },
}

M.essential_points = {
    book = { x=-451.6,y=-218,z=-19.9 },
}
    
M.automatic_routes = {
    -- ルート側が xxx に改名されていて lathe は存在しない。
    -- 実質無効だったので、無効だと分かる形にしておく
    book = { route="lathe", disabled=true },
}

return M
