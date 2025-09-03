-- 戦士

local M = {}

local role_Melee = require 'role/Melee'
local task = require 'task'

M.mainJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 0 },
    -- { 60, 10, 'input /ja バーサク <me>', 0 },
    -- { 60, 300, 'input /ja アグレッサー <me>', 0 },
    { 100, 300, 'input /ja ブラッドレイジ <me>', 0 },
    -- { 100, 60, 'input /ja 挑発 <t>', 0 },
    { 100, 600, 'input /ja リストレント <me>', 0 },
    { 100, 180, 'input /ja リタリエーション <me>', 0},
}

M.subJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 1 },
    -- { 100, 60, 'input /ja 挑発 <t>', 1 },
    -- { 100, 300, 'input /ja バーサク <me>', 0 },
    { 100, 300, 'input /ja アグレッサー <me>', 0 },
}

function provoke(player) -- 挑発
    local level = task.PRIORITY_HIGH
    local c = "input /ja 挑発 <t>"
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 0, 1, 30, false)
    if player.status == 1 then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    if 119 <= player.item_level then
	provoke(player)  -- 挑発
    end
end

function M.sub_tick(player)
    if 119 <= player.item_level then
	provoke(player)  -- 挑発
    end
end

return M
