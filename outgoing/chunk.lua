local M = {}

local packets = require('packets')

local zone_zonein = require('zone/zonein')


local packet_handler = { }

-- Standard Client
packet_handler[0x015] = function(packet)
    -- 一番頻繁に受け取るパケット
end

-- Zone In 3。クライアントが背景の読み込みを終えて送る、ゾーンインの最後の
-- パケット。これより前に動くと、背景が出ないまま操作不能になる事がある
packet_handler[0x011] = function(packet)
    zone_zonein.notify_done()
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
