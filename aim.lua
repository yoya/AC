local M = {}

-- Idle, Leveling, Ambus, Works, Mission
M.Idle = 0
M.Leveling = 1
M.Ambus = 2
M.Works = 4
M.Mission = 8
M.AbysYellow = 16
M.allAims = {M.Leveling, M.Ambus, M.Works, M.Mission}

M.aim = M.Idle

return M
