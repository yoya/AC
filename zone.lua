---
--- Zone 毎の情報

local M = {}

M.zoneTable = {
    [2] = require('zone/2_CpntLanding'),    -- ギルド桟橋
    [6] = require('zone/6_BearclawPn'),     -- 熊爪嶽
    [7] = require('zone/7_Attohwa'),        -- アットワ地溝
    [15] = require('zone/15_AbysKonscht'),  -- アビセア-コンシュタット
    [25] = require('zone/25_Misareaux'),    -- ミザレオ海岸
    [26] = require('zone/26_Tavnazia'),     -- タブナジア地下壕
    [45] = require('zone/45_AbysTahrongi'), -- アビセア-タロンギ
    [50] = require('zone/50_WhiteGate'),    -- アトルガン白門
    [51] = require('zone/51_Wajaom'),       -- ワジャーム樹林
    [61] = require('zone/61_Zhayolm'),      -- ゼオルム火山
    [68] = require('zone/68_Aydeewa'),      -- エジワ蘿洞
    [70] = require('zone/70_ChocoCirc'),    -- チョコボサーキット
    [79] = require('zone/79_Caedarva'),     -- カダーバの浮沼
    [80] = require('zone/80_SSandOria_S'),  -- 南サンドリア〔Ｓ〕
    [82] = require('zone/82_Jugner_S'),     -- ジャグナー森林〔Ｓ〕
    [83] = require('zone/83_Vunkerl_S'),    -- ブンカール〔Ｓ〕
    [84] = require('zone/84_Batallia_S'),   -- バタリア丘陵〔Ｓ〕
    [85] = require('zone/85_LaVaule_S'),    -- ラヴォール村〔Ｓ〕
    [89] = require('zone/89_Grauberg_S'),   -- グロウベルグ〔Ｓ〕
    [91] = require('zone/91_RolFields_S'),  -- ロランベリー耕地〔Ｓ〕
    [98] = require('zone/98_SaurChamp_S'),  -- ソロムグ原野〔Ｓ〕
    [102] = require('zone/102_LaTheine'),   -- ラテーヌ高原
    [104] = require('zone/104_Jugner'),     -- ジャグナー森林
    [105] = require('zone/105_Batallia'),   -- バタリア丘陵
    [111] = require('zone/111_Beaucedine'), -- ボスディン氷河
    [112] = require('zone/112_Xarcabard'),  -- ザルカバード
    [124] = require('zone/124_YhoatorJng'), -- ヨアトル大森林
    [125] = require('zone/125_WestAltepa'), -- 西アルテパ砂漠
    [126] = require('zone/126_Qufim'),      -- クフィム島
    [132] = require('zone/132_AbysLaThein'), -- アビセア-ラテーヌ
    [139] = require('zone/139_HorlaisPk'),  -- ホルレーの岩峰
    [142] = require('zone/142_Yughott'),    -- ユグホトの岩屋
    [143] = require('zone/143_Palborough'), -- パルブロ鉱山
    [147] = require('zone/147_Beadeaux'),   -- ベドー
    [148] = require('zone/148_QulunDome'),  -- クゥルンの大伽藍
    [149] = require('zone/149_Davoi'),      -- ダボイ
    [150] = require('zone/150_MonastiCav'), -- 修道窟
    [151] = require('zone/151_Oztroja'),    -- オズトロヤ城
    [152] = require('zone/152_AltarRoom'),  -- 祭壇の間
    [159] = require('zone/159_Uggalepih'),  -- ウガレピ寺院
    [182] = require('zone/182_WalkEchoes'), -- ウォークオブエコーズ
    [184] = require('zone/184_LowDelkfut'), -- デルクフの塔下層
    [273] = require('zone/273_WohGates'),   -- ウォーの門
}

return M
