local M = {}

local io_chat = require 'io/chat'
local actask = require 'task'
local battle = require 'battle'

M.status_handlers = { }

-- Idle
M.status_handlers[0] = function(new, old)
    -- io_chat.print("status change: Idle")
    actask.setTaskSimple("ac inject currinfo1", 2, 1)
    actask.setTaskSimple("ac inject currinfo2", 3, 1)
    actask.setTaskSimple("//record char", 6, 1)
    if old == 1 then
	--  敵が近くにいない場合、移動用装備に着替える。
	--  -移動用の歌やロールをかける
    end
    if old == 1 or old == 4 then
	-- 1: 戦闘 4:魅了
	battle.finish()
    end
end

M.status_handlers[1] = function(new, old)
    -- io_chat.print("status change: Battle")
    battle.start()
end

-- 魅了
M.status_handlers[4] = function(new, old)
    -- 自分を寝かせるようパーティメンバーの依頼する
end

function M.status_change_handler(new, old)
    local handler = M.status_handlers[new]
    if handler ~= nil then
	handler(new, old)
    end
end

return M
