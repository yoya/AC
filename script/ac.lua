#! /usr/bin/lua

path = debug.getinfo(1,"S").source:sub(2)
local dirname, _ = path:match('^(.*/)([^/]-)$')
local queueDir = dirname.."/../queue/"
local now = os.time()
local filename = string.format("command-%010d", now)
local command = table.concat(arg, " ")
print(filename, command)
