-- 統計情報。
-- 倒した敵の count とか

local M = {
    DefeatedEnemyTable = {},
    FallingEnemyTable = {},
    WSCount = 0,
}

local io_chat = require('io/chat')

function M.init()
    M.DefeatedEnemyTable = {}
    M.FallingEnemyTable = {}
    M.WSCount = 0
end

function M.defeat(name)
    if M.DefeatedEnemyTable[name] == nil then
	M.DefeatedEnemyTable[name] = 1
    else
	M.DefeatedEnemyTable[name] = M.DefeatedEnemyTable[name] + 1
    end
end

function M.falling(name)
    if M.FallingEnemyTable[name] == nil then
	M.FallingEnemyTable[name] = 1
    else
	M.FallingEnemyTable[name] = M.FallingEnemyTable[name] + 1
    end
end

function M.ws()
    M.WSCount = M.WSCount + 1
end

function tableHasData(t)
    for k, v in pairs(t) do
	return true
    end
    return false
end

function M.print()
    local total = 0
    local datetime = os.date("%X", os.time())
    -- if #M.DefeatedEnemyTable == 0 then -- 駄目
    if tableHasData(M.DefeatedEnemyTable) == false then
	io_chat.print("=== Defeated Enemy Zero === "..datetime);
    else
	io_chat.setNextColor(5)
	io_chat.print("=== Defeated Enemy Table === " .. datetime);
	for name, count in pairs(M.DefeatedEnemyTable) do
	    io_chat.setNextColor(6)
	    io_chat.print(name .. ": "..count);
	    total = total + count
	end
	io_chat.setNextColor(5)
	io_chat.print("=> Total: "..total);
	for name, count in pairs(M.FallingEnemyTable) do
	    io_chat.setNextColor(3)
	    io_chat.print("### Falling "..name .. ": "..count);
	    total = total + count
	end
    end
    if M.WSCount > 0 then
	io_chat.print("### WS Count =  "..M.WSCount)
    end
end

return M
