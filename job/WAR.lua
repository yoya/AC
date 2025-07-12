-- 戦士

local M = {}

M.mainJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 0 },
    -- { 60, 10, 'input /ja バーサク <me>', 0 },
    -- { 60, 300, 'input /ja アグレッサー <me>', 0 },
    { 100, 300, 'input /ja ブラッドレイジ <me>', 0 },
    { 100, 60, 'input /ja 挑発 <t>', 0 },
    { 100, 600, 'input /ja リストレント <me>', 0 },
    { 100, 180, 'input /ja リタリエーション <me>', 0},
}

M.subJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 1 },
    { 100, 60, 'input /ja 挑発 <t>', 1 },
    -- { 100, 300, 'input /ja バーサク <me>', 0 },
    { 100, 300, 'input /ja アグレッサー <me>', 0 },
}

return M
