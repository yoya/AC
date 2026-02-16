-- 忍者

local M = {}

local role_Melee = require 'role/Melee'
local acitem = require 'item'
local task = require 'task'

M.mainJobProbTable = {
    { 100, 60*10, 'input /ja 陰忍 <me>', 2 },
    { 100, 60*5/2, 'input /nin 活火の術:壱 <me>', 3 + 4 },  -- 自分のSTP+10
    { 100, 60*5/2, 'input /nin 妙手の術:壱 <me>', 3 + 4 },  -- 自分の与TP-
    { 100, 60*5/2, 'input /nin 幽林の術:壱 <t>', 1.5 + 4, true },  -- 相手のSTP-
    { 100, 60*5/2, 'input /nin 捕縄の術:弐 <t>', 1.5 + 4, true },  -- スロウ
    -- { 100, 30, 'input /nin 空蝉の術:壱 <me>', 4 + 4},
    -- { 100, 45, 'input /nin 空蝉の術:弍 <me>', 1.5 + 4 },
    -- { 100, 60, 'input /nin 空蝉の術:参 <me>', 0.5 + 4 },
    { 100, 60*5/2, 'input /nin 哀車の術:壱 <t>', 4 + 4, true }, -- 敵の攻撃力down
    { 100, 60, 'input /nin 風遁の術:壱 <t>', 2.75 + 4, true },  -- 氷耐性down
    { 100, 60, 'input /nin 水遁の術:参 <t>', 2.75 + 4, true },  -- 雷耐性down
}

M.subJobProbTable = { }

function invoke_ninjutsu(level, ninjutsu_command, duration, period, onoff)
    assert(type(level) == "number")
    assert(type(ninjutsu_command) == "string")
    assert(type(duration) == "number")
    assert(type(period) == "number")
    assert(type(onoff) == "boolean")
    local c = 'input '..ninjutsu_command
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 0, duration, period, true)
    if onoff == true then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

local toolbag_proc_guard_count = 0
function toolbag_proc(ninja_tools_list)
    -- print("toolbag_proc(ninja_tools_list)", toolbag_proc_guard_count)
    if toolbag_proc_guard_count > 0 then
	-- 短期間でこに関数を連続で呼ぶと、二重処理するので間をあける対処
	toolbag_proc_guard_count = toolbag_proc_guard_count - 1
	-- print("toolbag_proc_guard_count", toolbag_proc_guard_count)
	return
    end
    for _, ninja_tool in ipairs(ninja_tools_list) do
	-- 札がない時に対応する忍だすきを使う。
	local item_id = ninja_tool.item_id
	if not acitem.inventoryHasItem(item_id) then -- 札
	    local toolbag_id = ninja_tool.toolbag_id
	    if acitem.inventoryHasItem(toolbag_id) then -- 忍だすき
		acitem.useItemIncludeBags(toolbag_id)
		toolbag_proc_guard_count = 30
	    else -- インベントリーにない場合、かばんから移動する
		acitem.bagsToInventory(id)
	    end
	end
    end
end

function has_shika()
    
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    -- local shihei_item_id = 1179 -- 紙兵
    local ninja_tools_list = {
	{ item_id = 2971, toolbag_id = 5867 }, -- 猪ノ札, 忍だすき【猪】
	{ item_id = 2972, toolbag_id = 5868 }, -- 鹿ノ札, 忍だすき【鹿】
	{ item_id = 2973, toolbag_id = 5869 }, -- 蝶ノ札, 忍だすき【蝶】
	{ item_id = 1179, toolbag_id = 5314 }, -- 忍だすき【紙兵】
    }
    toolbag_proc(ninja_tools_list)
    local shika_onoff = false
    --  空蝉の術・遁甲の術・物見の術・妙手の術・身替の術・活火の術
    if acitem.inventoryHasItem(1179) or -- 紙兵
	acitem.inventoryHasItem(2972) then -- 鹿ノ札
	shika_onoff = true
    end
    local level = task.PRIORITY_HIGH
    -- level, command, duration, period, onoff
    invoke_ninjutsu(level, '/nin 空蝉の術:壱 <me>', 4 + 4, 30, shika_onoff)
    invoke_ninjutsu(level, '/nin 空蝉の術:弍 <me>', 1.5 + 4, 45, shika_onoff)
    invoke_ninjutsu(level, '/nin 空蝉の術:参 <me>', 0.5 + 4, 60, shika_onoff)
end

function M.sub_tick(player)
    local ninja_tools_list = {
	{ item_id = 1179, toolbag_id = 5314 }, -- 忍だすき【紙兵】
    }
    toolbag_proc(ninja_tools_list)
end

return M
