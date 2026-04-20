-- 怨念洞

local M = { id = 160 }

local acitem = require 'item'

function M.statprint_handler()
    print("zone/160 statprint_handler")
    local items = {
	1137, -- 僧のカギ
    }
    acitem.showOwnItems(items)
end

M.event_handlers = {
    { event_type="statprint", handler=M.statprint_handler }
}

return M

