-- 地脈調査

local M = {}

local keyboard = require 'keyboard'
-- local io_chat = require 'io/chat'
local incoming_text = require 'incoming/text'
local control = require 'control'

M.auto = false
    
function M.ergonLocusFunction()
    keyboard.pushKeys({"numpad5"})
    M.auto = true
    while(M.auto)
    do
	keyboard.pushKeys({"f8", "numpad*", "numpad2", "enter"})
	coroutine.sleep(3)
	keyboard.pushKeys({"up", "enter"})
	coroutine.sleep(3)
    end
    M.auto = false
    keyboard.pushKeys({"escape"})
end

function M.incoming_text_handler(text)
    if not M.auto then return end -- auto 時だけ処理
    if string.contains(text, "ワークスコールを達成した") or
	string.contains(text, "すでに調査を終えています") then
	M.auto = false
	keyboard.pushKeys({"escape"})
    elseif string.contains(text, "ターゲットが範囲外です") then
	M.auto = false
	keyboard.pushKeys({"escape"})
    end
end

M.listener_id = incoming_text.addListener("", M.incoming_text_handler)

return M
