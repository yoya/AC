-- 統計情報。
-- 倒した敵の count とか

local io_chat = require('io/chat')

local M = {
    DefeatedEnemyTable = {}
}

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
    io_chat.print("=== Defeated Enemy table ===");
    for name, count in pairs(M.DefeatedEnemyTable) do
	io_chat.print(name .. ": "..count);
    end
end

return M
