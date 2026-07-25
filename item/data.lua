local M = {}

local utils = require 'utils'

-- 参考) https://raw.githubusercontent.com/Windower/Resources/master/resources_data/items.lua

M.crystal_ids = {
    4096, -- 炎のクリスタル
    4097, -- 氷のクリスタル
    4098, -- 風のクリスタル
    4099, -- 土のクリスタル
    4100, -- 雷のクリスタル
    4101, -- 水のクリスタル
    4102, -- 光のクリスタル
    4103, -- 闇のクリスタル
    4104, -- 炎の塊
--  4105, -- 氷の塊
    4106, -- 風の塊
    4107, -- 土の塊
    4108, -- 雷の塊
    4109, -- 水の塊
    4110, -- 光の塊
    4111, -- 闇の塊
}

M.seal_ids = {
    1126, --- 獣人印章
    1127, --- 獣神印章
    2955, --- 魔人印章
    2956, --- 魔王印章
    2957, --- 魔神印章
}

M.bayld_swap_ids = {
    20543, -- マオチノーリ
    20630, -- アトヤク
    20731, -- シウトレアト
    20740, -- カマトラタシア
    20768, -- カクルジャンソード
    20829, -- イコヨカ
    20992, -- 太鼓鐘
    21233, -- アジュブボウ
    21253, -- アテテペヨルグ
    21257, -- ゾクィティフイツォ
    21334, -- "アニミキーブレット
    21409, -- フォフロンフルート 113装備 ???
    27781, -- ズッフハット
    27736, -- クイアイズヘルム
    27737, -- カブナフハット
    27779, -- クァウピリヘルム
    27780, -- チョカリツリマスク
    28166, -- クイアイズトラウザ
    28305, -- エヘカマルブーツ
    28343, -- チョカリツリブーツ",
}

M.gob_dial_key_ids = {
--  2517,  -- ダイヤルキー#FES
    8973,  -- ダイヤルキー#SP
    9217,  -- ダイヤルキー#Ab
    9218,  -- ダイヤルキー#Fo
    9274,  -- ダイヤルキー#ANV
}

M.cipher_ids = {} --  盟スクロール
for i=10112, 10193 do table.insert(M.cipher_ids,i) end

M.magicScrolls = {} -- 魔法スクロール
-- 魔法/精霊契約書/忍術/歌 (ディア〜イナンデーション)
for i=4606,5106  do table.insert(M.magicScrolls, i) end
-- スロウII,パライズII,ファランクスII
for i=6569,6571  do table.insert(M.magicScrolls, i) end

-- ダイス(戦士のダイス〜迎撃のダイス)
for i=5477,5505  do table.insert(M.magicScrolls, i) end
-- 学者(計〜陣〜策)
for i=6041,6061 do table.insert(M.magicScrolls, i) end
-- 風水(インデリジェネ〜ジオヘイスト)
for i=6073,6132 do table.insert(M.magicScrolls, i) end

M.soulStoneSacks = {
    6486,  -- 古い袋【白魂石】
    6487,  -- 古い袋【緑魂石】
    6488,  -- 古い袋【黒魂石】
} -- 石の袋

M.soulStoneSacksT = utils.table.convertArrayToTrueTable(M.soulStoneSacks)

-- EVWS 取得の試練
M.trialWeapon = {
    16735, -- トライアルアクス
    16793, -- トライアルサイズ
    16892, -- トライアルスピア
    16952, -- トライアルソード
    17456, -- トライアルクラブ
    17507, -- トライアルナックル
    17527, -- トライアルポール
    17616, -- トライアルダガー
    17654, -- トライアルサパラ
    17933, -- トライアルピック
    18144, -- トライアルボウ
    18146, -- トライアルガン
    20749, -- ライアルブレード
    21066, -- トライアルワンド
}

M.trialWeaponT = utils.table.convertArrayToTrueTable(M.trialWeapon)

-- 【包】アシェラ等。(Deed交換品)
M.decItems = {}
for i=6521,6529  do table.insert(M.decItems, i) end

return M
