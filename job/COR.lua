-- コルセア

local M = {}

local utils = require('utils')
local io_chat = require('io/chat')
local ac_data = require('ac/data')
local task = require 'task'
local role_Melee = require 'role/Melee'
local incoming_text = require('incoming/text')

local split_multi = utils.string.split_multi
local phantom_roll_table = ac_data.phantom_roll_table

M.mainJobProbTable = {
    { 100, 20*60, 'input /ja ランダムディール <me>', 3 },
    -- { 200, 60, 'input /ja コルセアズロール <me>; wait 2; input /ja ダブルアップ <me>', 0 },
    { 50, 300, 'input /ja ブリッツァロール <me>', 3 },
    { 100, 300/2, 'input /ja サムライロール  <me>', 3 },
    { 100, 300/2, 'input /ja カオスロール  <me>', 3 },
    { 100, 300, 'input /ja ファイターズロール  <me>', 3 },
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

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

-- ダブルアップの on/off
function phantom_roll_double_up(on)
    io_chat.setNextColor(3)
    io_chat.print("phantom_roll_double_up", on)
    assert(type(on) == "boolean")
    local c = "input /ja ダブルアップ <me>"
    local level = task.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 2, 2, 5, false)
    if on == true then
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
	    io_chat.setNextColor(6)
	    io_chat.print("アンラッキーロール("..roll_number..")！ > スネークアイ&ダブルアップ")
	    local c = "input /ja スネークアイ <me>; wait 2; input /ja ダブルアップ <me>"
	    task.setTask(task.PRIORITY_MIDDLE,
			 -- command, delay, duration, period, eachfight
			 task.newTask(c, 1, 1, 5, false))
	    return
	end
	io_chat.setNextColor(6)
	io_chat.print(roll_name.." "..roll_number.." で打ち止め ("..roll_info.lucky.."/"..roll_info.unlucky..")")
	phantom_roll_double_up(false) -- たまに暴発するのを防ぎたい
	return
    end
    io_chat.setNextColor(6)
    io_chat.print("出目:"..roll_number.." => ダブルアップ！")
    phantom_roll_double_up(true)
end

-- ロールの文字列を見つけたら動く。
function incoming_text_handler(text)
    local player = windower.ffxi.get_player()
    if string.contains(text, player.name) == false then
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
	io_chat.setNextColor(3)
	io_chat.print("Bust => フォールド！")
	local c = "input /ja フォールド <me>"
	task.setTask(task.PRIORITY_MIDDLE,
		     -- command, delay, duration, period, eachfight
		     task.newTask(c, 1, 1, 5, false))
	return
    end
end


local listener_id = incoming_text.addListener("ロール", incoming_text_handler)

return M
