-- 侍

local M = {}

M.mainJobProbTable = {
    { 100, 180, 'input /ja 黙想 <me>', 3 },
    { 200, 60, 'input /ja 八双 <me>', 3 }, -- 攻撃
    -- { 100, 60, 'input /ja 星眼 <me>', 3 }, -- 防御
    { 100, 180, 'input /ja 先義後利 <me>', 3 },
    { 100, 180, 'input /ja 渾然一体 <t>', 3 },
    { 100, 180, 'input /ja 石火之機 <me>', 3 },
}

M.subJobProbTable = {
    { 60, 180, 'input /ja 黙想 <me>', 3 },
    { 200, 60, 'input /ja 八双 <me>', 3 }, -- 攻撃
    -- { 60, 60, 'input /ja 星眼 <me>', 1 }, -- 防御
    { 100, 180, 'input /ja 石火之機 <me>', 1 },
}

return M
