package.path = package.path .. ";../?.lua"
local actask = require('task')
local io_console = require('io/console')

local task1 = actask.newTask("input /ja 挑発 <t>", 2, 60)
local task2 = actask.newTask("input /ma フラッシュ <t>", 2, 45)
local task3 = actask.newTask("input /ma スタン <t>", 2, 10)
local task4 = actask.newTask("input /ma ウォークライ <t>", 2, 300)

actask.setTask(actask.PRIORITY_HIGH, task1)
actask.setTask(actask.PRIORITY_HIGH, task1)
actask.setTask(actask.PRIORITY_HIGH, task2)
actask.setTask(actask.PRIORITY_TOP, task3)
actask.setTask(actask.PRIORITY_MIDDLE, task4)

for i = 1,4 do
    local level, task = actask.getTask()
    io_console.print(level, task)
end
