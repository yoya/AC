-- 学者

local M = {}

M.mainJobProbTable = {
    { 100, 3600/36, 'input /ja 白のグリモア <me>', 0 },
    { 100, 3600/36, 'input /ja 白の補遺 <me>', 0 },
    { 100, 300/2, 'input /ja 女神降臨の章 <me>; wait 1; input /ma ストンスキン <me>', 8 },
    { 100, 120, 'input /ja 女神降臨の章 <me>; wait 1; input /ma リジェネV <me>', 8 },
    { 100, 120, 'input /ma リジェネV <p1>', 5 },
    { 100, 120, 'input /ma 悪事千里の策 <p1>', 5 },
    { 100, 120, 'input /ma 暗中飛躍の策 <p2>', 5 },
    { 100, 120, 'input /ma 鼓舞激励の策 <p1>', 5 },
    { 100, 120, 'input /ma 鼓舞激励の策 <p2>', 5 },
    { 50, 120, 'input /ja 机上演習 <me>', 0 },
    -- { 100, 30, 'input /ma サンダーII <t>', 2},
    -- { 200, 30, 'input /ma サンダーIII <t>', 3},
    -- { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p2>', 4 },
}

M.subJobProbTable = { }

return M
