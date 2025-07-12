-- 地脈調査

local M = {}

local keyboard = require 'keyboard'

M.auto = false
    
function ergonLocusFunction()
    keyboard.pushKeys({"numpad5"})
    M.auto = true
    while(M.auto)
    do
	keyboard.pushKeys({"f8", "numpad*", "numpad2", "enter"})
	coroutine.sleep(3)
	keyboard.pushKeys({"up", "enter"})
	coroutine.sleep(3)
    end
    M.auto = false
end

M.ergonLocusFunction = ergonLocusFunction

return M
