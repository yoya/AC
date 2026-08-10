-- 換金(エミネンス、ユニティポイント)
-- zone:256 西アドゥリンでは自動で有効化

local M = {}

local utils = require 'utils'
local command = require 'command'
local keyboard = require 'keyboard'
local push_keys = keyboard.push_keys
local io_chat = require 'io/chat'

local ac_char = require("ac/char")
local acitem = require 'item'

function M.tick(player)
end

M.eminence_point_redeem_enable = true
M.unity_point_redeem_enable = true

function M.contents_in(player)
    print("contents/redeem.contents_in")
    M.eminence_point_redeem_enable = true
    M.unity_point_redeem_enable = true
end

function M.incoming_text_handler(text)
    if M.parent.type ~= M.parent.Redeem then
	return
    end
    local me = windower.ffxi.get_mob_by_target("me")
    local eminence_point = ac_char.eminence_point()
    local unity_point = ac_char.unity_point()
    -- エミネンス交換後
    if string.contains(text, "sparks to purchase:") then
	--push_keys({1, "escape", "escape"})
	push_keys({1, "numpad*"}) -- lock を外す
    elseif string.contains(text, "Sparks Buying Finished.") or
	string.contains(text, "アイテムを整理した後") then
	windower.ffxi.run(24 - me.x, -120 - me.y)
    elseif string.contains(text, "You do not have enough sparks.") or
	string.contains(text, "エミネンスが足りません") or
	string.contains(text, "アイテム等の交換に使用できるエミネンスポイントは、") then
	M.eminence_point_redeem_enable = false
	-- windower.ffxi.run(24 - me.x, -120 - me.y)
    elseif string.contains(text, "all売却 end") then
	utils.target_lockon(false)  -- ロックオンしてたら外す
	print("what???? > emi, uni:",
	      M.eminence_point_redeem_enable,
	      M.unity_point_redeem_enable)
	if M.eminence_point_redeem_enable and eminence_point > 1000 then
	    command.send("ac move def2emi")
	elseif M.unity_point_redeem_enable and unity_point > 9 then
	    command.send("ac move def2nuna")
	else
	    -- モグハウスに行く
	    windower.ffxi.run(26 - me.x, -128 - me.y)
	end
    --elseif string.contains(text, "まいどありにゃ〜") then
    elseif string.contains(text, "まいどありにゃ") then
	push_keys({3, "escape", "escape"})  -- 選択肢メニューを消す
	command.send("ac move -def2nuna")
    elseif string.contains(text, "次週までアイテムおよび特殊素材の交換が制限されます。") then
	M.unity_point_redeem_enable = false
    elseif string.contains(text, "はにゃあ？") then
	if not M.unity_point_redeem_enable then
	    io_chat.warn("ユニティ交換はもう終わってます")
	end
	if unity_point < 10 then
	    io_chat.warn("ユニティポイントが足りません", unity_point)
	    M.unity_point_redeem_enable = false
	    return
	end
	local n = acitem.inventory_freespace_num()
	local exchange_point = n * 99
	if unity_point < exchange_point then
	    exchange_point  = unity_point
	end
	if 5000 < exchange_point then
	    exchange_point = 5000
	end
	local unity_point_div_10 = math.floor(ac_char.unity_point()/10)
	if unity_point_div_10 < exchange_point then
	    exchange_point = unity_point_div_10
	end
	push_keys({1, "right", "down", "enter"}) -- どうする？
	push_keys({2, "right", "right", "right", "enter"}) -- 次へ進む
	push_keys({2, "right", "right", "enter"}) -- プライズパウダー
	io_chat.info("ユニティポイント交換額", exchange_point)
	coroutine.sleep(3)
	for c in tostring(exchange_point):gmatch(".") do
	    -- io_chat.print(c)
	    -- push_keys({c}) -- これで数字入力できない。
	    M.dialog_keyinput(c)
	    coroutine.sleep(0.5)
	end
	push_keys({"enter"})
    end
end

function M.dialog_keyinput(c)
    -- command.send("keyboard_sendstring "..c)  -- say で出ちゃった
    command.send("keyboard_type "..c)
end

return M
