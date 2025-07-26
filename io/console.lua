local M = {}

local utils_table = require "utils/table"

function M.print(v)
    local text = type(v) == "string" and v or utils_table.tableToString(v)
    print(text)
end

return M

