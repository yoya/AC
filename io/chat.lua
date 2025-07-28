local M = {}

local utils_table = require "utils/table"

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
    windower.add_to_chat(17, windower.to_shift_jis(text))
end

return M
