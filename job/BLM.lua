-- 黒魔道士

local M = {}

local utils = require 'utils'
local task = require 'task'
local role_Sorcerer = require 'role/Sorcerer'
local ac_party = require 'ac/party'

M.mainJobProbTable = {
    -- スキル上げ
    --- 精霊スキル
    -- { 500, 10, 'input /ma ストーン <t>', 3 },
    -- { 10, 10, 'input /ma ファイア <t>', 4 },
    -- { 10, 10, 'input /ma ブリザド <t>', 4 },
    -- { 10, 10, 'input /ma サンダー <t>', 4 },
    -- { 10, 10, 'input /ma ブリザドII <t>', 4 },
    -- { 10, 10, 'input /ma サンダーII <t>', 4 },
    --- 暗黒スキル
    --{ 10,10, 'input /ma バイオ <t>', 3 },
    --{ 10,40, 'input /ma ドレイン <t>',  6},
    --{ 10,10, 'input /ma スタン <t>', 5 },
    -- { 200,10, 'input /ma アスピル <t>', 2 },
    -- { 200,10, 'input /ma アスピルII <t>', 2 },
    --- 弱体スキル
    { 10,10, 'input /ma ディア <t>', 5, true },
    --- 強化スキル
    -- { 100, 180, 'input /ma ショックスパイク <me>', 5 },
}

M.subJobProbTable = { }

function M.invoke_magick_debuff(player, magic, onoff, need_mp)
    if player.vitals.mp < need_mp then
	return
    end
    local level = task.PRIORITY_LOW
    local c = 'input /ma '..magic..' <t>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 2, 5, 90, true)
    if onoff then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function M.main_tick(player)
    if role_Sorcerer.main_tick ~= nil then
	role_Sorcerer.main_tick(player)
    end
    if player.status == 1 then -- 戦闘中
	M.invoke_magick_debuff(player, 'バーン', true, 25)
	M.invoke_magick_debuff(player, 'チョーク', true, 25)
	if player.vitals.mp >= 1200 then
	    role_Sorcerer.invoke_magic(2, true, task.PRIORITY_LOW)
	    role_Sorcerer.invoke_magic(3, true, task.PRIORITY_LOW)
	end
    else
	M.invoke_magick_debuff(player, 'バーン', false, 25)
	M.invoke_magick_debuff(player, 'チョーク', false, 25)
	role_Sorcerer.invoke_magic(2, false, task.PRIORITY_LOW)
	role_Sorcerer.invoke_magic(3, false, task.PRIORITY_LOW)
    end
end

function M.sub_tick(player)
    local acjob = M.parent
    if role_Sorcerer.sub_tick ~= nil then
	role_Sorcerer.sub_tick(player)
    end
    if utils.table.contains(acjob.tankJobs, player.main_job) or
	utils.table.contains(acjob.meleeJobs, player.main_job) then
	return  -- 前衛は精霊弱体しない。時間が勿体無い
    end
    if ac_party.count_member( { main_job="BLM" } ) >= 1 then
	return  -- 本職に任せる
    end
    if player.status == 1 then -- 戦闘中
	M.invoke_magick_debuff(player, 'バーン', true, 25)
	M.invoke_magick_debuff(player, 'チョーク', true, 25)
    else
	M.invoke_magick_debuff(player, 'バーン', false, 25)
	M.invoke_magick_debuff(player, 'チョーク', false, 25)
    end
end

return M
