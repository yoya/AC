package.path = package.path .. ";../?.lua"
local prob = require "prob"
local io_console = require "io/console"
io_console.print("### WHM/BLM")
io_console.print(prob.getSendCommandProbTable("WHM", "BLM", 1))
io_console.print("### BLM/RDM")
io_console.print(prob.getSendCommandProbTable("BLM", "RDM", 1))
