-- ナイト

local M = {}

M.mainJobProbTable = {
    { 200, 60, 'input /ma フラッシュ <t>', 1 },
    -- { 100, 60, 'input /ma ホーリーII <t>', 2 },
    { 100, 120, 'input /ma リアクト <me>', 4 },
    { 100, 120, 'input /ma クルセード <me>', 4 },
    { 40, 60, 'input /ma ケアルIII <me>', 3 },
    { 100, 180, 'input /ja ランパート <me>; wait 1; input /ja マジェスティ <me>; wait 1; input /ma ケアルIII <me>', 7 },
    { 100, 180-20, 'input /ma エンライト <me>', 3 },
    { 100, 600-100, 'input /ja フィールティ <me>', 0 },
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 300, 'input /ja パリセード <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

M.subJobProbTable = {
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

return M
