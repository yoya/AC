-- アブダルスの模型-レギオンB

local M = { id = 287 }

function M.zone_in()
    print("Ambus in")
    local contents = __AC.contents
    contents.setType(contents.Ambus)
end

function M.zone_out()
    print("Ambus out")
    local contents = __AC.contents
    contents.setType(contents.Idle)
end

M.routes = {
}

M.essentialPoints = {
    entrance = {x=137,y=-137,z=12.5},
}

M.automatic_trust = {
    "ヴァレンラール", "モンブロー", "セルテウス",
}

M.automatic_routes = {
}

return M
