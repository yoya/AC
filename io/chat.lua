local M = {}

require('chat') -- string:color (色の定義は addons/libs/chat/colors.lua)
local utils_table = require "utils/table"
-- メッセージ種類の番号なので設定で変わるが、デフォルトだと以下
-- 1: 白
-- 2: 赤紫, 3: オレンジ, 4:ピンク
-- 5: 水色, 6: エメラルド
-- 7: 紫, 8: 明赤紫, 9: 白
-- 10: 肌色
local textColor = nil
local textColorOnce = false

function M.setColor(col)
    textColor = col
    textColorOnce = false
end
function M.clearColor()
    textColor = nil
end
function M.setNextColor(col)
    textColor = col
    textColorOnce = true
end

function M.print(...)
    local text = ""
    for i, v in pairs({...}) do
	local t = type(v) == "string" and v or utils_table.tableToString(v)
	if i == 1 then
	    text = text .. t
	else
	    text = text .. " " .. t
	end
    end
    if textColor ~= nil then
	text = text:color(textColor)
    end
    if textColorOnce == true then
	textColor = nil
	textColorOnce = false
    end
    windower.add_to_chat(17, windower.to_shift_jis(text))
end

function M.printf(...)
    -- local s = string.format(...)
    success, retval = pcall(string.format, ...)
    if success then
	M.print(retval)
    else
	M.print(debug.traceback())
    end
end

-- 処理は続くレベルの警告
function M.warn(...)
    M.setNextColor(2)  -- 赤紫
    M.print(...)
end
function M.warnf(...)
    M.setNextColor(2)  -- 赤紫
    M.printf(...)
end
-- 処理を止めるレベルのエラー
function M.error(...)
    M.setNextColor(4)
    M.print(...)
end
function M.errorf(...)
    M.setNextColor(3)  -- オレンジ
    M.printf(...)
end

return M
