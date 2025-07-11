--- Job 毎の情報

local M = {}

M.jobTable = {
    WHM = require('job/WHM'), -- 白魔導士
    BLM = require('job/BLM'), -- 黒魔道士
}

return M
