-- 竜騎士

local M = {}

M.mainJobProbTable = {
    { 10, 60*20, 'input /ja コールワイバーン <me>', 2 },
    { 10, 60*1, 'input /ja ジャンプ <me>', 2 },
    { 10, 60*1.5, 'input /ja スピリットリンク <me>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <me>', 2 },
    { 10, 60*3, 'input /ja スーパージャンプ <me>', 2 },
    { 10, 60*3, 'input /ja スピリットボンド <me>', 2 },
    { 10, 60*5, 'input /ja ディープブリージング <me>', 2 },
    -- { 10, 60*3, 'input /ja アンゴン <me>', 2 },
    { 10, 60, 'input /ja スピリットジャンプ <me>', 2 },
    { 10, 60*2, 'input /ja ソウルジャンプ <me>', 2 },
}

M.subJobProbTable = {
    { 10, 60*1, 'input /ja ジャンプ <me>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <me>', 2 },
}

return M
