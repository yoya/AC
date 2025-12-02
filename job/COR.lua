-- コルセア

local M = {}

local utils = require('utils')
local control = require('control')
local io_chat = require('io/chat')
local ac_data = require('ac/data')
local ac_pos = require('ac/pos')
local task = require 'task'
local role_Melee = require 'role/Melee'
local incoming_text = require('incoming/text')
local aczone = require('zone')

local split_multi = utils.string.split_multi
local phantom_roll_table = ac_data.phantom_roll_table

M.mainJobProbTable = {
    { 100, 60*10/2, 'input /ja クルケッドカード <me>', 3 }, -- 駄目元で
    { 100, 20*60/2, 'input /ja ランダムディール <me>', 3 },
    -- { 200, 60, 'input /ja コルセアズロール <me>; wait 2; input /ja ダブルアップ <me>', 0 },
--    { 50, 300, 'input /ja ブリッツァロール <me>', 3 },
--    { 100, 300/2, 'input /ja サムライロール  <me>', 3 },
--    { 100, 300/2, 'input /ja カオスロール  <me>', 3 },
--    { 100, 300, 'input /ja ファイターズロール  <me>', 3 },
    -- { 100, 300/2, 'input /ja メガスズロール  <me>', 3 },
    -- { 100, 300/2, 'input /ja ウィザーズロール  <me>', 3 },
    --[[
	{ 100, 300, 'input /ja ガランツロール <me>', 3 },
	{ 100, 300, 'input /ja ダンサーロール <me>', 3 },
    ]]
}

M.subJobProbTable = {
    -- { 100, 300, 'input /ja コルセアズロール <me>;'' wait 2; /ja ダブルアップ <me>', 3 },
    { 100, 60, 'input /ja コルセアズロール <me>', 3 },
    -- { 100, 300, 'input /ja サムライロール  <me>', 3 },
    -- { 100, 300, 'input /ja カオスロール  <me>', 3 },
    -- { 100, 300, 'input /ja ファイターズロール  <me>', 3 },
}

function phantom_roll(roll_name, on, delay)
    local c = "input /ja "..roll_name.." <me>"
    local level = task.PRIORITY_MIDDLE
    local period = 300 / 4
    if roll_name == "コルセアズロール" then
	level = task.PRIORITY_HIGH
	period = 20
    end
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, delay, 4, period, true)
    if on then
	--io_chat.setNextColor(6)
	--io_chat.print("phantom_roll", roll_name)
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function roll_tick(player)
    local zone = windower.ffxi.get_info().zone
    local me = windower.ffxi.get_mob_by_target("me")
    local mob = windower.ffxi.get_mob_by_target("t")
    -- 醴泉島(291)のかえる池
    if zone == 291 and aczone.isNear(291, "toad_pond", 100) then
	phantom_roll("ダンサーロール", true, 0)  -- リジェネ
	phantom_roll("ガランツロール", true, 61)  -- 防御
	-- phantom_roll("ニンジャロール", true, 61*3)  -- 回避
	-- phantom_roll("メガスズロール", true, 61*4)  -- 魔防御
	phantom_roll("ルーニストロール", true, 61*6)  -- 魔回避
	return
    end
    if mob ~= nil then
	-- print(mob.hpp)
	local war_roll = false
	local sam_roll = false
	local drk_roll = false
	local cor_roll = false
	local blitzer_roll = false
	-- コルセアロール使えるように 33% でストップ
	if 33 <= mob.hpp and mob.hpp <= 100 then
	    war_roll = true
	    sam_roll = true
	    drk_roll = true
	end
	-- 敵の HP が3%〜15% で、可能ならコルセアズロール
	-- Apex で3%未満だと戦闘終了と同時に動く可能性がそこそこある
	if 3 <= mob.hpp and mob.hpp <= 20 then
	    cor_roll = true
	    blitzer_roll = true
	end
	phantom_roll("サムライロール", sam_roll, 0)
	phantom_roll("カオスロール", drk_roll, 61)
	phantom_roll("ファイターズロール", war_roll, 61*2)
	phantom_roll("コルセアズロール", cor_roll, 0)
	phantom_roll("ブリッツァロール", blitzer_roll, 61)
    end
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    local cors_roll = false
    if player.status == 1 then -- 戦闘中
	roll_tick(player)
    end
    -- ロールrecastを考慮してないので、駄目元のコルセアズロール。
