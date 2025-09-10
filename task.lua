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
--ex) [M.PRIORITY_HIGH]   = { task1, task2, ... },

local taskPeriodTable = {}
-- ex) command => time

-- newTask
---  command: コマンド。/input  挑発 <t> 等々
---  delay 開始するまでの遅延
---  duration: command にかかる時間
---  period: 同じ command を次に実行できるまでの時間
---  eachfight: 戦闘毎に period をリセットするか否か
M.newTask = function(command, delay, duration, period, eachfight)
    local t = {command=command, delay=delay, duration=duration, period=period,
	       eachfight=eachfight}
    assertTask(t)
    return t
end

function assertTask(task)
    assert(type(task.command) == "string", "command need to be a string: "..task.command)
    assert(type(task.delay) == "number", "delay need to be a number: "..task.command)
    assert(type(task.duration) == "number", "duration need to be a number: "..task.command)
    assert(type(task.period) == "number", " period need to be a number: "..task.command)
    assert(type(task.eachfight) == "boolean", "eachfight need to be a boolean: "..task.command)
end

function assertLevel(level)
    assert(PRIORITY_FIRST <= level and level <= PRIORITY_LAST, "unknown level: "..level)
end

M.allClear = function()
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	for i, task in ipairs(taskTable[level]) do
	    taskTable[level] = {}
	end
    end
end

M.resetByFight = function()
    -- taskPeriodTable から eachfight が true のエントリを削除する
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	for i, task in ipairs(taskTable[level]) do
	    if task.eachfight == true then
		local task = taskTable[level][1]  -- 1 origin
		local c = task.command
		taskPeriodTable[c] = os.time() - 1
		table.remove(taskTable[level], 1)
	    end
	end
    end
end

function taskEqual(task1, task2)
    return task1.command == task2.command
end

function taskIndex(level, task)
    for i, t in ipairs(taskTable[level]) do
	if taskEqual(t, task) then
	    return i
	end
    end
    return 0  -- 1 origin なので 0 を非存在とする
end

function taskContain(level, task)
    if taskIndex(level, task) > 0 then
	return true
    end
    return false
end

-- タスク追加
function M.setTask(level, task)
    assertLevel(level)
    assertTask(task)
    if taskContain(level, task) == true then  -- 重複避け
	return false
    end
    table.insert(taskTable[level], task)
    local c = task.command
    local t = os.time() + task.delay
    --if taskPeriodTable[c] == nil or taskPeriodTable[c] < t then
    if taskPeriodTable[c] == nil then
	taskPeriodTable[c] = t
    end
    return true
end

-- タスク削除
function M.removeTask(level, task)
    assertLevel(level)
    assertTask(task)
    local i = taskIndex(level, task)
    if i > 0 then
	table.remove(taskTable[level], i)
    end
    return i
end

-- ある程度決め打ちの設定でタスク生成
function M.setTaskSimple(c, delay, duration)
    local level = M.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = M.newTask(c, delay, duration, 10, false)
    M.setTask(level, t)
end

function M.removeTaskSimple(c)
    local level = M.PRIORITY_HIGH
    -- command, delay, duration, period, eachfight
    local t = M.newTask(c, 0, 0, 0, false)
    M.removeTask(level, t)
end

M.init = function()
    taskTable = {
	[M.PRIORITY_TOP]    = {},
	[M.PRIORITY_HIGH]   = {},
	[M.PRIORITY_MIDDLE] = {},
	[M.PRIORITY_LOW]    = {},
    }
end

-- 優先順の高い方から、1つだけタスクを取得
function M.getTask()
    local now = os.time()
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	for i, task in ipairs(taskTable[level]) do
	    local c = task.command
	    local t = taskPeriodTable[c]
	    if t <= now then
		taskPeriodTable[c] = os.time() + task.period
		table.remove(taskTable[level], i)
		return level, task
	    end
	end
    end
    return 0, nil
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
    local c = task.command
    -- auto run の時。/ma の command は実行せず setTask し直す
    -- windower.ffxi.run(false)
    -- coroutine.sleep(0.25)
    -- io_chat.print("TASK command:"..task.command, task.duration)
    local o = string.find(c, '//')  -- 頭が // のコマンドは特別扱い
    if o == nil or o > 1 then
	command.send(c)
    else
	if string.find(c, '//echo ') == 1 then
	    local io_chat = require('io/chat')
	    io_chat.setNextColor(5)
	    io_chat.print(string.sub(c, 8))
	end
    end
    tickNextTime = os.time() + task.duration
end

function M.print()
    local io_chat = require('io/chat')
    io_chat.setNextColor(5)
    io_chat.print("=== task print")
    for l, taskArr in pairs(taskTable) do
	io_chat.setNextColor(6)
	io_chat.print("level:"..l)
	for i, task in ipairs(taskArr) do
	    local c = task.command
	    local t = taskPeriodTable[c]
	    io_chat.print(task, t <= os.time())
	end
    end
end

return M
