---
--- Keyboard
--- キーボード操作の関数

local M = {}

function M.pushKeys(keys)
    local command = ""
    local wait = 0
    for i, k in ipairs(keys) do
        command = command.."setkey "..k.." down; wait 0.1; setkey "..k.." up; wait 0.1; "
        wait = wait + 0.1 + 0.1
    end
    windower.send_command(command)
    coroutine.sleep(wait)
end

return M

