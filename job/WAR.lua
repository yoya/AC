-- 戦士

local M = {}

M.mainJobProbTable = {
    { 60, 300, 'input /ja ウォークライ <me>', 0 },
    -- { 60, 10, 'input /ja バーサク <me>', 0 },
    -- { 60, 10, 'input /ja アグレッサー <me>', 0 },
    { 60, 10, 'input /ja ブラッドレイジ <me>', 0 },
    { 60, 60, 'input /ja 挑発 <t>', 0 },
    { 60, 10, 'input /ja リストレント <me>', 0 },
    { 60, 10, 'input /ja リタリエーション <me>', 0},
}

M.subJobProbTable = {
    { 60, 300, 'input /ja ウォークライ <me>', 1 },
    { 60, 60, 'input /ja 挑発 <t>', 1 },
    -- { 100, 300, 'input /ja バーサク <me>', 0 },
    { 100, 300, 'input /ja アグレッサー <me>', 0 },
}

return M
