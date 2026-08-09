-- アビセア-アルテパ

local M = { id = 218 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_zone_override(contents.Abyssea)
end

M.routes = {
    conf = {
	{x=430,y=320,z=0.3}, {x=424.4,y=326.9},
	{x=410.1,y=328.6}, {x=410.4,y=330},
	{a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=430,y=320,z=0.3},
}

M.automatic_routes = {
    entrance = { route="conf"},
}

return M
