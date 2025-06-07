---
--- Prob
--- 確率的なコマンド実行

--- packets = require 'packets'

utils = require 'autoutils'
local merge_tables = utils.merge_tables

local M = {}

--- job = { probPermil(1/1000), recast, command, wait }

--- local SMN_summon_head = "input /pet 神獣の帰還 <me>; wait 3; "
--- local SMN_summon_tail = "; wait 3; input /pet 神獣の帰還 <me>"
local SMN_summon_head = ""
local SMN_summon_tail = "; wait 3; input /pet 神獣の攻撃 <t>"

--- 通常の的
---local GEO_inde = "インデフューリー"
--local GEO_inde = "インデヘイスト"
--local GEO_geo = "ジオフレイル"  -- 防御down
local GEO_inde2 = "インデヒューリー" -- 攻撃力up
local GEO_geo2 = "ジオトーパー" -- 回避down
--- 格上の敵
---local GEO_inde = "インデプレサイス" --- 命中up
--- 醴泉島かえる
local GEO_inde = "インデリジェネ"
local GEO_geo = "ジオバリア"  -- 防御down

--- アンバス用
--- local GEO_inde = "インデバリア" --- アンバス物防up
---local GEO_geo = "ジオアトゥーン" --- 魔回避down
---local GEO_inde = "インデフェンド" --- アンバス魔防up
--- カオス戦用
--- local GEO_inde = "インデフェンド" --- アンバス魔防up

