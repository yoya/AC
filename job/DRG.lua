-- 竜騎士

local M = {}

local actask = require 'task'
local ac_equip = require 'ac/equip'

M.mainJobProbTable = {
    { 10, 60*20, 'input /ja コールワイバーン <me>', 2 },
    { 10, 60*1, 'input /ja ジャンプ <t>', 2 },
    { 10, 60*1.5, 'input /ja スピリットリンク <me>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <t>', 2 },
    { 10, 60*3, 'input /ja スーパージャンプ <t>', 2 },
    { 10, 60*3, 'input /ja スピリットボンド <me>', 2 },
    { 10, 60*5, 'input /ja ディープブリージング <t>', 2 },
    { 10, 60, 'input /ja スピリットジャンプ <t>', 2 },
    { 10, 60*2, 'input /ja ソウルジャンプ <t>', 2 },
}

M.subJobProbTable = {
    { 10, 60*1, 'input /ja ジャンプ <t>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <t>', 2 },
}

function M.main_tick(player)
    local c_angon = 'input /ja アンゴン <t>'
    if player.status == 1 then
	-- アンゴンを装備している時に使用する
	local item_id = ac_equip.equip_item_by_slot_name("ammo")
	if item_id == 18259 then  -- アンゴン
	    actask.setTaskSimple(c_angon, 1, 60*3)
	end
    else
	actask.removeTaskSimple(c_angon)
    end
end

return M
