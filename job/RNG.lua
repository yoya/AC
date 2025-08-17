-- 狩人

local M = {}

local task = require 'task'

M.mainJobProbTable = {
    { 200, 300, 'input /ja 狙い撃ち <me>', 0 },
    { 100, 60, 'input /ja スカベンジ <me>', 0 },
    { 100, 300, 'input /ja 乱れ撃ち <me>', 0 },
    -- { 100, 180, 'input /ja エンドレスショット <me>', 0 },
    -- エンドレスとリキャスト共有
    { 100, 180, 'input /ja ダブルショット <me>', 0 },
    { 100, 180, 'input /ja カモフラージュ <me>; wait 1; input /ja デコイショット <me>', 0 },
    -- { 100, 180, 'input /ja ホバーショット <me>', 0 }, -- デコイと両立不可
}

M.subJobProbTable = {
	{ 200, 300, 'input /ja 狙い撃ち <me>', 0 },
	{ 100, 60, 'input /ja スカベンジ <me>', 0 },
	{ 100, 300, 'input /ja 乱れ撃ち <me>', 0 },
}

function invoke_shoot(onoff)
    local level = task.PRIORITY_LOW  -- 他にやる事ない時は常に shoot
    local c = 'input /shoot <t>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 0, 2, 3, true)
    if onoff == true then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function M.main_tick(player)
    if player.status == 1 then -- 戦闘中
	local items = windower.ffxi.get_items()
	local equipment = items.equipment
	if equipment.range > 0 and equipment.ammo > 0 then
	    invoke_shoot(true)
	else
	    invoke_shoot(false)
	end
    end
end

return M
