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
-- M.allContents = {M.Leveling, M.Ambus, M.Works, M.Mission, M.MogGarden}

M.contentsTable = {
    [M.Ambus] = require 'contents/ambus',
}

M.type = M.Idle

function M.tick(player)
    if M.type == M.Idle then
	return
    end
    local tick = M.contentsTable[M.type].tick
    if tick ~= nil then
	tick(player)
    end
end

return M
