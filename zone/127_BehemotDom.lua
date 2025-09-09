-- ベヒーモスの縄張り

local M = { id = 127 }

local io_net = require 'io/net'

M.routes = {
    -- CL135 ワープ
    frag = { -- 雷の祈り (古代石碑巡礼)
	{x=-183.1,y=57.9,z=-19.9}, {x=-222.5,y=32}, {a="mount"},
	{x=-237,y=2.7}, {x=-235,y=-6}, {x=-218,y=-18},
	{x=-171,y=-21}, {x=-155.5,y=-19.5}, {x=-143,y=-21.5},
	{x=-108,y=-20.5}, {x=-102,y=-25}, {x=-98,y=-47.5},
	{x=-80.5,y=-79}, {a="dismount"}, {x=-75.6,y=-88,z=-4},
    },
    wanted = { -- ベヒモス
	{x=-183.1,y=57.9,z=-19.9}, {x=-197.5,y=59.5},
	{x=-219,y=67,d=1}, {x=-262.5,y=73.3,z=-19.4,d=2},
    },
}

M.essentialPoints = {
    unity_warp = {x=-183.1,y=57.9,z=-19.9},
    wanted = {x=-269.2,y=74.2,z=-19.8},
}

M.automatic_routes = {
    unity_warp = { route="wanted" },
}

function M.tick(player)
    local mobArr = windower.ffxi.get_mob_array()
    -- ウォンテッド???の近くにいる時、??? が現れたらターゲットする
    if M.parent.isNear(127, "wanted", 20) then
	for i, m in pairs(mobArr) do
	    if m.name == "???" and m.status == 0 then
		io_net.targetByMobId(m.id)
	    end
	end
    end
end


return M

