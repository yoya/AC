-- アビセア-ラテーヌ

local M = { id = 132 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_contents(Abyssea)
end

M.routes = {
    conf = {
	{x=-480,y=792,z=0.2}, {x=-476,y=785.1},
	{x=-472.9,y=785.4}, {a="f8touch"}, {wait=1},
	-- ビジタントをつける
	{keys={"right", "enter", "right", "enter", "up", "enter", "up", "enter"}}, {wait=2},
	{x=-479,y=775,z=0.6}, {target="Veridical Conflux #01"}, {a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=-480,y=792,z=0.2},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

M.essential_items = {
    2894, -- 戦勝の盾
    2895, -- 大型靴下
    2896, -- 超重量腕輪
}
M.essential_key_items = {
    1482, -- 破られたギガースの盾
    1483, -- 潰れたギガースの腕輪
    1484, -- 断ち切られたギガースの首飾り
}
return M
