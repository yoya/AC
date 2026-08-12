-- チョコボレース

local M = {}

local command = require 'command'
local task = require 'task'

function M.incoming_text_handler(text)
    -- レースが終わったらデジョンする
    -- エミネンス目標対応で、レースの連続観戦はしない前提
    if string.contains(text, "次回の開催までごきげんよう！") then
	coroutine.sleep(10)
	task.set_task_simple("ac warp", 1, 5)
    end
end

return M
