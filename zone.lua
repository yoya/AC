---
--- Zone 毎の情報

local ac_pos = require 'ac/pos'

local M = {}

M.zoneTable = {
    [2] = require('zone/2_CpntLanding'),    -- ギルド桟橋
    [4] = require('zone/4_BibikiBay'),      -- ビビキー湾
    [6] = require('zone/6_BearclawPn'),     -- 熊爪嶽
    [8] = require('zone/8_BoneyardGl'),     -- 千骸谷
    [7] = require('zone/7_Attohwa'),        -- アットワ地溝
    [11] = require('zone/11_OldMoval'),     -- ムバルポロス旧市街
    [13] = require('zone/13_Mine2716'),     -- 2716号採石場
    [15] = require('zone/15_AbysKonscht'),  -- アビセア-コンシュタット
    [24] = require('zone/24_LufaiseMds'),   -- ルフェーゼ野
    [25] = require('zone/25_Misareaux'),    -- ミザレオ海岸
    [26] = require('zone/26_Tavnazia'),     -- タブナジア地下壕
    [32] = require('zone/32_SealionDen'),   -- 海獅子の巣窟
    [33] = require('zone/33_AlTaieu'),      -- アル・タユ
    [34] = require('zone/34_HuXzoi'),       -- フ・ゾイの王宮
    [35] = require('zone/35_RuHmet'),       -- ル・メトの園
    [36] = require('zone/36_EmParadox'),    -- 天象の鎖
    [45] = require('zone/45_AbysTahrongi'), -- アビセア-タロンギ
    [48] = require('zone/48_AlZahbi'),      -- アルザビ
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
    [87] = require('zone/87_BasMarket_S'),  -- バストゥーク商業区〔Ｓ〕
    [89] = require('zone/89_Grauberg_S'),   -- グロウベルグ〔Ｓ〕
    [90] = require('zone/90_Pashhow_S'),    -- パシュハウ沼〔Ｓ〕
    [91] = require('zone/91_RolFields_S'),  -- ロランベリー耕地〔Ｓ〕
    [94] = require('zone/94_WinWaters_S'),  -- ウィンダス水の区〔Ｓ〕
    [98] = require('zone/98_SaurChamp_S'),  -- ソロムグ原野〔Ｓ〕
    [101] = require('zone/101_ERonfaure'),  -- 東ロンフォール
    [102] = require('zone/102_LaTheine'),   -- ラテーヌ高原
    [104] = require('zone/104_Jugner'),     -- ジャグナー森林
    [105] = require('zone/105_Batallia'),   -- バタリア丘陵
    [108] = require('zone/108_Konschtat'),  -- コンシュタット高地
    [111] = require('zone/111_Beaucedine'), -- ボスディン氷河
    [112] = require('zone/112_Xarcabard'),  -- ザルカバード
    [113] = require('zone/113_Teriggan'),   -- テリガン岬
    [121] = require('zone/121_ZiTah'),      -- 聖地ジ・タ
    [124] = require('zone/124_YhoatorJng'), -- ヨアトル大森林
    [125] = require('zone/125_WestAltepa'), -- 西アルテパ砂漠
    [126] = require('zone/126_Qufim'),      -- クフィム島
    [127] = require('zone/127_BehemotDom'), -- ベヒーモスの縄張り
    [132] = require('zone/132_AbysLaThein'), -- アビセア-ラテーヌ
    [136] = require('zone/136_BeaGlacier_S'), -- ボスディン氷河〔Ｓ〕
    [139] = require('zone/139_HorlaisPk'),  -- ホルレーの岩峰
    [142] = require('zone/142_Yughott'),    -- ユグホトの岩屋
    [143] = require('zone/143_Palborough'), -- パルブロ鉱山
    [145] = require('zone/145_Giddeus'),    -- ギデアス
    [147] = require('zone/147_Beadeaux'),   -- ベドー
    [148] = require('zone/148_QulunDome'),  -- クゥルンの大伽藍
    [149] = require('zone/149_Davoi'),      -- ダボイ
    [150] = require('zone/150_MonastiCav'), -- 修道窟
    [151] = require('zone/151_Oztroja'),    -- オズトロヤ城
    [152] = require('zone/152_AltarRoom'),  -- 祭壇の間
    [153] = require('zone/153_Boyahda'),    -- ボヤーダ樹
    [159] = require('zone/159_Uggalepih'),  -- ウガレピ寺院
    [164] = require('zone/164_Garlaige_S'), -- ガルレージュ要塞〔Ｓ〕
    [166] = require('zone/166_Ranguemont'), -- ラングモント峠
    [167] = require('zone/167_Bostaunieu'), -- ボストーニュ監獄
    [168] = require('zone/168_OracleChmb'), -- 宣託の間
    [169] = require('zone/169_Toraimarai'), -- トライマライ水路
    [170] = require('zone/170_FullMoonFn'), -- 満月の泉
    [172] = require('zone/172_Zeruhn'),     -- ツェールン鉱山
    [173] = require('zone/173_Korroloka'),  -- コロロカの洞門
    [182] = require('zone/182_WalkEchoes'), -- ウォークオブエコーズ
    [183] = require('zone/183_Legion'),     -- アブダルスの模型-レギオン
    [184] = require('zone/184_LowDelkfut'), -- デルクフの塔下層
    [190] = require('zone/190_RanpsTomb'),  -- 龍王ランペールの墓
    [193] = require('zone/193_Ordelles'),   -- オルデール鍾乳洞
    [192] = require('zone/192_InHorutoto'), -- 内ホルトト遺跡
    [196] = require('zone/196_Gusgen'),     -- グスゲン鉱山
    [197] = require('zone/197_CrawlNest'),  -- クロウラーの巣
    [201] = require('zone/201_ClstGales'),  -- 突風の回廊
    [202] = require('zone/202_ClstStorms'), -- 雷鳴の回廊
    [203] = require('zone/203_ClstFrost'),  -- 凍結の回廊
    [207] = require('zone/207_ClstFlames'), -- 灼熱の回廊
    [208] = require('zone/208_Quicksand'),  -- 流砂洞
    [209] = require('zone/209_ClstTremor'),  -- 震動の回廊
    [211] = require('zone/211_ClstTides'),   -- 海流の回廊
    [215] = require('zone/215_AbysAttohwa'), -- アビセア-アットワ
    [216] = require('zone/216_AbysMisar'),   -- アビセア-ミザレオ
    [217] = require('zone/217_AbysVunkerl'), -- アビセア-ブンカール
    [218] = require('zone/218_AbysAltepa'),  -- アビセア-アルテパ
    [230] = require('zone/230_SSandOria'),  -- 南サンドリア
    [231] = require('zone/231_NSandOria'),  -- 北サンドリア
    [233] = require('zone/233_ChatdOrag'),  -- ドラギーユ城
    [234] = require('zone/234_BastokMine'), -- バストゥーク鉱山区
    [235] = require('zone/235_BastokMark'), -- バストゥーク商業区
    [236] = require('zone/236_PortBastok'), -- バストゥーク港
    [237] = require('zone/237_Metalworks'), -- 大工房
    [238] = require('zone/238_WindWaters'), -- ウィンダス水の区
    [239] = require('zone/239_WindWalls'),  -- ウィンダス石の区
    [240] = require('zone/240_PortWind'),   -- ウィンダス港
    [241] = require('zone/241_WindWoods'),  -- ウィンダス森の区
    [242] = require('zone/242_HeavenTowr'), -- 天の塔
    [243] = require('zone/243_RuLudeGard'), -- ル・ルデの庭
    [244] = require('zone/244_UpJeuno'),    -- ジュノ上層
    [245] = require('zone/245_LowJeuno'),   -- ジュノ下層
    [246] = require('zone/246_PortJeuno'),  -- ジュノ港
    [247] = require('zone/247_Rabao'),      -- ラバオ
    [249] = require('zone/249_Mhaura'),     -- マウラ
    [251] = require('zone/251_HallOfGods'), -- 神々の間
    [252] = require('zone/252_Norg'),       -- ノーグ
    [253] = require('zone/253_AbysUleg'),   -- アビセア-ウルガラン
    [254] = require('zone/254_AbysGraub'),  -- アビセア-グロウベルグ
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
    [280] = require('zone/280_MogGarden'),  -- モグガーデン
    [281] = require('zone/281_Leafallia'),  -- リファーリア
    [287] = require('zone/287_LegionB'),    -- アブダルスの模型-レギオンB
    [288] = require('zone/288_EschaZiTah'), -- エスカ-ジ・タ
    [291] = require('zone/291_ReisenHenge'), -- 醴泉島-秘境
}

for z, m in pairs(M.zoneTable) do
    if z ~= m.id then
	print("illegal zone:"..z.." module id:"..m.id)
    end
    -- 各々の zone handler から routeTable を参照できるようにする
    m.parent = M
end

function M.getRouteTable(zone)
    local t = M.zoneTable[zone]
    if t ~= nil and t.routes ~= nil then
	return t.routes
    end
    return nil
end

function M.tick(player)
    local zone = windower.ffxi.get_info().zone
    local z = M.zoneTable[zone]
    if z ~= nil then
	local tick = z.tick
	if tick ~= nil then
	    tick(player)
	end
    end
end

function M.isNear(zone, name, distance)
    if zone ~= windower.ffxi.get_info().zone then
	return false
    end
    local z = M.zoneTable[zone]
    if z ~= nil then
	local points = z.essentialPoints
	local me = windower.ffxi.get_mob_by_target("me")
	if points ~= nil and me ~= nil then
	    for name, pos in pairs(points) do
		if ac_pos.distance(me, pos) <= distance then
		    return true
		end
	    end
	end
    end
    return false
end

return M
