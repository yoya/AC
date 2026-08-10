-- ラ・カザナル宮外郭〔Ｕ１〕


local M = { id = 275 }

function M.zone_in()
    print("Vagary in")
    -- 場所によってはソーティもあるので、一旦なくす
    --[[
    local contents =  __AC.contents
    contents.set_zone_override(contents.Vagary)
    ]]
end

function M.zone_out()
    print("Vagary out")
    --[[
    local contents =  __AC.contents
    contents.clear_zone_override()
    ]]
end

M.routes = { }

M.essential_points = {
    -- アシュラック入り口
    asyu = {x=864,y=300,z=69.8},
    -- バラモア入り口 z=110 の時ある？
    bara={x=258,y=-660,z=100},
    -- ドクマク
    doku={x=300,y=-660,z=100},
}

M.automatic_routes = { }

function M.tick(player)
    print("sortie??? zone 275!!!!")
end

return M
