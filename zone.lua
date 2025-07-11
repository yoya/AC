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
    [83] = require('zone/83_Vunkerl_S'),    -- 過去ブンカール
    [84] = require('zone/84_Batallia_S'),   -- バタリア丘陵〔Ｓ〕
    [85] = require('zone/85_LaVaule_S'),    -- ラヴォール村〔Ｓ〕
    [89] = require('zone/89_Grauberg_S'),   -- 過去グロウベルグ
    [273] = require('zone/273_WohGates'),   -- ウォーの門
}

return M
