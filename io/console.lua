local M = {}

local utils = require "utils"

function M.print(v)
    print(utils.tableToString(v))
end

return M

