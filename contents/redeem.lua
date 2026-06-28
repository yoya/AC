-- 換金(エミネンス、ユニティポイント)
-- zone:256 西アドゥリンでは自動で有効化

local M = {}

local utils = require 'utils'
local command = require 'command'
local incoming_text = require 'incoming/text'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local ac_char = require("ac/char")

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
    local t = windower.ffxi.get_mob_by_target("t")
    -- エミネンス交換後
    if string.contains(text, "sparks to purchase:") then
	--pushKeys({1, "escape", "escape"})
	pushKeys({1, "numpad*"}) -- lock を外す
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
	local eminence_point = ac_char.eminence_point()
	local unity_point = ac_char.unity_point()
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
	pushKeys({3, "escape", "escape"})  -- 選択肢メニューを消す
	command.send("ac move -def2nuna")
    elseif string.contains(text, "次週までアイテムおよび特殊素材の交換が制限されます。") then
	M.unity_point_redeem_enable = false
    end
end

incoming_text.addListener("", M.incoming_text_handler)

return M
