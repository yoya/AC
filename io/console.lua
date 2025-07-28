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
    print(text)
end

return M

