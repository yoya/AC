-- MagicBurst 役。黒魔道士/赤魔導士

local command = require 'command'
local asinspect = require 'inspect'

local M = {}

function M.mainTick(player)
    local ws_time = asinspect.ws_time + 4
    local now = os.time()
    if ws_time < now then
	if  now < (ws_time + 2) then
	    -- command.send('input /ma ブリザドV <t>')
	    command.send('input /ma ファイアV <t>')
	elseif now < (ws_time + 4) then
	    -- command.send('input /ma ブリザドIV <t>')
	    command.send('input /ma ファイアIV <t>')
	end
    end
end

return M
