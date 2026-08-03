-- アブダルスの模型-レギオン

local M = { id = 183 }


function M.zone_in()
    print("Ambus in")
    local contents = __AC.contents
    contents.set_zone_override(contents.Ambus)
end

function M.zone_out()
    print("Ambus out")
    local contents = __AC.contents
    contents.clear_zone_override()
end

M.routes = {
}

M.essential_points = {
    entrance = {x=137,y=-137,z=12.5},
}

M.automatic_trust = {
    "ヴァレンラール", "モンブロー", "セルテウス",
}

M.automatic_routes = {
}

return M
