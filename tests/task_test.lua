package.path = package.path .. ";../?.lua"
local actask = require('task')
local io_console = require('io/console')

local task1 = actask.newTask("input /ja 挑発 <t>", 0, 2, 60, false)
local task2 = actask.newTask("input /echo 消されるタスク", 0, 2, 45, false)
local task3 = actask.newTask("input /ma ウォークライ <t>", 0, 2, 300, false)
local task4 = actask.newTask("input /echo 1秒後に実行", 1, 0, 0, false)
local task5 = actask.newTask("input /ma スタン <t>", 0, 2, 10, false)

actask.setTask(actask.PRIORITY_HIGH, task1)
actask.setTask(actask.PRIORITY_HIGH, task1)
actask.setTask(actask.PRIORITY_HIGH, task2)
actask.setTask(actask.PRIORITY_LOW, task3)
actask.setTask(actask.PRIORITY_MIDDLE, task4)
actask.setTask(actask.PRIORITY_TOP, task5)

actask.removeTask(actask.PRIORITY_HIGH, task2)

for i = 1,3 do
    print("tick:", i, "time:"..os.time())
    repeat
	local level, task = actask.getTask()
	io_console.print(level, task)
    until level == 0
    (io.popen("sleep 1")):close()
end
