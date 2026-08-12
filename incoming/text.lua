-- incoming text の処理

local M = {}

-- { {keyword, callback}, ... }
local listener_table = {}
local listener_table_last_idx = 0

-- 配信しないチャットモード。
-- 同じ文面が複数のモードで届き、listener が重複して呼ばれるのを防ぐ。
local ignore_mode_set = {
    [152] = true,
}

function M.incoming_handler(data, modified, original_mode, modified_mode, blocked)
    if ignore_mode_set[original_mode] then
	return
    end
    local text = windower.from_shift_jis(data)
    for i, listener in pairs(listener_table) do
	if listener ~= nil and string.contains(text, listener.keyword) then
	    listener.callback(text)
	end
    end
end

function M.duplication_check(keyword, callback)
    for i, listener in pairs(listener_table) do
	if listener.keyword == keyword and listener.callback == callback then
	    return true
	end
    end
    return false
end

function M.add_listener(keyword, callback)
    if type(keyword) ~= "string" or type(callback) ~= "function" then
	print(debug.traceback())
    end
    assert(type(keyword) == "string")
    assert(type(callback) == "function")
    if M.duplication_check(keyword, callback) then
	print("M.duplication_check true")
	return
    end
    local caller_info = debug.getinfo(2)
    local idx = listener_table_last_idx + 1
    listener_table_last_idx = idx
    listener_table[idx] = { keyword=keyword, callback=callback,
			    caller_info=caller_info }
    return idx
end

function M.remove_listener(idx)
    listener_table[idx] = nil
end

function M.show_listener()
    local io_chat = require 'io/chat'
    io_chat.set_next_color(6)
    io_chat.printf("=== incoming/text.show_listener: %d", listener_table_last_idx)
    for i, listener in pairs(listener_table) do
	local caller_info = listener.caller_info
	local caller_name = caller_info.name and caller_info.name or "(nil)"
	local source_path = caller_info.source:sub(windower.addon_path:len()+1)
	io_chat.set_next_color(7)
	io_chat.printf("[%d] keyword=%s caller_func=%s source=%s", i, listener.keyword, caller_name, source_path)
    end
end

return M
