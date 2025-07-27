package.path = package.path .. ";../?.lua"
local actask = require('task')

local task = {command="input /ja 挑発<t>", duration=2}
actask.setTask(1, task)

local t = actask.getTask(1)
