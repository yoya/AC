-- タスクスケジューラ

local M = {}

local utils = require('utils')

-- 優先度別、タスク
-- { 種類
M.taskTable = {
    [1] = {},  -- 最優先。スタンや緊急ケアル 
    [2] = {},  -- 優先度高。サイレス。MB
    [3] = {},  -- 優先度中。デバフ。通常ケアル
    [4] = {},  -- 優先度低。バフ。通常の魔法、遠隔武器
}

function M.setTask(task, level)
    if utils.contains(taskTable[level], task) == false then
	taskTable[level].insert(task)
    end
end

function M.clearTask(task, level)
    if utils.contains(taskTable[level], task) == false then
	taskTable[level].remove(task)
    end
end

function M.getTask(level)
    if #taskTable[level] >= 1 then
	local task = taskTable[0]
	taskTable[level].remove(task)
	return task
    end
    return nil
end

return M