end

-- ダブルアップの on/off
function phantom_roll_double_up(on)
    assert(type(on) == "boolean")
    local c = "input /ja ダブルアップ <me>"
    local level = task.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 1, 4, 5, false)
    if on == true then
	-- io_chat.setNextColor(6)
	-- io_chat.print("phantom_roll_double_up")
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

-- 出目に応じてロールアップを続けるか否かの処理
function COR_phantom_roll_up(roll_name, roll_number)
    assert(type(roll_name) == "string")
    assert(type(roll_number) == "number")
    -- io_chat.setNextColor(6)
    -- io_chat.print("COR_phantom_roll_up", roll_name, roll_number)
    local roll_info = phantom_roll_table[roll_name.."ロール"]
    if roll_info == nil then
	io_chat.setNextColor(3)
	io_chat.print("Unknown phantom roll:"..roll_name)
	return
    end
    if roll_number == roll_info.lucky then
	io_chat.setNextColor(6)
	io_chat.print(roll_name.."("..roll_number..") ラッキーロール！")
	return
    end
    if roll_number >= 6 then
	-- TODO: フォールド使える場合は return しない
	if roll_number == roll_info.unlucky then
	    if control.debug then
		io_chat.setNextColor(6)
		io_chat.print("アンラッキーロール("..roll_number..")！ > スネークアイ&ダブルアップ")
	    end
	    local c = "input /ja スネークアイ <me>; wait 2; input /ja ダブルアップ <me>"
	    task.setTask(task.PRIORITY_MIDDLE,
			 -- command, delay, duration, period, eachfight
			 task.newTask(c, 1, 1, 5, false))
	    return
	end
	if control.debug then
	     io_chat.setNextColor(6)
	     io_chat.print(roll_name.." "..roll_number.." で打ち止め ("..roll_info.lucky.."/"..roll_info.unlucky..")")
	end
	phantom_roll_double_up(false) -- たまに暴発するのを防ぎたい
	return
    end
    if control.debug then
	io_chat.setNextColor(6)
	io_chat.print("出目:"..roll_number.." => ダブルアップ！")
    end
    phantom_roll_double_up(true)
end

-- ロールの文字列を見つけたら動く。
function incoming_text_handler(text)
    local player = windower.ffxi.get_player()
    if player == nil or string.contains(text, player.name) == false then
	return
    end
    -- Upachanのダブルアップ\n→ファイターズロールの合計値が5になった！
    local s = split_multi(text, {'ダブルアップ', '→', 'ロール', 'が', 'に'})
    if s ~= nil then
	local roll_name = s[3]
	local roll_number = tonumber(s[5])
	COR_phantom_roll_up(roll_name, roll_number)
	return
    end
    -- Upachanのファイターズロール→合計値が5になった！
    local s = split_multi(text, {'の', 'ロール', 'が', 'に'})
    if s ~= nil then
	local roll_name = s[2]
	local roll_number = tonumber(s[4])
	COR_phantom_roll_up(roll_name, roll_number)
	return
    end
    if string.contains(text,"ロールがBust") then
	if control.debug then
	     io_chat.setNextColor(3)
	     io_chat.print("Bust => フォールド！")
	end
	local c = "input /ja フォールド <me>"
	task.setTask(task.PRIORITY_MIDDLE,
		     -- command, delay, duration, period, eachfight
		     task.newTask(c, 1, 1, 5, false))
	return
    end
end


local listener_id = incoming_text.addListener("ロール", incoming_text_handler)

return M
