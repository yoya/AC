package.path = package.path .. ";../?.lua"
local actask = require('task')
local io_console = require('io/console')

local task1 = actask.new_task("input /ja 挑発 <t>", 0, 2, 60, false)
local task2 = actask.new_task("input /echo 消されるタスク", 0, 2, 45, false)
local task3 = actask.new_task("input /ma ウォークライ <t>", 0, 2, 300, false)
local task4 = actask.new_task("input /echo 1秒後に実行", 1, 0, 0, false)
local task5 = actask.new_task("input /ma スタン <t>", 0, 2, 10, false)

actask.set_task(actask.PRIORITY_HIGH, task1)
actask.set_task(actask.PRIORITY_HIGH, task1)
actask.set_task(actask.PRIORITY_HIGH, task2)
actask.set_task(actask.PRIORITY_LOW, task3)
actask.set_task(actask.PRIORITY_MIDDLE, task4)
actask.set_task(actask.PRIORITY_TOP, task5)

actask.remove_task(actask.PRIORITY_HIGH, task2)

for i = 1,3 do
    print("tick:", i, "time:"..os.time())
    repeat
	local level, task = actask.get_task()
	io_console.print(level, task)
    until level == 0
    (io.popen("sleep 1")):close()
end
