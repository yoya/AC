-- アビセア-コンシュタット

local M = { id = 15 }

function M.zone_in()
    local contents = require 'contents'
    contents.set_zone_override(contents.Abyssea)
end

M.routes = {
    conf = {
	{x=154.5,y=-840,z=-72}, {x=130.4,y=-826},
	{x=131,y=-825.5}, {a="f8touch"}
    },
}

M.essential_points = {
    entrance = {x=154.5,y=-840,z=-72},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

return M
