local M = {}

local utils_table = require "utils/table"

function M.print(v)
    local text = type(v) == "string" and v or utils_table.tableToString(v)
    windower.add_to_chat(17, windower.to_shift_jis(text))
end

return M
