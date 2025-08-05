-- 統計情報。
-- 倒した敵の count とか

local M = {
    DefeatedEnemyTable = {}
}

local io_chat = require('io/chat')

function M.init()
    M.DefeatedEnemyTable = {}
end

function M.defeat(name)
    if M.DefeatedEnemyTable[name] == nil then
	M.DefeatedEnemyTable[name] = 0
    end
    M.DefeatedEnemyTable[name] = M.DefeatedEnemyTable[name] + 1
end

function M.print()
    local total = 0
    io_chat.setNextColor(5)
    io_chat.print("=== Defeated Enemy Table ===");
    for name, count in pairs(M.DefeatedEnemyTable) do
	io_chat.setNextColor(6)
	io_chat.print(name .. ": "..count);
	total = total + count
    end
    io_chat.setNextColor(5)
    io_chat.print("=> Total: "..total);
end

return M
