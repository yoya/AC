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

-- タスク追加
function M.setTask(task, level)
    if utils.contains(taskTable[level], task) == false then
	taskTable[level].insert(task)
    end
end

-- タスク削除
function M.removeTask(task, level)
    if utils.contains(taskTable[level], task) == false then
	taskTable[level].remove(task)
    end
end

-- 優先順の高い方から、1つだけタスクを取得
function M.getTask(level)
    for level = 1, #taskTable do
	if #taskTable[level] >= 1 then
	    local task = taskTable[level][0]
	    taskTable[level].remove(task)
	    return task
	end
    end
    return nil
end

return M
