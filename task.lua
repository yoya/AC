-- タスクスケジューラ

local M = {}

local control = require 'control'
local command = require 'command'
local ac_record = require 'ac/record'
local ws = require 'ws'

-- 優先度別、タスク
-- 優先度
local PRIORITY_FIRST  = 1
M.PRIORITY_TOP    = 1  -- 最優先。スタンや緊急ケアル
M.PRIORITY_HIGH   = 2  -- 優先度高。サイレス。MB, WS
M.PRIORITY_MIDDLE = 3  -- 優先度中。デバフ。通常ケアル
M.PRIORITY_LOW    = 4  -- 優先度低。バフ。通常の魔法、遠隔武器
local PRIORITY_LAST  = 4
local task_table = {
    [M.PRIORITY_TOP]    = {},
    [M.PRIORITY_HIGH]   = {},
    [M.PRIORITY_MIDDLE] = {},
    [M.PRIORITY_LOW]    = {},
}
--ex) [M.PRIORITY_HIGH]   = { task1, task2, ... },

local task_period_table = {}
-- ex) command => { time=次に実行できる時刻, eachfight=戦闘毎にリセットするか }

-- new_task
---  command: コマンド。/input  挑発 <t> 等々
---  delay 開始するまでの遅延
---  duration: command にかかる時間
---  period: 同じ command を次に実行できるまでの時間
---  eachfight: 戦闘毎に period をリセットするか否か
M.new_task = function(cmd, delay, duration, period, eachfight)
    local t = {command=cmd, delay=delay, duration=duration, period=period,
	       eachfight=eachfight}
    assert_task(t)
    return t
end

function assert_task(task)
    assert(type(task.command) == "string", "command need to be a string: "..task.command)
    assert(type(task.delay) == "number", "delay need to be a number: "..task.command)
    assert(type(task.duration) == "number", "duration need to be a number: "..task.command)
    assert(type(task.period) == "number", " period need to be a number: "..task.command)
    assert(type(task.eachfight) == "boolean", "eachfight need to be a boolean: "..task.command)
end

function assert_level(level)
    assert(PRIORITY_FIRST <= level and level <= PRIORITY_LAST, "unknown level: "..level)
end

M.all_clear = function()
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	task_table[level] = {}
    end
end

M.all_reset = function()  -- 再使用タイマーのリセット
    task_period_table = {}
end

M.reset_by_fight = function()
    -- eachfight が true のタスクをキューから外し、再使用タイマーをリセットする
    -- (prob.lua が新しい戦闘用に積み直す)
    -- 実行済みのタスクはキューに残っていないので、再使用タイマー側を走査する
    local now = os.time()
    for _, p in pairs(task_period_table) do
	if p.eachfight == true then
	    p.time = now - 1
	end
    end
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	local tasks = task_table[level]
	-- table.remove するので後ろから回す
	for i = #tasks, 1, -1 do
	    if tasks[i].eachfight == true then
		table.remove(tasks, i)
	    end
	end
    end
end

function task_equal(task1, task2)
    return task1.command == task2.command
end

function task_index(level, task)
    for i, t in ipairs(task_table[level]) do
	if task_equal(t, task) then
	    return i
	end
    end
    return 0  -- 1 origin なので 0 を非存在とする
end

function task_contain(level, task)
    if task_index(level, task) > 0 then
	return true
    end
    return false
end

-- タスク追加
function M.set_task(level, task)
    assert_level(level)
    assert_task(task)
    if task_contain(level, task) == true then  -- 重複避け
	return false
    end
    table.insert(task_table[level], task)
    local c = task.command
    local t = os.time() + task.delay
    local p = task_period_table[c]
    if p == nil then
	task_period_table[c] = { time=t, eachfight=task.eachfight }
    else
	-- delay は2回目以降も効かせる。ただし再使用待ちを縮めはしない
	if p.time < t then
	    p.time = t
	end
	p.eachfight = task.eachfight
    end
    return true
end

