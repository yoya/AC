-- ワークス関連

local M = {}

M.survey = require("works/survey")  -- 地脈調査
M.boost = require("works/boost")  -- 開拓応援

function M.stop()
    M.survey.auto = false
    M.boost.auto = false
end

return M
