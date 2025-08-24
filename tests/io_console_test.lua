package.path = package.path .. ";../?.lua"
local io_console = require "io/console"
local data = { "AAA", "BBB", CCC = {"XXX", 0.1234, true}, "ZZZ" }

io_console.print(data)

io_console.printf("%04d %04d %s", 1, 2, "X")
