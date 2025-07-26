-- 暗黒騎士

local M = {}

M.mainJobProbTable = {
    { 100, 180-30, 'input /ma エンダークII <me>', 3 },
    { 100, 180, 'input /ma ドレッドスパイク <me>', 3 },
    { 60, 120, 'input /ma ドレインIII <t>', 3 },
    { 100, 120, 'input /ma アブゾースト <t>', 3, true },
    { 100, 120, 'input /ma アブゾバイト <t>', 3, true },
    { 100, 120, 'input /ma アブゾタック <t>', 3, true },
    { 100, 120, 'input /ma アブゾデック <t>', 3, true },
    { 100, 120, 'input /ma アブゾアキュル <t>', 3, true },
    { 100, 3000, 'input /ja ラストリゾート <me>', 0 },
    -- { 100, 3000, 'input /ja 暗黒 <me>', 0 },
    { 100, 3000, 'input /ja ディアボリクアイ <me>', 0 },
    -- { 100, 180, 'input /ja コンスームマナ <me>', 0 }, -- MP全部消える
    { 100, 90, 'input /ja レッドデリリアム <me>', 0 },
}

M.subJobProbTable = {
    { 100, 3000, 'input /ja ラストリゾート <me>', 0 },
    { 100, 3000, 'input /ja 暗黒 <me>', 0 },
}

return M
