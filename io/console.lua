local M = {}

local utils_table = require "utils/table"

function M.print(v)
    local text = utils_table.tableToString(v)
    print(text)
end

return M

