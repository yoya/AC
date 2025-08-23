-- アブダルスの模型-レギオン

local M = { id = 183 }

local contents = require('contents')

function M.zone_in()
    print("Ambus in")
    contents.type = contents.Ambus
end

function M.zone_out()
    print("Ambus out")
    contents.type = contents.Idle
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
