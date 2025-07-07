---
--- Zone 毎の情報

local M = {}

local zone_2_CpntLanding = require('zone/2_CpntLanding')
local zone_6_BearclawPn = require('zone/6_BearclawPn')
local zone_7_Attohwa = require('zone/7_Attohwa')
local zone_15_AbysKonscht = require('zone/15_AbysKonscht')
local zone_25_Misareaux = require('zone/25_Misareaux')
local zone_26_Tavnazia = require('zone/26_Tavnazia')
local zone_45_AbysTahrongi = require('zone/45_AbysTahrongi')
local zone_50_WhiteGate = require('zone/50_WhiteGate')
local zone_51_Wajaom = require('zone/51_Wajaom')
local zone_61_Zhayolm = require('zone/61_Zhayolm')
local zone_68_Aydeewa = require('zone/68_Aydeewa')
local zone_80_Southern_SandOria_S = require('zone/80_Southern_SandOria_S')
local zone_82_Jugner_S = require('zone/82_Jugner_S')
local zone_83_Vunkerl_S = require('zone/83_Vunkerl_S')
local zone_89_Grauberg_S = require('zone/89_Grauberg_S')
local zone_273_WohGates = require('zone/273_WohGates')

M.zoneTable = {
    [2] = zone_2_CpntLanding,   -- ギルド桟橋
    [6] = zone_6_BearclawPn,    -- 熊爪嶽
    [7] = zone_7_Attohwa,       -- アットワ地溝
    [15] = zone_15_AbysKonscht  -- アビセア-コンシュタット
    [25] = zone_25_Misareaux,   -- ミザレオ海岸
    [26] = zone_26_Tavnazia,    -- タブナジア地下壕
    [45] = zone_45_AbysTahrongi, -- アビセア-タロンギ
    [50] = zone_50_WhiteGate,   -- アトルガン白門
    [51] = zone_51_Wajaom,      -- ワジャーム樹林
    [61] = zone_61_Zhayolm,     -- ゼオルム火山
    [68] = zone_68_Aydeewa,     -- エジワ蘿洞
    [80] = zone_80_Southern_SandOria_S, -- 南サンドリア〔Ｓ〕
    [82] = zone_82_Jugner_S,    -- ジャグナー森林〔Ｓ〕
    [83] = zone_83_Vunkerl_S,   -- 過去ブンカール
    [89] = zone_89_Grauberg_S,  -- 過去グロウベルグ
    [273] = zone_273_WohGates,  -- ウォーの門
}

return M
