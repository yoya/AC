local M = {}
-- 今後、イベントリスナーはここに集約する

-- { {event_type, callback}, ... }
M.listener_table = {}
M.listener_table_last_idx = 0

function M.fire_handler(event_type, ...)
    for i, listener in pairs(M.listener_table) do
	if listener ~= nil and listener.event_type == event_type then
	    listener.callback(text)
	end
    end
end

function M.addListener(event_type, callback)
    assert(type(event_type) == "string")
    assert(type(callback) == "function")
    local caller_info = debug.getinfo(2)
    local idx = M.listener_table_last_idx + 1
    M.listener_table_last_idx = idx
    M.listener_table[idx] = { event_type=event_type, callback=callback,
			    caller_info=caller_info }
    return idx
end

function M.removeListener(idx)
    M.listener_table[idx] = nil
end

function M.showListener()
    local io_chat = require 'io/chat'
    io_chat.infof("=== event.showListener: %d", M.listener_table_last_idx)
    for i, listener in pairs(M.listener_table) do
	local caller_info = listener.caller_info
	local caller_name = caller_info.name and caller_info.name or "(nil)"
	local source_path = caller_info.source:sub(windower.addon_path:len()+1)
	io_chat.printf("[%d] event_type=%s caller_func=%s source=%s", i, listener.event_type, caller_name, source_path)
    end
end

return M
