-- モンク

local M = {}

local role_Melee = require 'role/Melee'
local command = require 'command'
local task = require 'task'

M.mainJobProbTable = {
    { 100, 120, 'input /ja 集中 <me>', 0 },
    { 100, 120, 'input /ja 回避 <me>', 0 },
    { 60, 600, 'input /ja マントラ <me>', 0 },
    { 60, 300, 'input /ja 猫足立ち <me>', 0 },
    { 60, 300, 'input /ja かまえる <me>', 0 },
    { 60, 300, 'input /ja インピタス <me>', 0 },
    { 60, 60, 'input /ja 絶対カウンター <me>', 0 },
    -- { 60, 600, 'input /ja 無想無念 <me>', 0 },
}

M.subJobProbTable = {
    { 100, 120, 'input /ja 集中 <me>', 0 },
}

function M.main_tick(player)
    if player.status == 1 and player.vitals.hp < 300 then  -- 緊急回復
	local c = "input /ja インナーストレングス <me>"
	task.setTaskSimple(c, 0, 2)
    end
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local jaList = { "猫足立ち", "回避", "かまえる", "集中",
		     "インナーストレングス", "百烈拳"}
    for i, ja_name in ipairs(jaList) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.newTask(c, (i-1)*2, 2, 10, false)
	task.setTask(level, t)
    end
end

function M.dothebest_sub(player)
    local level = task.PRIORITY_HIGH
    local jaList = { "回避", "かまえる", "集中"}
    for i, ja_name in ipairs(jaList) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.newTask(c, (i-1)*2, 2, 10, false)
	task.setTask(level, t)
    end
end

return M
