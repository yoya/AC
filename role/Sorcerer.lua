-- MagicBurst 役。黒魔道士/赤魔導士

local M = {}

local utils = require 'utils'
local io_chat = require'io/chat'
local acinspect = require 'inspect'
local task = require 'task'
local pstatus = require 'player_status'

M.magic = "ファイア"
local MB_magic = "ファイア"
local nonMB_magic = "ファイア"
--local MB_magic = "ブリザド"
--local MB_magic = "サンダー"

local magic_table = {
    fire = "ファイア",
    ice = "ブリザド",
    wind = "エアロ",
    -- light
    -- dark
    stone = "ストーン",
    thunder = "サンダー",
    water = "ウォータ",
}

M.weak_magic_table = {
    -- イフリート
    -- シヴァ
    ['Ifrit'] = {'ウォータ'},
    ['Shiva'] = {'ファイア'},
    ['Garuda'] = {'ブリザド'},
    ['Titan'] = {'エアロ'},
    ['Ramuh'] = {'ストーン'},
    ['Leviathan'] = {'サンダー'},
    --
    ['Azi Dahaka'] = {'ウォータ', 'ストーン'},
    ['Naga Raja'] = {'サンダー'},
    ['Quetzalcoatl'] = {'ブリザド'},
    ['Mireu'] = {'ウォータ'},
    --
    ['Apex Jagil'] = {'サンダー', 'ブリザド'},
    ['Apex Toad'] = {'サンダー', 'ブリザド'},
}

M.resist_magic_table = {
    ['Ifrit'] = {'ファイア'},
    ['Shiva'] = {'ブリザド'},
    ['Garuda'] = {'エアロ'},
    ['Titan'] = {'ストーン'},
    ['Ramuh'] = {'サンダー'},
    ['Leviathan'] = {'サンダー'},
    -- ドメインベージョン
    ['Azi Dahaka'] = {'ファイア', 'サンダー'},
    ['Naga Raja'] = {'ブリザド', 'ウォータ'},
    ['Quetzalcoatl'] = {'エアロ', 'ストーン'},
    ['Mireu'] = {'ファイア'},
    --
    ['Apex Jagil'] = {'ウォーター'},
    ['Apex Toad'] = {'ウォーター'},
}

function within_time(x, a, b)
    if a <= x and x < b then
	return true
    end
    return false
end

-- local fastcast = 0.8
-- local haste = 0.8
local fastcast = 3.0
local haste = 1.0

local magick_params = {
    -- rank, duration, period
    [1] = {rank='', dur=0.5*fastcast, per=2*haste},
    [2] = {rank='II', dur=1.5*fastcast, per=6*haste},
    [3] = {rank='III', dur=3*fastcast, per=15*haste},
    [4] = {rank='IV', dur=5*fastcast, per=30*haste},
    [5] = {rank='V', dur=7.5*fastcast, per=45*haste},
    [6] = {rank='VI', dur=10.5*fastcast, per=60*haste}
}

function invoke_magic(magicRank, onoff, level)
    assert(type(magicRank) == "number")
    assert(type(onoff) == "boolean")
    local param = magick_params[magicRank]
    if level == nil then
	level = task.PRIORITY_HIGH
    end
    local magic = MB_magic
    -- なるべく通りのよい属性を選択する
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob ~= nil and M.weak_magic_table[mob.name] ~= nil then
	if not utils.table.contains(M.weak_magic_table[mob.name], magic) then
	    magic = M.weak_magic_table[mob.name][1]
	end
    end
    if magicRank > 1 then
	magic = magic .. param.rank
    end
    local c = 'input /ma '..magic..' <t>'
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 0, param.dur, param.per, false)
    if onoff == true then
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end
M.invoke_magic = invoke_magic

function M.magic_burst(player, magick_rank)
    -- 戦闘終了側 (else 節) でも使うので関数スコープで宣言する
    local level = task.PRIORITY_HIGH
    if player.status == pstatus.ENGAGED then -- 戦闘中
	local sc_time = acinspect.sc_time
	local sc_attr = acinspect.sc_attr
	local now = os.time()
	local mp = player.vitals.mp
	local sc = acinspect.skillchain_table[sc_attr]
	if sc == nil then
	    -- print("XXX mb == nil mb_attr:"..mb_attr)
	    return
	end
	MB_magic = sc.magic
	local magic = MB_magic
	-- 効かない属性は MB 打たない。回復されるかもしれないし。
	local mob = windower.ffxi.get_mob_by_target("t")
	if mob ~= nil and M.resist_magic_table[mob.name] ~= nil then
	    if utils.table.contains(M.resist_magic_table[mob.name], magic) then
		return -- MB を打たない
	    end
	end
	-- 一旦、FC 少なめでタイミング調整。
	if within_time(now, sc_time, sc_time + 1)
	    and magick_rank >= 5 and mp >= 306 then
	    invoke_magic(5, true, level)
	else
	    invoke_magic(5, false, level)
	end
	if within_time(now, sc_time, sc_time + 2)
	    and magick_rank >= 4 and mp >= 195 then
	    invoke_magic(4, true, level)
	else
	    invoke_magic(4, false, level)
	end
	if within_time(now, sc_time, sc_time + 3)
	    and magick_rank >= 3 and mp >= 91 then
	    invoke_magic(3, true, level)
	else
	    invoke_magic(3, false, level)
	end
	if within_time(now, sc_time, sc_time + 4)
	    and magick_rank >= 2 and mp >= 37 then
	    invoke_magic(2, true, level)
	else
	    invoke_magic(2, false, level)
	end
	if within_time(now, sc_time, sc_time + 5)
	    and magick_rank >= 1 and mp >= 9 then
	    invoke_magic(1, true, level)
	else
	    invoke_magic(1, false, level)
	end
    else  -- 戦闘終了してる場合は、魔法のタスク予約を取り消す。暴発防止
	invoke_magic(1, false, level)
	invoke_magic(2, false, level)
	invoke_magic(3, false, level)
	invoke_magic(4, false, level)
	invoke_magic(5, false, level)
    end
end

function M.main_tick(player)
    local magick_rank = 3
    local main_job = player.main_job
    if main_job == "BLM" or main_job == "SCH" then
	magick_rank = 5
    elseif main_job == "RDM" then
	magick_rank = 4
    elseif main_job == "GEO" or main_job == "DRK" then
	magick_rank = 3
    else
	return -- MB しない
    end
    M.magic_burst(player, magick_rank)
end

function M.sub_tick(player)
    local magick_rank = 2
    local sub_job = player.sub_job
    if sub_job == "BLM" then
	magick_rank = 2
    end
    M.magic_burst(player, magick_rank)
end

function M.set_magic(magic)
    -- print("set_magic("..tostring(magic)..")")
    if magic ~= nil then
	if magic_table[magic] ~= nil then
	    MB_magic = magic_table[magic]
	    io_chat.print("set magic "..magic.." -> "..MB_magic)
	else
	    print("Unknown magic:"..magic)
	end
    else
	io_chat.print(magic_table)
    end
end

return M
