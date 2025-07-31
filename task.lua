-- タスクスケジューラ

local M = {}

local utils = require('utils')
local io_console = require('io/console')
local command = require 'command'

-- 優先度別、タスク
-- 優先度
local PRIORITY_FIRST  = 1
M.PRIORITY_TOP    = 1  -- 最優先。スタンや緊急ケアル
M.PRIORITY_HIGH   = 2  -- 優先度高。サイレス。MB
M.PRIORITY_MIDDLE = 3  -- 優先度中。デバフ。通常ケアル
M.PRIORITY_LOW    = 4  -- 優先度低。バフ。通常の魔法、遠隔武器
local PRIORITY_LAST  = 4
local taskTable = {
    [M.PRIORITY_TOP]    = {},
    [M.PRIORITY_HIGH]   = {},
    [M.PRIORITY_MIDDLE] = {},
    [M.PRIORITY_LOW]    = {},
}
local taskPeriodTable = {}
-- ex) [M.PRIORITY_HIGH]   = { task1, task2, ... },

-- newTask
---  command: コマンド。/input  挑発 <t> 等々
---  duration: command にかかる時間
---  period: 同じ command を次に実行できるまでの時間
---  eachfight: 戦闘毎に period をリセットするか否か
M.newTask = function(command, duration, period, eachfight)
    return {command=command, duration=duration, period=period,
	    eachfight=eachfight}
end

local tickNextTime = os.time()
M.tick = function()
    if os.time() < tickNextTime then
	return
    end
    local level, task = M.getTask()
    if task == nil then
	return
    end
    -- auto run の時。/ma の command は実行せず setTask し直す
    command.send(task.command)
    tickNextTime = os.time() + task.duration
end

M.resetByFight = function()
    -- taskPeriodTable から eachfight が true のエントリを削除する
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	for i, task in ipairs(taskTable[level]) do
	    if task.eachfight == true then
		local task = taskTable[level][1]  -- 1 origin
		table.remove(taskTable[level], 1)
		return level, task
	    end
	end
    end
    return 0, nil
end

function taskEqual(task1, task2)
    return task1.command == task2.command
end

function taskIndex(level, task)
    for i,t in ipairs(taskTable[level]) do
	if taskEqual(t, task) then
	    return i
	end
    end
    return 0
end

function taskContain(level, task)
    if taskIndex(level, task) > 0 then
	return true
    end
    return false
end

-- タスク追加
function M.setTask(level, task)
    if taskContain(level, task) == false then  -- 重複避け
	table.insert(taskTable[level], task)
    end
end

-- タスク削除
function M.removeTask(level, task)
    local i = taskIndex(level, task)
    if i > 0 then
	table.remove(taskTable[level], i)
    end
    return i
end

-- 優先順の高い方から、1つだけタスクを取得
function M.getTask()
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	if #taskTable[level] >= 1 then
	    local task = taskTable[level][1]  -- 1 origin
	    table.remove(taskTable[level], 1)
	    return level, task
	end
    end
    return 0, nil
end

function M.print()
    io_console.print(taskTable)
end

return M
