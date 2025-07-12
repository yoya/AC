-- 風水士

local M = {}

--- 通常の敵
--local GEO_inde = "インデフューリー"
local GEO_inde = "インデヘイスト"
local GEO_geo = "ジオフレイル"  -- 防御down
local GEO_inde2 = "インデヒューリー" -- 攻撃力up
local GEO_geo2 = "ジオトーパー" -- 回避down
--- 格上の敵
--local GEO_inde = "インデプレサイス" --- 命中up
--- 醴泉島かえる
--local GEO_inde = "インデリジェネ"
--local GEO_geo = "ジオバリア"  -- 防御down

--- アンバス用
--- local GEO_inde = "インデバリア" --- アンバス物防up
---local GEO_geo = "ジオアトゥーン" --- 魔回避down
---local GEO_inde = "インデフェンド" --- アンバス魔防up
--- カオス戦用
--- local GEO_inde = "インデフェンド" --- アンバス魔防up

M.mainJobProbTable = {
    { 100, 120, 'input /ma ケアル <p1>', 3 },
    { 100, 120, 'input /ma ヘイスト <p2>', 3 },
    { 50, 30, 'input /ma サンダー <t>', 3},
    { 50, 30, 'input /ma サンダーII <t>', 3},
    -- { 100, 30, 'input /ma サンダーIII <t>', 3},
    { 50, 30, 'input /ma ファイア <t>', 3},
    { 50, 30, 'input /ma  ファイアII <t>', 3},
    -- { 100, 30, 'input /ma ファイアIII <t>', 3},
    { 50, 30, 'input /ma ブリザド <t>', 3},
    { 50, 30, 'input /ma ブリザドII <t>', 3},
    -- { 100, 30, 'input /ma ブリザドIII <t>', 3},
}

M.mainJobProbTable_1 = {
    { 150, 300/3, 'input /ma '..GEO_geo..' <t>; wait 1; input /ja サークルエンリッチ <me>', 6 },
    { 250, 20, 'input /ma '..GEO_geo..' <t>', 6 },
    -- { 50, 600/2, 'input /ja グローリーブレイズ <me>; wait 1; input /ja フルサークル <me>; wait 1; input /ma '..GEO_geo..' <t>', 12  },
    { 150, 180, 'input /ma '..GEO_inde..' <me>', 4 },
    { 10, 600, 'input /ja エントラスト <me>; wait 2; input /ma インデデック <p2>', 6 },
    { 10, 300, 'input /ja メンドハレイション <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
    { 10, 300, 'input /ja レイディアルアルカナ <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
}

M.mainJobProbTable_2 = {
    { 150, 300/2, 'input /ma '..GEO_geo2..' <t>; wait 1; input /ja サークルエンリッチ <me>', 6 },
    { 250, 20, 'input /ma '..GEO_geo2..' <t>', 6 },
    -- { 50, 600/2, 'input /ja グローリーブレイズ <me>; wait 1; input /ja フルサークル <me>; wait 1; input /ma '..GEO_geo2..' <t>', 12  },
    { 150, 180, 'input /ma '..GEO_inde2..' <me>', 4 },
    { 10, 600, 'input /ja エントラスト <me>; wait 2; input /ma インデスト <p2>', 6 },
    { 10, 300, 'input /ja メンドハレイション <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
    { 10, 300, 'input /ja レイディアルアルカナ <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
}
 
M.subJobProbTable = { }

return M
