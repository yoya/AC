-- アビセア-ミザレオ

local M = { id = 216 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_zone_override(contents.Abyssea)
end

M.routes = {
    conf = {
	{x=657.2,y=316.3,z=-15.1}, {x=644.1,y=317.4},
	{x=642.8,y=319.4}, {a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=657.2,y=316.3,z=-15.1},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M
