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
-- タスク

M.newTask = function(command, duration)
    return {command=command, duration=duration}
end

local tickNextTime = os.time()
M.tick = function()
    if os.time() < tickNextTime then
	return
    end
    local task = M.getTask()
    if task == nil then
	return
    end
    command.send(task.command)
    tickNextTime = os.time() + task.duration
end

-- 
-- 種類
local taskTable = {
    [M.PRIORITY_TOP]    = {},
    [M.PRIORITY_HIGH]   = {},
    [M.PRIORITY_MIDDLE] = {},
    [M.PRIORITY_LOW]    = {},
}

-- タスク追加
function M.setTask(level, task)
    if utils.contains(taskTable[level], task) == false then
	table.insert(taskTable[level], task)
    end
end

-- タスク削除
function M.removeTask(level, task)
    if utils.contains(taskTable[level], task) == false then
	table.remove(taskTable[level], task)
    end
end

-- 優先順の高い方から、1つだけタスクを取得
function M.getTask()
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	if #taskTable[level] >= 1 then
	    local task = taskTable[level][1]  -- 1 origin
	    table.remove(taskTable[level], 1)
	    return task
	end
    end
    return nil
end

function M.print()
    io_console.print(taskTable)
end

return M
