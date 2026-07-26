-- 魔導剣士

local M = {}

M.main_job_prob_table = {
    { 50, 60, 'input /ja ビベイシャス <me>', 0 },
    { 100, 30, 'input /ja スルポール <me>', 0 },
    { 100, 60, 'input /ja ヴァリエンス <me>', 0 },
    { 50, 300, 'input /ja ソードプレイ <me>', 0 },
    { 50, 300, 'input /ja バットゥタ <me>', 0 },
    { 10, 300, 'input /ja ワンフォアオール <me>', 0 },
    { 50, 60, 'input /ma リジェネIV <me>', 5},
    { 50, 120, 'input /ma ファランクス <me>', 4},
    { 50, 120, 'input /ma フォイル <me>', 4},
    { 50, 300, 'input /ma クルセード <me>', 4},
    { 100, 30, 'input /ma フラッシュ <t>', 1},
}

M.sub_job_prob_table = {
    { 50, 300, 'input /ja ソードプレイ <me>', 0 },
}

return M
