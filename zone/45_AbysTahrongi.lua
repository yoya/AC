-- アビセア-タロンギ

local M = { id = 45 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_zone_override(contents.Abyssea)
end

M.routes = {
    conf = {
	{x=-23.1,y=-677.4,z=44.3}, {x=-1.7,y=-678.4},
	{x=0,y=-680.3}, {a="f8touch"}, {wait=1},
	-- ビジタントをつける
	{keys={"right", "enter", "right", "enter", "up", "enter", "up", "enter"}}, {wait=2},
	{x=9,y=-635,z=31.3}, {target="Veridical Conflux #01"}, {a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=-23.1,y=-677.4,z=44.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M
