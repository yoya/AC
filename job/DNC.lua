-- 踊り子

local M = {}

local role_Melee = require 'role/Melee'
local actask = require 'task'

M.mainJobProbTable = {
    {50, 90, 'input /ja ヘイストサンバ <me>', 0 },
    {50, 90, 'input /ja ドレインサンバII <me>', 0 },
    {100, 60, 'input /ja B.フラリッシュ <me>', 0 },
    {100, 90, 'input /ja C.フラリッシュ <me>', 0 },
    {100, 90, 'input /ja S.フラリッシュ <me>', 0 },
    {100, 90, 'input /ja T.フラリッシュ <me>', 0 },
    {100, 5*3, 'input /ja クイックステップ <t>', 0},
    {100, 5*3, 'input /ja ボックスステップ <t>', 0},
    {100, 5*3, 'input /ja フェザーステップ <t>', 0},
}

M.subJobProbTable = { }

function isDefensive()
    return M.parent.needSafety()
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    local level = actask.PRIORITY_LOW
    local c_a = 'input /ja 剣の舞い <me>'
    local c_d = 'input /ja 扇の舞い <me>'
    -- command, delay, duration, period, eachfight
    local t_a = actask.newTask(c_a, 2, 2, 60*3+1, false)
    local t_d = actask.newTask(c_d, 2, 2, 60*3+1, false)
    if true then
	actask.setTask(level, t_a)
	actask.removeTask(level, t_d)
    else
	actask.removeTask(level, t_a)
	actask.setTask(level, t_a)
    end
end

return M
