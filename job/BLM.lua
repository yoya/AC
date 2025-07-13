-- 黒魔道士

local M = {}

M.mainJobProbTable = {
    -- { 200, 10, 'input /ma ブリザド <t>', 2 },
    { 200, 10, 'input /ma ブリザドII <t>', 2 },
    { 300, 5, 'input /ma ブリザドIII <t>', 3 },
    { 200, 10, 'input /ma ブリザドIV <t>', 4 },
    -- { 100, 10, 'input /ma ブリザドV <t>', 5 },
    -- { 100,10, 'input /ma ファイア <t>', 2 },
    { 200,10, 'input /ma ファイアII <t>', 2 },
    { 300, 10, 'input /ma ファイアIII <t>', 3 },
    { 200, 10, 'input /ma ファイアIV <t>', 4 },
    -- { 300, 10, 'input /ma ファイアV <t>', 5 },
    -- { 100,10, 'input /ma サンダー <t>', 2 },
    { 200, 5, 'input /ma サンダーII <t>', 2 },
    { 300, 5, 'input /ma サンダーIII <t>', 3 },
    { 200, 10, 'input /ma サンダーIV <t>', 4 },
    -- { 200, 10, 'input /ma サンダーV <t>', 5 },
    -- { 200, 10, 'input /ma サンダーVI <t>', 5 },
    { 500, 90, 'input /ma バーン <t>', 5, true },
    { 500, 90, 'input /ma チョーク <t>', 5, true },
    -- スキル上げ
    -- { 500, 10, 'input /ma ストーン <t>', 2 },
    -- { 200, 10, 'input /ma ファイア <t>', 2 },
    -- { 500, 10, 'input /ma ブリザド <t>', 2 },
    -- { 500, 10, 'input /ma サンダー <t>', 2 },
    -- { 300,10, 'input /ma バイオ <t>', 2 },
    { 300,40, 'input /ma ドレイン <t>',  4},
    --   200,10, 'input /ma スタン <t>', 2 },
    { 200,10, 'input /ma アスピル <t>', 2 },
    { 200,10, 'input /ma アスピルII <t>', 2 },
    -- { 200,10, 'input /ma ディア <t>', 2, true },
    -- { 100, 10, 'input /ma ショックスパイク <me>', 5 },
}

M.subJobProbTable = {
    -- { 100, 30, 'input /ma サンダーII <t>', 2},
    -- { 200, 30, 'input /ma フロスト <t>', 3, true},
}

return M
