-- Melee 役。前衛。

local M = {}

local task = require 'task'

function M.main_tick(player)
    if player.status == 1 then
	local c = "input /item カルボナーラ <me>"
	local level = task.PRIORITY_LOW
	-- command, delay, duration, period, eachfight
	local t = task.new_task(c, 1, 3, 30*60/10, false)
	task.set_task(level, t)
    end
end

return M
