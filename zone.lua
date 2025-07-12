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
    -- 215,216,217,218 アビセア
    [230] = require('zone/230_SSandOria'),  -- 南サンドリア
    [236] = require('zone/236_PortBastok'), -- バストゥーク港
    [237] = require('zone/237_Metalworks'), -- 大工房
    [238] = require('zone/238_WindWaters'), -- ウィンダス水の区
    [239] = require('zone/239_WindWalls'),  -- ウィンダス石の区
    [240] = require('zone/240_PortWind'),   -- ウィンダス港
    [242] = require('zone/242_HeavenTowr'), -- 天の塔
    [243] = require('zone/243_RuLudeGard'), -- ル・ルデの庭
    [244] = require('zone/244_UpJeuno'),    -- ジュノ上層
    [245] = require('zone/245_LowJeuno'),   -- ジュノ下層
    [252] = require('zone/252_Norg'),       -- ノーグ
    -- 253,254 アビセア
    [256] = require('zone/256_WestAdoulin'), -- 西アドゥリン
    [257] = require('zone/257_EastAdoulin'), -- 東アドゥリン
    [258] = require('zone/258_Rala'),       -- ララ水道
    [261] = require('zone/261_Ceizak'),     -- ケイザック古戦場
    [262] = require('zone/262_Hennetiel'),  -- エヌティエル水林
    [263] = require('zone/263_Yorcia'),     -- ヨルシア森林
    [265] = require('zone/265_Morimar'),    -- モリマー台地
    [266] = require('zone/266_Marjami'),    -- マリアミ渓谷
    [267] = require('zone/267_Kamihr'),     -- カミール山麓
    [268] = require('zone/268_SihGates'),   -- シィの門
    [270] = require('zone/270_Cirdas'),     -- シルダス洞窟
    [273] = require('zone/273_WohGates'),   -- ウォーの門
    [274] = require('zone/274_OutRaKaz'),   -- ラ・カザナル宮外郭
    [277] = require('zone/277_RaKazTurris'), -- ラ・カザナル宮天守
    [281] = require('zone/281_Leafallia'),  -- リファーリア
}

return M
