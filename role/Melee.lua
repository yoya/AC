-- Melee 役。前衛。

local M = {}

local task = require 'task'

function M.main_tick(player)
    local c = "input /item カルボナーラ <me>"
    local level = task.PRIORITY_LOW
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 1, 3, 30*60/3, false)
    task.setTask(level, t)
end

return M
