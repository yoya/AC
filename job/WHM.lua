-- 白魔道士

local role_Healer = require 'role/Healer'

local M = {}

M.mainJobProbTable = {
    -- { 100, 120, 'input /ma ディア <t>', 3, true },
    { 100, 120, 'input /ma ディアII <t>', 3, true  },
    { 100, 120, 'input /ma スロウ <t>', 3, true },
    { 100, 120, 'input /ma パライズ <t>', 3, true },
    -- { 100, 120, 'input /ma アドル <t>', 3, true },
    { 50, 300-100, 'input /ma アディデック <me>', 5 },
    -- { 100, 180, 'input /ma オースピス <me>', 1 },
    { 50, 600-300, 'input /ma バウォタラ <me>', 1 },
    { 100, 120, 'input /ma リジェネIV <p1>', 6 },
    -- { 100, 120, 'input /ma リジェネIV <p2>', 6 },
    -- { 100, 120, 'input /ma リジェネIII <p1>', 6 },
    { 100, 120, 'input /ma リジェネIII <p2>', 6 },
    -- { 100, 120, 'input /ma リジェネIII <p2>', 6 },
    { 100, 120, 'input /ma ヘイスト <p1>', 6 },
    { 100, 120, 'input /ma ヘイスト <p2>', 6 },
    { 100, 120, 'input /ma ヘイスト <p3>', 6 },
    --  { 100, 120, 'input /ma ヘイスト <p3>', 6 },
    { 100, 180, 'input /ja ハートオブソ\ラス <me>', 0 },
    -- { 100, 600, 'input /ja 女神の聖域 <me>', 0 },
    { 10, 300, 'input /ma リレイズIV <me>', 0 },
    { 500, 60, 'input /ma ケアル <p1>', 3 },
    -- { 500, 60, 'input /ma ケアル <p2>', 3 },
    -- { 200, 60, 'input /ma ケアルII <p1>', 3 },
    { 10, 300, 'input /ma ブリンク <me>', 5},
    { 10, 300, 'input /ma ストンスキン <me>', 5},
    { 100, 60, 'input /ma バニシュ <t>', 3 },
    -- { 100, 60, 'input /ma バニシュII <t>', 3 },
    -- { 100, 60, 'input /ma バニシュIII <t>', 3 },
    -- { 100, 60, 'input /ma ホーリー <t>', 3 },
    -- { 100, 60, 'input /ma ホーリーII <t>', 3 },
    { 200, 600/2, 'input /ja デヴォーション <p2>', 0 },
}

M.subJobProbTable = {
    { 5, 600-60, 'input /ma アクアベール <me>', 7},
    { 5, 300-30, 'input /ma ブリンク <me>', 7},
    { 5, 300-30, 'input /ma ストンスキン <me>', 8},
    { 100, 120-30, 'input /ma ヘイスト <p1>', 6 },
}

function M.main_tick(player)
    if role_Healer.main_tick ~= nil then
	role_Healer.main_tick(player)
    end
end

function M.sub_tick(player)
    if role_Healer.sub_tick ~= nil then
	role_Healer.sub_tick(player)
    end
end

return M
