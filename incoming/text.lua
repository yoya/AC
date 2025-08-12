-- incoming text の処理

local M = {}

-- { {keyword, callback}, ... }
local listener_table = {}

function M.incoming_handler(data, modified, original_mode, modified_mode, blocked)
    local text = windower.from_shift_jis(data)
    for i, listener in ipairs(listener_table) do
	if string.contains(text, listener.keyword) then
	    listener.callback(text)
	end
    end
end

function M.addListener(keyword, callback)
    assert(type(keyword) == "string")
    assert(type(callback) == "function")
    table.insert(listener_table, {keyword=keyword, callback=callback})
    local idx = #listener_table
    return idx
end

return M
