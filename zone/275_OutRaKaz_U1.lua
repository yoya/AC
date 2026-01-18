-- ラ・カザナル宮外郭〔Ｕ１〕

local M = { id = 275 }

function M.zone_in()
    print("Vagary in")
    contents.type = contents.Vagary
end

function M.zone_out()
    print("Vagary out")
    contents.type = contents.Idle
end

M.routes = { }

M.essentialPoints = {
    -- アシュラック入り口
    asyu = {x=864,y=300,z=69.8},
    -- バラモア入り口 z=110 の時ある？
    bara={x=258,y=-660,z=100},
    -- ドクマク
    doku={x=300,y=-660,z=100},
}

M.automatic_routes = { }

function M.tick(player)
    print(player)
end

return M
