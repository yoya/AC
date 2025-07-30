-- MagicBurst 役。黒魔道士/赤魔導士

local M = {}

local command = require 'command'
local asinspect = require 'inspect'

-- local MB_magic = "ファイア"
local MB_magic = "ブリザド"

function M.mainTick(player)
    if player.status == 1 then -- 戦闘中
	local ws_time = asinspect.ws_time
	local now = os.time()
	if ws_time + 4 < now then
	    if  now < (ws_time + 5) then
		command.send('input /ma '..MB_magic..'V <t>')
	    elseif now < (ws_time + 6) then
		command.send('input /ma '..MB_magic..'IV <t>')
	    elseif now < (ws_time + 8) then
		command.send('input /ma '..MB_magic..'III <t>')
	    elseif now < (ws_time + 10) then
		command.send('input /ma '..MB_magic..'II <t>')
	    end
	end
    end
end

return M
