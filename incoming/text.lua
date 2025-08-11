-- incoming text の処理

local M = {}

local utils = require('utils')
local io_console = require('io/console')
local io_chat = require('io/chat')
local ac_data = require('ac/data')
local task = require 'task'

local split_multi = utils.string.split_multi
local phantom_roll_table = ac_data.phantom_roll_table

-- ダブルアップの on/off
function phantom_roll_double_up(on)
    assert(type(on) == boolean)
    local c = "input /ja ダブルアップ <me>"
    local level = task.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 1, 1, 5, false)
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
	    io_chat.print("アンラッキーロール("..roll_number..")！ > スネークアイ")
	    local c = "input /ja スネークアイ <me>"
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

-- コルセアの処理。ロールの文字列を見つけたら動く。
function COR_handler(player, text)
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

function M.incoming_handler(data, modified, original_mode, modified_mode, blocked)
    local player = windower.ffxi.get_player()
    if string.contains(data, player.name) then
	local text = windower.from_shift_jis(data)
	if string.contains(text,"ロール") then
	    COR_handler(player, text)
	end
    end
end

return M
