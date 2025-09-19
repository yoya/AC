-- incoming text の処理

local M = {}

-- { {keyword, callback}, ... }
local listener_table = {}
local listener_table_last_idx = 0

function M.incoming_handler(data, modified, original_mode, modified_mode, blocked)
    local text = windower.from_shift_jis(data)
    for i, listener in ipairs(listener_table) do
	if listener ~= nil and string.contains(text, listener.keyword) then
	    listener.callback(text)
	end
    end
end

function M.addListener(keyword, callback)
    assert(type(keyword) == "string")
    assert(type(callback) == "function")
    local caller_info = debug.getinfo(2)
    local idx = listener_table_last_idx + 1
    listener_table[idx] = { keyword=keyword, callback=callback,
			    caller_info=caller_info }
    listener_table_last_idx = idx
    return idx
end

function M.removeListener(idx)
    listener_table[idx] = nil
end

function M.showListener()
    local io_chat = require 'io/chat'
    for i, listener in ipairs(listener_table) do
	local caller_info = listener.caller_info
	local caller_name = caller_info.name and caller_info.name or "(nil)"
	local source_path = caller_info.source:sub(windower.addon_path:len()+1)
	io_chat.printf("[%d] keyword=%s caller_func=%s source=%s", i, listener.keyword, caller_name, source_path)
    end
end

return M
