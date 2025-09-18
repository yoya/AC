local M = {}

local packets = require('packets')

local io_chat = require('io/chat')

local packet_handler = { }

-- Standard Client
packet_handler[0x015] = function(packet)
    -- 一番頻繁に受け取るパケット
end

function M.outgoing_handler(id, data, modified, injected, blocked)
    local handler = packet_handler[id]
    --print("outgoing_handler:",id)
    local done = false
    if handler ~= nil then
	local packet = packets.parse('outgoing', data)
	handler(packet)
	done = true
    end
    if not done then  -- デバッグ用
	-- io_chat.print("outgoing_handler id:".. string.format("0x%03X", id))
    end
end

return M
