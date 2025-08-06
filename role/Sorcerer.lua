-- MagicBurst 役。黒魔道士/赤魔導士

local M = {}

local command = require 'command'
local asinspect = require 'inspect'

--local MB_magic = "ファイア"
--local MB_magic = "ブリザド"
local MB_magic = "サンダー"

function M.magicBurst(player, magickRank)
    if player.status == 1 then -- 戦闘中
	local ws_time = asinspect.ws_time
	local now = os.time()
	if ws_time + 4 < now then
	    if  now < (ws_time + 5) and magickRank >= 5 then
		command.send('input /ma '..MB_magic..'V <t>')
	    elseif now < (ws_time + 6)  and magickRank >= 4 then
		command.send('input /ma '..MB_magic..'IV <t>')
	    elseif now < (ws_time + 8) and magickRank >= 3 then
		command.send('input /ma '..MB_magic..'III <t>')
	    elseif now < (ws_time + 10) and magickRank >= 2 then
		command.send('input /ma '..MB_magic..'II <t>')
	    end
	end
    end
end

function M.mainTick(player)
    local magickRank = 2
    local main_job = player.main_job
    if main_job == "BLM" then
	magickRank = 5
    elseif main_job == "GEO" then
	magickRank = 3
    elseif main_job == "GEO" then
	magickRank = 2
    end
    if player.status == 1 then -- 戦闘中
	M.magicBurst(player, magickRank)
    end
end

return M
