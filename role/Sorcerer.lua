-- MagicBurst 役。黒魔道士/赤魔導士

local M = {}

local io_chat = require'io/chat'
local command = require 'command'
local asinspect = require 'inspect'
local task = require 'task'

local MB_magic = "ファイア"
--local MB_magic = "ブリザド"
--local MB_magic = "サンダー"

function within_time(x, a, b)
    if a <= x and x < b then
	return true
    end
    return false
end

local magickParams = {
    -- rank, duration, period
    [1] = {rank='', dur=1, per=2},
    [2] = {rank='II', dur=2, per=6},
    [3] = {rank='III', dur=4, per=15},
    [4] = {rank='IV', dur=6, per=30},
    [5] = {rank='V', dur=8, per=45},
    [6] = {rank='VI', dur=11, per=60}
}

function invoke_magic(magicRank, onoff)
    assert(type(magicRank) == "number")
    assert(type(onoff) == "boolean")
    local param = magickParams[magicRank]
    local level = task.PRIORITY_HIGH
    local magic = MB_magic..param.rank
    local c = 'input /ma '..magic..' <t>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 0, param.dur, param.per, false)
    if onoff == true then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function M.magicBurst(player, magickRank)
    if player.status == 1 then -- 戦闘中
	local ws_time = asinspect.ws_time
	local now = os.time()
	local mp = player.vitals.mp
	if within_time(now, ws_time + 4, ws_time + 6)
	    and magickRank >= 5 and mp >= 306 then
	    invoke_magic(5, true)
	else
	    invoke_magic(5, false)
	end
	if within_time(now, ws_time + 6, ws_time + 8)
	    and magickRank >= 4 and mp >= 195 then
	    invoke_magic(4, true)
	else
	    invoke_magic(4, false)
	end
	if within_time(now, ws_time + 8, ws_time + 9)
	    and magickRank >= 3 and mp >= 91 then
	    invoke_magic(3, true)
	else
	    invoke_magic(3, false)
	end
	if within_time(now, ws_time + 9, ws_time + 10)
	    and magickRank >= 2 and mp >= 37 then
	    invoke_magic(2, true)
	else
	    invoke_magic(2, false)
	end
    end
end

function M.main_tick(player)
    if player.status == 1 then -- 戦闘中
	local magickRank = 2
	local main_job = player.main_job
	if main_job == "BLM" then
	    magickRank = 5
	elseif main_job == "RDM" then
	    magickRank = 3
	elseif main_job == "GEO" then
	    magickRank = 2
	end
	M.magicBurst(player, magickRank)
    end
end

local magicTable = {
    fire = "ファイア",
    ice = "ブリザド",
    wind = "エアロ",
    -- light
    -- dark
    stone = "ストーン",
    thunder = "サンダー",
    water = "ウォータ",
}

function M.setMagic(magic)
    print("setMagic("..magic..")")
    if magic ~= nil then
	if magicTable[magic] ~= nil then
	    MB_magic = magicTable[magic]
	    io_chat.print("set magic "..magic.." -> "..MB_magic)
	else
	    print("Unknown magic:"..magic)
	end
    else
	io_chat.print(magicTable)
    end
end

return M
