-- ラ・カザナル宮外郭〔Ｕ１〕


local M = { id = 275 }

M.origContentType = nil

function M.zone_in()
    local contents =  __AC.contents
    print("Vagary in")
    -- 場所によってはソーティもあるので、一旦なくす
    --[[
    M.origContentType = contents.type
	contents.set_type(contents.Vagary)
    ]]
end

function M.zone_out()
    local contents =  __AC.contents
    print("Vagary out")
    --[[
    if M.origContentType ~= nil then
	contents.set_type(M.origContentType)
	M.origContentType = nil
	end
    ]]
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
    print("sortie??? zone 275!!!!")
end

return M
