-- 竜騎士

local M = {}

M.mainJobProbTable = {
    { 10, 60*20, 'input /ja コールワイバーン <me>', 2 },
    { 10, 60*1, 'input /ja ジャンプ <t>', 2 },
    { 10, 60*1.5, 'input /ja スピリットリンク <me>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <t>', 2 },
    { 10, 60*3, 'input /ja スーパージャンプ <t>', 2 },
    { 10, 60*3, 'input /ja スピリットボンド <me>', 2 },
    -- { 10, 60*5, 'input /ja ディープブリージング <t>', 2 },
    -- { 10, 60*3, 'input /ja アンゴン <t>', 2 },
    { 10, 60, 'input /ja スピリットジャンプ <t>', 2 },
    { 10, 60*2, 'input /ja ソウルジャンプ <t>', 2 },
}

M.subJobProbTable = {
    { 10, 60*1, 'input /ja ジャンプ <t>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <t>', 2 },
}

return M
