-- アビセア-ブンカール

local M = { id = 217 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_zone_override(contents.Abyssea)
end

M.routes = {
    conf = {
	{x=-351.3,y=699.8,z=-46.3}, {x=-339.7,y=696.7},
	{x=-318.5,y=680.9}, {x=-317.2,y=682.4},
	{a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=-351.3,y=699.8,z=-46.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M
