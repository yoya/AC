-- アビセア-アットワ

local M = { id = 215 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_zone_override(contents.Abyssea)
end

M.routes = {
    conf = {
	{x=-139.2,y=-180.6,z=20.3}, {x=-144.7,y=-178.8},
	{x=-146.3,y=-176.9,d=1}, {a="f8touch"}, {wait=3},
	-- ビジタントをつける
	{keys={"right", "enter", "right", "enter", "up", "enter", "up", "enter"}}, {wait=2},
	{x=-140,y=-204,d=1}, {target="Veridical Conflux #01"}, {a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=-139.2,y=-180.6,z=20.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M
