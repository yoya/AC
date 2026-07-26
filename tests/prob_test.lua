package.path = package.path .. ";../?.lua"
local prob = require "prob"
local io_console = require "io/console"
io_console.print("### WHM/BLM")
io_console.print(prob.get_send_command_prob_table("WHM", "BLM", 1))
io_console.print("### BLM/RDM")
io_console.print(prob.get_send_command_prob_table("BLM", "RDM", 1))
