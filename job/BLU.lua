-- 青魔導士

local M = {}

M.main_job_prob_table = {
    { 100, 90, 'input /ma コクーン <me>', 3 },
    { 100, 60, 'input /ma シンカードリル <t>', 4 },
    { 50, 60*2, 'input /ma いやしの風 <me>', 6 },
    { 50, 300, 'input /ma エラチックフラッター <me>', 3 },
}

M.sub_job_prob_table = {
    { 100, 60, 'input /ma コクーン <me>', 5 },
    { 100, 60, 'input /ma ガイストウォール <me>', 5 },
    { 100, 60, 'input /ma いやしの風 <me>', 5 },
    { 100, 60, 'input /ma シープソング <me>', 5 },
}

return M
