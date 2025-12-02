-- 吟遊詩人

local M = {}

local task = require 'task'
local role_Melee = require 'role/Melee'
local aczone = require('zone')
local io_chat = require('io/chat')

local piani_prefix = "input /ja ピアニッシモ <me>; wait 2; "

M.mainJobProbTable = {
    -- { 100, 60, 'input /ma 魔法のフィナーレ <t>', 8, true },
    -- { 200, 120, 'input /ma 修羅のエレジー <t>', 8, true },
    { 1000, 120, piani_prefix..'input /ma 魔物のレクイエムVII <t>', 8, true },
    -- { 200, 120, 'input /ma 光のスレノディII <t>', 8, true },
}

M.subJobProbTable = {
    { 300, 180/2, 'input /ma 無敵の進撃マーチ <me>', 8 },
    { 200, 180/2, 'input /ma 猛者のメヌエットIII <me>', 8 },
    -- { 200, 120, 'input /ma 戦場のエレジー <t>', 8, true },
}

function song(song_name, onoff, period, delay)
    local c = "input /song "..song_name.." <me>"
    local level = task.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, delay, 10, period, true)
    if onoff then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function isDefensive()
    if aczone.isNear(291, "toad_pond", 120) then
	return true
    end
    return false
end

function song_tick(player)
    local zone = windower.ffxi.get_info().zone
    local onoff = player.status > 0
    if isDefensive() then
	song("重装騎兵のミンネV", onoff, 15*60 / 3, 2)
	song("闘龍士のマンボ", onoff, 15*60 / 2, 12)
	-- song("活力のエチュード", onoff, 15*60 / 3, 12*2)
	song("戦士達のピーアンVI", onoff, 15*60 / 3, 12*3)
	song("栄光の凱旋マーチ", onoff, 15*60 / 3, 12)
	return
    end
    -- TODO auto かつ街中以外で以下を実行。status 1 で弱体系実行
    song("無敵の進撃マーチ", onoff, 15*60 / 3, 12)
    song("栄光の凱旋マーチ", onoff, 15*60 / 3, 12*2)
    song("猛者のメヌエットV", onoff, 15*60 / 2, 12*3)
    song("剣豪のマドリガル", onoff, 15*60 / 4, 12*4)
    song("怪力のエチュード", onoff, 15*60 / 3, 12*4)
    song("妙技のエチュード", onoff, 15*60 / 2, 12*4)
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    song_tick(player)
end

return M
