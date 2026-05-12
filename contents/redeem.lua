-- 換金(エミネンス、ユニティポイント)
-- zone:256 西アドゥリンでは自動で有効化

local M = {}

local command = require 'command'
local incoming_text = require 'incoming/text'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

function M.tick(player)
end

function M.incoming_text_handler(text)
    if M.parent.type ~= M.parent.Redeem then
	return
    end
    local me = windower.ffxi.get_mob_by_target("me")
    local t = windower.ffxi.get_mob_by_target("t")
    -- エミネンス交換後
    if string.contains(text, "Sparks Buying Finished.") then
	windower.ffxi.run(24 - me.x, -120 - me.y)
    elseif string.contains(text, "0回売却") then
	print("AAA")
	if t.name == 'Defliaa' then
	    command.send("ac move def2nuna")
	end
    --elseif string.contains(text, "まいどありにゃ〜") then
    elseif string.contains(text, "まいどありにゃ") then
	pushKeys({3, "escape"})
	command.send("ac move -def2nuna")
    end
end

incoming_text.addListener("", M.incoming_text_handler)

return M
