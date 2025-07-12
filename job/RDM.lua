-- 赤魔導士

local M = {}

M.mainJobProbTable = {
    { 200, 300*2, 'input /ja コンポージャー <me>', 0 },
    { 100, 30, 'input /ma ディスペル <t>', 3 },
    { 200, 180, 'input /ma ディアIII <t>', 3 },
    { 100, 300, 'input /ma ディストラII <t>', 4 },
    { 100, 180*3, 'input /ma ストライII <me>', 4 },
    { 100, 300*3, 'input /ma ゲインデック <me>', 4 },
    { 100, 150*3, 'input /ma リフレシュIII <me>', 4 },
    { 100, 180, 'input /ma エンサンダーII <me>', 4 },
    -- { 100, 180, 'input /ma エンストーンII <me>', 4 },
    { 100, 180, 'input /ma ヘイストII <p1>', 3 },
    { 100, 180*3, 'input /ma ヘイストII <me>', 3 },
    { 5, 600-60, 'input /ma アクアベール <me>', 5},
    { 5, 300-30, 'input /ma ブリンク <me>', 5},
    { 5, 300-30, 'input /ma ストンスキン <me>', 5},
}

M.subJobProbTable = {
    -- { 5, 600-60, 'input /ma アクアベール <me>', 5},
    { 10, 300/2, 'input /ma ブリンク <me>', 5},
    { 10, 300/2, 'input /ma ストンスキン <me>', 5},
    { 100, 300-30, 'input /ma リフレシュ <me>', 5},
    { 100, 300-30, 'input /ma リフレシュ <p2>', 5},
    { 250, 120, 'input /ma ディアII <t>', 4 },
    { 100, 120, 'input /ma ディストラ <t>', 4 },
    { 100, 120, 'input /ma フラズル <t>', 4 },
    { 100, 300, 'input /ja コンバート <me>', 1 },
    -- { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p2>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p3>', 4 },
}

return M
