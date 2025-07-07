---
--- Zone 毎の情報

local M = {}

local zone_2_CpntLanding = require('zone/2_CpntLanding')
local zone_7_Attohwa = require('zone/7_Attohwa')
local zone_25_Misareaux = require('zone/25_Misareaux')
local zone_26_Tavnazia = require('zone/26_Tavnazia')
local zone_50_AhtUrhgan_Whitegate = require('zone/50_AhtUrhgan_Whitegate')
local zone_61_Zhayolm = require('zone/61_Zhayolm')
local zone_68_Aydeewa = require('zone/68_Aydeewa')
local zone_80_Southern_SandOria_S = require('zone/80_Southern_SandOria_S')
local zone_82_Jugner_S = require('zone/82_Jugner_S')
local zone_83_Vunkerl_S = require('zone/83_Vunkerl_S')
local zone_89_Grauberg_S = require('zone/89_Grauberg_S')
local zone_273_WohGates = require('zone/273_WohGates')

M.zoneTable = {
    [2] = zone_2_CpntLanding,   -- ギルド桟橋
    [7] = zone_7_Attohwa,       -- アットワ地溝
    [25] = zone_25_Misareaux,   -- ミザレオ海岸
    [26] = zone_26_Tavnazia,    -- タブナジア地下壕
    [50] = zone_50_AhtUrhgan_Whitegate, -- アトルガン白門
    [61] = zone_61_Zhayolm,     -- ゼオルム火山
    [68] = zone_68_Aydeewa,     -- エジワ蘿洞
    [80] = zone_80_Southern_SandOria_S, -- 南サンドリア〔Ｓ〕
    [82] = zone_82_Jugner_S,    -- ジャグナー森林〔Ｓ〕
    [83] = zone_83_Vunkerl_S,   -- 過去ブンカール
    [89] = zone_89_Grauberg_S,  -- 過去グロウベルグ
    [273] = zone_273_WohGates,  -- ウォーの門
}

return M
