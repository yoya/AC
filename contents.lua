local M = {}

-- Idle, Leveling, Ambus, Works, Mission
M.Idle = 0
M.Leveling = 1
M.Ambus = 2
M.Works = 3
M.Trove = 4
M.Mission = 5
M.AbysYellow = 6
M.MogGarden = 7
M.Trial = 8  -- 試練(各属性プロトクリスタル)
M.Raives = 9
-- M.allContents = {M.Leveling, M.Ambus, M.Works, M.Mission, M.MogGarden, M.Trial, M.Raives}

M.ambus = require 'contents/ambus'
M.trial = require 'contents/trial'
M.raives = require 'contents/raives'

M.contentsTable = {
    [M.Ambus] = M.ambus,
    [M.Trial] = M.trial,
    [M.Raives] = M.raives,
}

M.type = M.Idle

function M.tick(player)
    if M.type == M.Idle then
	return
    end
    if M.contentsTable[M.type] == nil then
	return  -- 未対応
    end
    local tick = M.contentsTable[M.type].tick
    if tick ~= nil then
	tick(player)
    end
end

return M
