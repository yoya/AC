local M = {}

local utils = require "utils"

function M.print(v)
    local text = utils.tableToString(v)
    windower.add_to_chat(17, windower.to_shift_jis(text))
end

return M
