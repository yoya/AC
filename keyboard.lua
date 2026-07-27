---
--- Keyboard
--- キーボード操作の関数

local M = {}

function M.push_keys(keys)
    local command = ""
    local wait = 0
    for i, k in ipairs(keys) do
	if type(k) == "number" then
	    command = command.."wait "..k.."; "
	else
	    command = command.."setkey "..k.." down; wait 0.2; setkey "..k.." up; wait 0.2; "
	    wait = wait + 0.2 + 0.2
	end
    end
    -- local io_chat = require 'io/chat'
    -- io_chat.print(command, wait)
    windower.send_command(command)
    coroutine.sleep(wait)
end

function M.longpush_key(key, wait)
    assert(type(key) == "string")
    assert(type(wait) == "number")
    local command = "setkey "..key.." down; wait "..wait.."; setkey "..key.." up"
    windower.send_command(command)
    coroutine.sleep(wait)
end

return M