-- タスク削除
function M.remove_task(level, task)
    assert_level(level)
    assert_task(task)
    local i = task_index(level, task)
    if i > 0 then
	table.remove(task_table[level], i)
    end
    return i
end

function M.reset_task(level, task)
    local i = task_index(level, task)
    if i > 0 then
	table.remove(task_table[level], i)
	task_period_table[task.command] = nil  -- 再使用タイマーをリセット
    end
    return i
end

local PRIORITY_SIMPLE = M.PRIORITY_MIDDLE
-- ある程度決め打ちの設定でタスク生成
function M.set_task_simple(c, delay, duration)
    local level = PRIORITY_SIMPLE
    -- command, delay, duration, period, eachfight
    local t = M.new_task(c, delay, duration, 10, false)
    M.set_task(level, t)
end

function M.remove_task_simple(c)
    local level = PRIORITY_SIMPLE
    -- command, delay, duration, period, eachfight
    local t = M.new_task(c, 0, 0, 0, false)
    M.remove_task(level, t)
end

function M.set_task_ex(c, params)
    local level = params.level or PRIORITY_SIMPLE
    local delay = params.delay or 0
    local duration = params.duration or 2
    local period = params.period or 10
    local eachfight = params.eachfight  or false
    local t = M.new_task(c, delay, duration, period, eachfight)
    M.set_task(level, t)
end

function M.remove_task_ex(c)
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	local t = M.new_task(c, 0, 0, 0, false)
	M.remove_task(level, t)
    end
end

M.init = function()
    task_table = {
	[M.PRIORITY_TOP]    = {},
	[M.PRIORITY_HIGH]   = {},
	[M.PRIORITY_MIDDLE] = {},
	[M.PRIORITY_LOW]    = {},
    }
end

-- 優先順の高い方から、1つだけタスクを取得
function M.get_task()
    local now = os.time()
    for level = PRIORITY_FIRST, PRIORITY_LAST do
	for i, task in ipairs(task_table[level]) do
	    local c = task.command
	    local p = task_period_table[c]
	    if p == nil or p.time <= now then
		task_period_table[c] = { time=now + task.period,
					 eachfight=task.eachfight }
		table.remove(task_table[level], i)
		return level, task
	    end
	end
    end
    return 0, nil
end

local tick_next_time = os.time()
M.tick = function()
    local now = os.time()
    if now < tick_next_time then
	return
    end
    local _, task = M.get_task()
    if task == nil then
	return
    end
    local c = task.command
    -- auto run の時。/ma の command は実行せず set_task し直す
    -- windower.ffxi.run(false)
    -- coroutine.sleep(0.25)
    -- io_chat.print("TASK command:"..task.command, task.duration)
    local o = string.find(c, '//')  -- 頭が // のコマンドは特別扱い
    if o == nil or o > 1 then
	local io_chat = require('io/chat')
	local datetime = os.date("%X", now)
	if control.debug then
	    io_chat.printf("[%s]task.command: %s", datetime, c)
	end
	command.send(c)
    else
	if string.find(c, '//echo ') == 1 then
	    local io_chat = require('io/chat')
	    io_chat.set_next_color(5)
	    io_chat.print(string.sub(c, 8))
	elseif string.find(c, '//record char') == 1 then
	    -- print("//record char")
	    ac_record.record_char()
	elseif string.find(c, '//ws exec') == 1 then
	    ws.exec()
	else
	    local io_chat = require('io/chat')
	    io_chat.warnf("task: unknown // command: %s", c)
	end
    end
    tick_next_time = now + task.duration
    -- print("tick_next_time", tick_next_time, task.duration, c)
end

function M.print()
    local io_chat = require('io/chat')
    io_chat.set_next_color(5)
    io_chat.print("=== task print")
    for l, taskArr in pairs(task_table) do
	io_chat.set_next_color(6)
	io_chat.print("level:"..l)
	for i, task in ipairs(taskArr) do
	    local c = task.command
	    local p = task_period_table[c]
	    io_chat.print(task, p == nil or p.time <= os.time())
	end
    end
end

return M
