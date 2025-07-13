---
--- Zone 毎の情報

local M = {}

local acpos = require 'pos'
local io_chat = require 'io/chat'

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
    [113] = require('zone/113_Teriggan'),   -- テリガン岬
    [124] = require('zone/124_YhoatorJng'), -- ヨアトル大森林
    [125] = require('zone/125_WestAltepa'), -- 西アルテパ砂漠
    [126] = require('zone/126_Qufim'),      -- クフィム島
    [127] = require('zone/127_BehemotDom'), -- ベヒーモスの縄張り
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
    [167] = require('zone/167_Bostaunieu'), -- ボストーニュ監獄
    [182] = require('zone/182_WalkEchoes'), -- ウォークオブエコーズ
    [184] = require('zone/184_LowDelkfut'), -- デルクフの塔下層
    [203] = require('zone/203_ClstFrost'),  -- 凍結の回廊
    -- 215,216,217,218 アビセア
    [230] = require('zone/230_SSandOria'),  -- 南サンドリア
    [233] = require('zone/233_ChatdOrag'),  -- ドラギーユ城
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



function isNear(pos)
    local me_pos = acpos.currentPos()
    d = acpos.distance(me_pos, pos)
    if d < 1.0 then
        return true
    end
    return false
end

function getRouteTable(zone)
    local t = aczone.zoneTable[zone]
    if t ~= nil and t.routes ~= nil then
	return t.routes
    end
    return automoveRouteTable[zone]
end
M.getRouteTable = getRouteTable

function autoMoveTo(zone_id, dest, reverse)
    local routeTable = getRouteTable(zone_id)
    if routeTable == nil then
	io_chat.print("Can't find routes at zone:"..zone_id)
	return
    end
    if dest == nil then
        if routeTable == nil then
            print("not defined zone route", zone_id)
        else
            for i, dest in pairs(routeTable) do
                io_chat.print(i)
            end
        end
    else
        route = routeTable[dest]
        if reverse == true then
            route = array_reverse(route)
        end
        moveTo(route)
    end
end
M.autoMoveTo = autoMoveTo

function M.zone_change_handler()
    coroutine.sleep(3)
    local zone = windower.ffxi.get_info().zone
    local me_pos = acpos.currentPos()
    if me_pos == nil then
        print("failed currentPos for me_pos")
        return ;
    end
    local round_x = math.round(me_pos.x, 3)
    local round_y = math.round(me_pos.y, 3)
    local round_z = math.round(me_pos.z, 3)
    print("zone:"..zone.." x="..round_x.." y="..round_y.." z="..round_z)
---    local east_adoulin_hp_pos = {-50.5, -92, 0} ここまで含める
    local east_adoulin_hp2_pos = {-51.5, -96, 0}
---local east_adoulin_hp2_pos = {-57.8, -130, 0}
    local jeuno_garden_hp_pos = {36.0, 8.8}
    if zone == 257 then
--        print("東アドゥリンなう")
        local dx = me_pos.x - east_adoulin_hp2_pos[1]
        local dy = me_pos.y - east_adoulin_hp2_pos[2]
        local dist = math.sqrt(dx*dx + dy+dy)
--        print("dist: "..dist)
        if dist < 10 then
            io_chat.print("東アドゥリン Home Point #2 (M)")
            coroutine.sleep(10)
            local me_pos2 = acpos.currentPos()
            local dx2 = me_pos.x - me_pos2.x
            local dy2 = me_pos.y - me_pos2.y
            local dist2 = math.sqrt(dx2*dx2 + dy2+dy2)
            if dist2 < 0.5 then
                acpos.turnTo({x=-58, y=-131}) --- モグハウスへ
                acpos.lookForward()
                coroutine.sleep(2)
                windower.ffxi.run(true)
            else
                print("dist >= 0.5")
            end
        end
    elseif zone == 246 then
--        io_chat.print("ジュノ庭なう")
        local dx = me_pos.x - jeuno_garden_hp_pos[1]
        local dy = me_pos.y - jeuno_garden_hp_pos[2]
        local dist = math.sqrt(dx*dx + dy+dy)
        print("dist: "..dist)
        if dist < 10 then
--            io_chat.print("ジュノ庭 Home Point #1 (E)")
            coroutine.sleep(2)
            acpos.turnTo({x=-54.5, y=0}) --- ヨアヒムとシェミの間
            acpos.lookForward()
            coroutine.sleep(3)
            windower.ffxi.run(true)
        end
    --- ソロムグ原野(120),ザルカバード(112)
    ---  ワジャーム樹林(51)、ゼオルム火山(61)、カダーバの浮沼(79)、ボスディン(111)、
    --- ヨアトル森林(124), 東アルテパ(114), 西アルテパ(125)、 バタリア(105)
    --- ビビキー湾(4)、マリミア(266)
    -- 過去ロランベリー耕地(84)
    --- ケイザック古戦場(261)、ヤッセの狩り場(260), モリマー台地(265),ヨルシア森林(263)
    --- 一旦外す。ワークスの邪魔   261, 260, 265, 263, 266
--    elseif utils.contains({120, 112, 51, 61, 79, 111, 124, 114, 125, 105, 4, 84}, zone) then
--        io_chat.print("5秒後に /mount ラプトル")
--        coroutine.sleep(5) --- 10はok
--        command.send('input /mount ラプトル; wait 1; input /follow <p1>')
    elseif zone == 70 then
        io_chat.print("チョコボサーキットなう")
        coroutine.sleep(2)
---        acpos.turnToPos(-320, -475, -335.4, -473.2)
        local tx = -335.4
---        local ty = -474.5  --- 475 > x < 473.5
        local ty = -473.5  --- 475 > x < 473.5
        acpos.turnTo({tx, ty})
        acpos.lookForward()
        coroutine.sleep(2)
        windower.ffxi.run(tx - me_pos.x, ty - me_pos.y)
        acpos.lookForward()
    elseif zone == 142 then  --- ユグホト砦洞窟内
        if isNear({x=437.2,y=68.6,z=-40}) then -- 温泉から入った所
            autoMoveTo(zone, "horl", false)
        elseif isNear({x=434,y=170,z=-40}) then -- HP#1
            windower.ffxi.run(1, 0)  -- go to right
        end
    elseif zone == 79 then  --- カダーバのうき沼、本ワープ
        windower.ffxi.run(-1, 0)  -- go to left
    elseif zone == 273 then -- うぉーの門
        print("woh gate")
        coroutine.sleep(1)
        autoMoveTo(zone, "raive", false)
    end
end

function M.warp_handler(prevZone, prevPos, zone, pos)
    if prevPos == nil or pos == nil then
        print(prevPos, pos)
        return
    end
    print("warp_handler", prevZone, prevPos.x, prevPos.y, zone, pos.x, pos.y)
    if zone == 139 then -- ホルレー
        io_chat.print("ホルレーなう")
        local bcStartPos = {x=-316.3,y=-102.57}
        local dist = acpos.distance(pos, bcStartPos)
        io_chat.print({"dist", dist})
        if dist < 10 then
            io_chat.print("AMAN トローブ開始位置")
            coroutine.sleep(2)
        end
    end
end

return M
