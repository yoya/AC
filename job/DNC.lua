-- 踊り子

local M = {}

local role_Melee = require 'role/Melee'
local actask = require 'task'

M.main_job_prob_table = {
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

M.sub_job_prob_table = { }

local function is_defensive()
    return M.parent.need_safety()
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    local level = actask.PRIORITY_LOW
    local c_a = 'input /ja 剣の舞い <me>'
    local c_d = 'input /ja 扇の舞い <me>'
    -- command, delay, duration, period, eachfight
    local t_a = actask.new_task(c_a, 2, 2, 60*3+1, false)
    local t_d = actask.new_task(c_d, 2, 2, 60*3+1, false)
    if not is_defensive() then
	actask.set_task(level, t_a)
	actask.remove_task(level, t_d)
    else
	actask.remove_task(level, t_a)
	actask.set_task(level, t_d)
    end
end

return M
