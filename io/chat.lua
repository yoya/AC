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

function M.set_color(col)
    textColor = col
    textColorOnce = false
end
function M.clear_color()
    textColor = nil
end
function M.set_next_color(col)
    textColor = col
    textColorOnce = true
end

function M.print(...)
    local text = ""
    for i, v in pairs({...}) do
	local t = type(v) == "string" and v or utils_table.table_to_string(v)
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
    local success, retval = pcall(string.format, ...)
    if success then
	M.print(retval)
    else
	M.print(debug.traceback())
    end
end

-- 重要なメッセージ
function M.notice(...)
    M.set_next_color(5)  -- 水色
    M.print(...)
end
function M.noticef(...)
    M.set_next_color(5)  -- 水色
    M.printf(...)
end
-- 通常のメッセージ
function M.info(...)
    M.set_next_color(6)  -- エメラルド
    M.print(...)
end
function M.infof(...)
    M.set_next_color(6)  -- エメラルド
    M.printf(...)
end
-- 処理は続くレベルの警告
function M.warn(...)
    M.set_next_color(2)  -- 赤紫
    M.print(...)
end
function M.warnf(...)
    M.set_next_color(2)  -- 赤紫
    M.printf(...)
end
-- 処理を止めるレベルのエラー
function M.error(...)
    M.set_next_color(4)
    M.print(...)
end
function M.errorf(...)
    M.set_next_color(3)  -- オレンジ
    M.printf(...)
end

return M
