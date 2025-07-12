-- ナイト

local M = {}

M.mainJobProbTable = {
    { 200, 45, 'input /ma フラッシュ <t>', 1 },
    -- { 100, 60, 'input /ma ホーリーII <t>', 2 },
    { 100, 180, 'input /ma リアクト <me>', 4 },
    { 100, 300-10, 'input /ma クルセード <me>', 4 },
    { 40, 60, 'input /ma ケアルIII <me>', 3 },
    { 100, 180, 'input /ja ランパート <me>; wait 1; input /ja マジェスティ <me>; wait 1; input /ma ケアルIII <me>', 7 },
    { 100, 180-10, 'input /ma エンライト <me>', 3 },
    { 100, 600, 'input /ja フィールティ <me>', 0 },
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 300, 'input /ja パリセード <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

M.subJobProbTable = {
    { 200, 45, 'input /ma フラッシュ <t>', 1 },
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

return M
