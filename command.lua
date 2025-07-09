---
--- Command
--- windowe

local M = {}

function send(c)
    s = windower.to_shift_jis(c)
    windower.send_command(s)
end
M.send = send

return M
