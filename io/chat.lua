local M = {}

require('chat') -- string:color
local utils_table = require "utils/table"

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

return M
