-- 赤魔導士

local M = {}

M.mainJobProbTable = {
    { 500, 300*2, 'input /ja コンポージャー <me>', 2 },
    -- { 100, 30, 'input /ma ディスペル <t>', 3 },
    { 500, 180, 'input /ma ディアIII <t>', 3, true },
    { 500, 300, 'input /ma ディストラII <t>', 4, true },
    { 500, 120, 'input /ma フラズルII <t>', 4, true },
    { 100, 180*3, 'input /ma ストライII <me>', 4 },
    { 100, 300*3, 'input /ma ゲインデック <me>', 4 },
    { 100, 150*3, 'input /ma リフレシュIII <me>', 4 },
    { 100, 150, 'input /ma リフレシュIII <p1>', 4 },
    { 100, 150, 'input /ma リフレシュIII <p2>', 4 },
    { 100, 180, 'input /ma エンサンダーII <me>', 4 },
    -- { 100, 180, 'input /ma エンストーンII <me>', 4 },
    { 100, 180*3, 'input /ma ヘイストII <me>', 3 },
    { 100, 180, 'input /ma ヘイストII <p1>', 3 },
    { 100, 180, 'input /ma ヘイストII <p3>', 3 },
    { 5, 600, 'input /ma アクアベール <me>', 5},
    { 5, 300, 'input /ma ブリンク <me>', 5},
    { 5, 300, 'input /ma ストンスキン <me>', 5},
}

M.subJobProbTable = {
    -- { 5, 600-60, 'input /ma アクアベール <me>', 5},
    { 100, 300, 'input /ma ブリンク <me>', 5},
    { 100, 300, 'input /ma ストンスキン <me>', 5},
    { 500, 300-10, 'input /ma リフレシュ <me>', 5},
    { 500, 300-10, 'input /ma リフレシュ <p2>', 5},
    { 500, 120, 'input /ma ディアII <t>', 4, true },
    { 500, 120, 'input /ma ディストラ <t>', 5, true },
    { 500, 120, 'input /ma フラズル <t>', 5, true },
    { 600/2, 1000, 'input /ja コンバート <me>', 1 },
    { 500, 120-10, 'input /ma ヘイスト <p1>', 4 },
    { 500, 120-10, 'input /ma ヘイスト <p2>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p3>', 4 },
}

return M