local sendCommandProbTable = {
    WAR = {
        { 60, 300, 'input /ja ウォークライ <me>', 0 },
---        { 60, 10, 'input /ja バーサク <me>', 0 },
---        { 60, 10, 'input /ja アグレッサー <me>', 0 },
        { 60, 10, 'input /ja ブラッドレイジ <me>', 0 },
        { 60, 60, 'input /ja 挑発 <t>', 0 },
        { 60, 10, 'input /ja リストレント <me>', 0 },
        { 60, 10, 'input /ja リタリエーション <me>', 0},
    },
    MNK = {
        { 60, 180, 'input /ja 集中 <me>', 0 },
        { 60, 180, 'input /ja チャクラ <me>', 0 },
        { 60, 600, 'input /ja マントラ <me>', 0 },
        { 60, 300, 'input /ja 猫足立ち <me>', 0 },
        { 60, 300, 'input /ja インピタス <me>', 0 },
    },
    WHM = {
--        { 100, 120, 'input /ma ディア <t>', 3 },
        { 100, 120, 'input /ma ディアII <t>', 3 },
--      { 100, 120, 'input /ma スロウ <t>', 3 },
--      { 100, 120, 'input /ma パライズ <t>', 3 },
--        { 100, 120, 'input /ma アドル <t>', 3 },
        { 50, 300-100, 'input /ma アディデック <me>', 5 },
--        { 100, 180, 'input /ma オースピス <me>', 1 },
        { 50, 600-300, 'input /ma バウォタラ <me>', 1 },
--       { 100, 120, 'input /ma リジェネIV <p1>', 6 },
--       { 100, 120, 'input /ma リジェネIV <p2>', 6 },
        { 100, 120, 'input /ma リジェネIII <p1>', 6 },
--        { 100, 120, 'input /ma リジェネIII <p2>', 6 },
        { 100, 120, 'input /ma ヘイスト <p1>', 6 },
        { 100, 120, 'input /ma ヘイスト <p2>', 6 },
--        { 100, 120, 'input /ma ヘイスト <p3>', 6 },
        { 100, 180, 'input /ja ハートオブソ\ラス <me>', 0 },
--        { 100, 600, 'input /ja 女神の聖域 <me>', 0 },
        { 10, 300, 'input /ma リレイズIV <me>', 0 },
--        { 500, 60, 'input /ma ケアル <p1>', 3 },
--      { 200, 60, 'input /ma ケアルII <p1>', 3 },
        { 10, 300-30, 'input /ma ブリンク <me>', 5},
        { 10, 300-30, 'input /ma ストンスキン <me>', 5},
--        { 100, 60, 'input /ma バニシュ <t>', 3 },
--      { 100, 60, 'input /ma バニシュII <t>', 3 },
--        { 100, 60, 'input /ma バニシュIII <t>', 3 },
--        { 100, 60, 'input /ma ホーリー <t>', 3 },
--        { 100, 60, 'input /ma ホーリーII <t>', 3 },
        { 100, 600, 'input /ja デヴォーション <p2>', 0 },
    },
    BLM = {
        { 100, 10, 'input /ma ブリザドII <t>', 2 },
        { 100, 10, 'input /ma ブリザドIII <t>', 3 },
--      { 100, 10, 'input /ma ブリザドIV <t>', 4 },
--      { 100, 10, 'input /ma ブリザドV <t>', 5 },
--        { 100,10, 'input /ma サンダー <t>', 2 },
        { 200,10, 'input /ma サンダーII <t>', 2 },
        { 400, 10, 'input /ma サンダーIII <t>', 3 },
--      { 200, 10, 'input /ma サンダーIV <t>', 4 },
--        { 100, 10, 'input /ma サンダーV <t>', 5 },
--[[
        { 200,10, 'input /ma バイオ <t>', 2 },
        { 200,10, 'input /ma ドレイン <t>', 2 },
        { 200,10, 'input /ma スタン <t>', 2 },
        { 200,10, 'input /ma ストーン <t>', 2 },
        { 200,10, 'input /ma ブリザド <t>', 2 },
]]
        { 100, 10, 'input /ma ショックスパイク <me>', 5 },
     },          
    RDM = {
        { 200, 300*2, 'input /ja コンポージャー <me>', 0 },
        { 100, 30, 'input /ma ディスペル <t>', 3 },
        { 200, 180, 'input /ma ディアIII <t>', 3 },
        { 100, 300, 'input /ma ディストラII <t>', 4 },
        { 100, 180*3, 'input /ma ストライII <me>', 4 },
        { 100, 300*3, 'input /ma ゲインデック <me>', 4 },
        { 100, 150*3, 'input /ma リフレシュIII <me>', 4 },
        { 100, 180, 'input /ma エンサンダーII <me>', 4 },
--     { 100, 180, 'input /ma エンストーンII <me>', 4 },
        { 100, 180, 'input /ma ヘイストII <p1>', 3 },
        { 100, 180*3, 'input /ma ヘイストII <me>', 3 },
        { 5, 600-60, 'input /ma アクアベール <me>', 5},
        { 5, 300-30, 'input /ma ブリンク <me>', 5},
        { 5, 300-30, 'input /ma ストンスキン <me>', 5},
    },
    THF = {
        { 10, 300, 'input /ja ぬすむ <t>', 0 },
        { 10, 300, 'input /ja かすめとる <t>', 0 },
        { 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja 不意打ち <me>; wait 1; input /ws マンダリクスタッブ <t>', 0 },
        { 50, 180, 'input /ja フェイント <me>', 0 },
        { 50, 300, 'input /ja コンスピレーター <me>', 0 },
        { 10, 180, 'input /ja まどわす <t>', 0 },
        { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja だまし討ち <me>; wait 1; input /ws マンダリクスタッブ <t>', 0 },
    },
    PLD = {
        { 200, 60, 'input /ma フラッシュ <t>', 1 },
---        { 100, 60, 'input /ma ホーリーII <t>', 2 },
        { 100, 120, 'input /ma リアクト <me>', 4 },
        { 100, 120, 'input /ma クルセード <me>', 4 },
        { 40, 60, 'input /ma ケアルIII <me>', 3 },
        { 100, 180, 'input /ja ランパート <me>; wait 1; input /ja マジェスティ <me>; wait 1; input /ma ケアルIII <me>', 7 },
        { 100, 180-20, 'input /ma エンライト <me>', 3 },
        { 100, 600-100, 'input /ja フィールティ <me>', 0 },
        { 100, 300, 'input /ja センチネル <me>', 0 },
        { 100, 300, 'input /ja パリセード <me>', 0 },
        { 100, 180, 'input /ja かばう <p1>', 0 },
    },
    DRK = {
        { 100, 180-30, 'input /ma エンダークII <me>', 3 },
        { 100, 180, 'input /ma ドレッドスパイク <me>', 3 },
        { 60, 120, 'input /ma ドレインIII <t>', 3 },
        { 100, 120, 'input /ma アブゾースト <t>', 3 },
        { 100, 120, 'input /ma アブゾアキュル <t>', 3 },
        { 100, 3000, 'input /ja ラストリゾート <me>', 0 },
        { 100, 3000, 'input /ja ディアボリクアイ <me>', 0 },
        { 100, 180, 'input /ja コンスームマナ <me>', 0 },
    },
    BST = {
        { 100, 1200, 'input /ja しょうしゅう <me>', 0 },
        { 200, 1200, 'input /pet たたかえ <t>', 0 },
---        { 500, 15, 'input /pet センシラブレード <t>', 0 },
    },
    BRD = {
        { 100, 120, 'input /ma 重装騎兵のミンネIV <me>', 7 },
        { 200, 60, 'input /ma 重装騎兵のミンネV <me>', 7 },
        { 200, 60, 'input /ma 闘龍士のマンボ <me>', 7 },
        { 200, 60, 'input /ma 活力のエチュード <me>', 7 },
        { 200, 60, 'input /ma 戦士達のピーアンVI <me>', 7 },
--[[
        { 150, 120, 'input /ma 無敵の進撃マーチ <me>', 7 },
        { 150, 120, 'input /ma 栄光の凱旋マーチ <me>', 7 },
        { 150, 120, 'input /ma 猛者のメヌエットV <me>', 7 },
        { 50, 180, 'input /ma 猛者のメヌエットIV <me>', 7 },
        { 50, 180, 'input /ma 剣豪のマドリガル <me>', 7 },
        { 50, 180, 'input /ma 怪力のエチュード <me>', 7 },
        { 50, 180, 'input /ma 妙技のエチュード <me>', 7 },
]]
--        { 100, 60, 'input /ma 魔法のフィナーレ <t>', 7 },
--        { 200, 120, 'input /ma 修羅のエレジー <t>', 7 },
--       { 200, 120, 'input /ma 魔物のレクイエムVII <t>', 7 },
        { 200, 120, 'input /ma 光のスレノディII <t>', 7 },
    },
    SAM = {
        { 100, 180, 'input /ja 黙想 <me>', 1 },
        { 200, 60-10, 'input /ja 八双 <me>', 1 }, -- 攻撃
--        { 100, 60, 'input /ja 星眼 <me>', 1 }, -- 防御
        { 100, 180, 'input /ja 先義後利 <me>', 1 },
        { 100, 180, 'input /ja 渾然一体 <me>', 1 },
        { 100, 180, 'input /ja 石火之機 <me>', 1 },
    },
    SMN = {
        { 200, 180, 'input /pet 神獣の加護 <me>;', 0 },
        { 200, 30, 'input /pet 神獣の攻撃 <t>;', 0 },
        { 500, 15, 'input /pet 神獣の帰還 <me>;', 0 },
---        { 50, 1200 / 50, 'input /ma タイタン召喚 <me>; wait 7; input /pet 大地の守り <me>; wait 3; input /pet 神獣の攻撃 <t>;', 15 },
        { 50, 1200 / 50, SMN_summon_head .. 'input /ma イフリート召喚 <me>; wait 7; input /pet 紅蓮の咆哮 <me>; wait 3; input /pet メテオストライク <t>' .. SMN_summon_tail, 15 },
        { 50, 1200 / 10,  SMN_summon_head .. 'input /ma ガルーダ召喚 <me>; wait 7; input /pet ヘイスガII <me>; wait 3; input /pet ウインドブレード <t>' .. SMN_summon_tail, 15 },
        { 50, 1200 / 20,  SMN_summon_head .. 'input /ma シヴァ召喚 <me>; wait 7; input /pet クリスタルブレシング <me>; wait 3; input /pet ヘヴンリーストライク <t>' .. SMN_summon_tail, 15 },
        { 50, 1200 / 20,  SMN_summon_head .. 'input /ma フェンリル召喚 <me>; wait 7; input /pet 上弦の唸り <me>; wait 3; input /pet インパクト <t>' .. SMN_summon_tail, 15 },
        { 5, 1200 / 10,  SMN_summon_head .. 'input /ma ケット・シー召喚 <me>; wait 7; input /pet リレイズII <me>' .. SMN_summon_tail, 15 },
        { 1, 1200 / 10,  SMN_summon_head .. 'input /ma ケット・シー召喚 <me>; wait 7; input /pet リレイズII <p1>' .. SMN_summon_tail, 15 },
        { 1, 1200 / 10,  SMN_summon_head .. 'input /ma ケット・シー召喚 <me>; wait 7; input /pet リレイズII <p2>' .. SMN_summon_tail, 15 },
        { 10, 300 / 2,  SMN_summon_head .. 'input /ma 光精霊召喚 <me>; wait 7; input /ja エレメントサイフォン <me>' .. SMN_summon_tail, 15 },
    },
    BLU = {
        { 100, 90, 'input /ma コクーン <me>', 3 },
        { 100, 60, 'input /ma シンカードリル <t>', 4 },
        { 50, 60, 'input /ma いやしの風 <me>', 6 },
---     { 50, 300, 'input /ma エラチックフラッター <me>', 3 },
    },
    COR = {
---            { 200, 60, 'input /ja コルセアズロール <me>; wait 2; input /ja ダブルアップ <me>', 0 },
            { 50, 300-30, 'input /ja ブリッツァロール <me>', 1 },
            { 100, 60, 'input /ja サムライロール  <me>', 1 },
            { 100, 60, 'input /ja カオスロール  <me>', 1 },
            { 100, 60, 'input /ja ファイターズロール  <me>', 1 },
---         { 100, 60, 'input /ja メガスズロール  <me>', 1 },
---            { 100, 60, 'input /ja ウィザーズロール  <me>', 1 },
--[[
            { 100, 60, 'input /ja ガランツロール <me>', 1 },
            { 100, 60, 'input /ja ダンサーロール <me>', 1 },
            { 100, 60, 'input /ja ダンサーロール <me>', 1 },
]]
    },
    PUP = {
        { 100, 1200, 'input /ja アクティベート <me>', 0 },
        { 100, 60, 'input /ja 応急処置 <me>', 0 },
        { 500, 60, 'input /pet ディプロイ <t>', 0 },
        { 200, 300, 'input /ja クールダウン <me>', 0 },
        { 200, 90, 'input /pet ファイアマニューバ <me>', 0 },
        { 100, 90, 'input /pet ライトマニューバ <me>', 0 },
    },
    DNC = {
--     {50, 300-30, 'input /ja 剣の舞い <me>', 0 },
        {50, 300-30, 'input /ja 扇の舞い <me>', 0 },
        {50, 90-10, 'input /ja ヘイストサンバ <me>', 0 },
        {50, 90-10, 'input /ja ドレインサンバII <me>', 0 },
        {100, 60, 'input /ja B.フラリッシュ <me>', 0 },
        {100, 90, 'input /ja C.フラリッシュ <me>', 0 },
        {100, 90, 'input /ja S.フラリッシュ <me>', 0 },
        {100, 90, 'input /ja T.フラリッシュ <me>', 0 },
        {100, 30, 'input /ja クイックステップ <t>', 0 },
        {100, 30, 'input /ja ボックスステップ <t>', 0 },
    },
    SCH = {
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
---        { 100, 30, 'input /ma サンダーII <t>', 2},
---        { 200, 30, 'input /ma サンダーIII <t>', 3},
---        { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
---     { 100, 120-30, 'input /ma ヘイスト <p2>', 4 },
    },
    RUN = { 
        { 50, 60, 'input /ja ビベイシャス <me>', 0 },
        { 100, 30, 'input /ja スルポール <me>', 0 },
        { 100, 60, 'input /ja ヴァリエンス <me>', 0 },
        { 50, 300, 'input /ja ソ\ードプレイ <me>', 0 },
        { 50, 300, 'input /ja バットゥタ <me>', 0 },
        { 10, 300, 'input /ja ワンフォアオール <me>', 0 },
        { 50, 60, 'input /ma リジェネIV <me>', 5},
        { 50, 120, 'input /ma ファランクス <me>', 4},
        { 50, 120, 'input /ma フォイル <me>', 4},
        { 50, 300, 'input /ma クルセード <me>', 4},
        { 100, 30, 'input /ma フラッシュ <t>', 1},
    },
    GEO = {
        { 100, 120, 'input /ma ケアル <p1>', 3 },
        { 100, 120, 'input /ma ヘイスト <p2>', 3 },
        { 100, 30, 'input /ma サンダー <t>', 3},
--[[
        { 100, 30, 'input /ma サンダーII <t>', 3},
        { 100, 30, 'input /ma サンダーIII <t>', 3},
        { 100, 30, 'input /ma サンダーIV <t>', 4},
]]
--        { 100, 30, 'input /ma ブリザドII <t>', 3},
--        { 100, 30, 'input /ma ブリザドIII <t>', 3},
--        { 100, 30, 'input /ma ブリザドIV <t>', 4},
    },
    GEO_1 = {
        { 150, 300/3, 'input /ma '..GEO_geo..' <t>; wait 1; input /ja サークルエンリッチ <me>', 6 },
        { 250, 20, 'input /ma '..GEO_geo..' <t>', 6 },
--        { 50, 600/2, 'input /ja グローリーブレイズ <me>; wait 1; input /ja フルサークル <me>; wait 1; input /ma '..GEO_geo..' <t>', 12  },
        { 150, 180-30, 'input /ma '..GEO_inde..' <me>', 4 },
        { 10, 600, 'input /ja エントラスト <me>; wait 2; input /ma インデデック <p2>', 6 },
        { 10, 300, 'input /ja メンドハレイション <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
        { 10, 300, 'input /ja レイディアルアルカナ <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
    },
    GEO_2 = {
        { 150, 300/3, 'input /ma '..GEO_geo2..' <t>; wait 1; input /ja サークルエンリッチ <me>', 6 },
        { 250, 20, 'input /ma '..GEO_geo2..' <t>', 6 },
--        { 50, 600/2, 'input /ja グローリーブレイズ <me>; wait 1; input /ja フルサークル <me>; wait 1; input /ma '..GEO_geo2..' <t>', 12  },
        { 150, 180-30, 'input /ma '..GEO_inde2..' <me>', 4 },
        { 10, 600, 'input /ja エントラスト <me>; wait 2; input /ma インデスト <p2>', 6 },
        { 10, 300, 'input /ja メンドハレイション <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
        { 10, 300, 'input /ja レイディアルアルカナ <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
    },
    ALL = {
---     { 200, 900, 'input /item キャパシティリング <me>', 1 },
    },
}

-- サブジョブ用
local sendCommandProbTableSub = {
    WAR = {
        { 60, 300, 'input /ja ウォークライ <me>', 1 },
        { 60, 60, 'input /ja 挑発 <t>', 1 },
        { 100, 300, 'input /ja バーサク <me>', 0 },
        { 100, 300, 'input /ja アグレッサー <me>', 0 },
    },
    MNK = {
        { 100, 120, 'input /ja 集中 <me>', 0 },
    },
    WHN = {
        { 5, 600-60, 'input /ma アクアベール <me>', 5},
        { 5, 300-30, 'input /ma ブリンク <me>', 5},
        { 5, 300-30, 'input /ma ストンスキン <me>', 5},
        { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
    },
    BLM = {
---        { 100, 30, 'input /ma サンダーII <t>', 2},
---        { 200, 30, 'input /ma フロスト <t>', 3},
    },
    RDM = {
--        { 5, 600-60, 'input /ma アクアベール <me>', 5},
        { 5, 300-30, 'input /ma ブリンク <me>', 5},
        { 5, 300-30, 'input /ma ストンスキン <me>', 5},
        { 100, 300-30, 'input /ma リフレシュ <me>', 5},
--        { 250, 120, 'input /ma ディアII <t>', 4 },
--        { 100, 120, 'input /ma ディストラ <t>', 4 },
--        { 100, 120, 'input /ma フラズル <t>', 4 },
--        { 50, 300, 'input /ja コンバート <me>', 1 },
--        { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
--        { 100, 120-30, 'input /ma ヘイスト <p2>', 4 },
--        { 100, 120-30, 'input /ma ヘイスト <p3>', 4 },
    },
    SAM = {
        { 60, 180, 'input /ja 黙想 <me>', 1 },
        { 200, 60-10, 'input /ja 八双 <me>', 1 }, -- 攻撃
--        { 60, 60, 'input /ja 星眼 <me>', 1 }, -- 防御
        { 100, 180, 'input /ja 石火之機 <me>', 1 },
    },
    BLU = {
        { 100, 60, 'input /ma コクーン <me>', 5 },
        { 100, 60, 'input /ma ガイストウォール <me>', 5 },
        { 100, 60, 'input /ma いやしの風 <me>', 5 },
        { 100, 60, 'input /ma シープソ\ング <me>', 5 },
    },
    COR = {
---        { 100, 60, 'input /ja コルセアズロール <me>;'' wait 2; /ja ダブルアップ <me>', 1 },
        { 100, 60, 'input /ja コルセアズロール <me>', 1 },
---        { 100, 60, 'input /ja サムライロール  <me>', 1 },
---     { 100, 60, 'input /ja カオスロール  <me>', 1 },
---     { 100, 60, 'input /ja ファイターズロール  <me>', 1 },
    },
}

M.getSendCommandProbTable = function(mainJob, subJob, rankInJob)
    local merged = {}
    for job, commprob in pairs(sendCommandProbTable) do
        if job == mainJob or job == mainJob..'_'..rankInJob or job == "ALL" then
            merged = merge_tables(merged, commprob)
        end
    end
    for job, commprob in pairs(sendCommandProbTableSub) do
        if job == subJob or job == "ALL" then
            merged = merge_tables(merged, commprob)
        end
    end
    return merged
end 

M.sendCommandProb = function(table, period, ProbRecastTime)
    ---    print("sendCommandProb")
    local rnd = math.random(1, 1000)
    local pp = 0
    local pn = 0
    for i, p_c in ipairs(table) do
        local p = p_c[1]  --- probability
        local r = p_c[2]  --- recast time
        local c = p_c[3]  --- command
        local t = p_c[4]  --- time
---        print(p, r, c, t)
        pn = pp + p*period   
        if ProbRecastTime[c] == nil then
            if pp < rnd and rnd <= pn then
                ProbRecastTime[c] = r
                windower.ffxi.run(false)
                coroutine.sleep(0.25)
                windower.send_command(c)
                if t > 0 then
                    coroutine.sleep(t)
                end
                return true
            end
            pp = pn
        else
            local remain =  ProbRecastTime[c] - period
            if remain > 0 then
                ProbRecastTime[c] = remain
            else
                ProbRecastTime[c] = nil
            end
        end
    end
    return false
end

return M

