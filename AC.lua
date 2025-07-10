_addon.author = 'Yoya'
_addon.version = '1.1.0'
_addon.commands = {'accountcluster', 'ac'}

require('functions')
local socket = require 'socket'
local config = require 'config'
local command = require 'command'

local res = require('resources')

local defaults = {
    Period = 1.0,
---    CampRange = 15.0,
    CampRange = 18.0,
}

local settings = config.load(defaults)

local auto = false
local player_id
local start_pos = {x = -1, y = -1, z = -1}
local attack = true
local useSilt = false
local useBeads = false
local doPointCheer = false
local current_sparks = -1

local ProbRecastTime = {}

--- クリスタル
local item_data = require 'item/data'

local crystal_ids = item_data.crystal_ids -- クリスタル/塊
local seal_ids = item_data.seal_ids -- 印章
local cipher_ids = item_data.cipher_ids --  盟スクロール

local preferedEnemyList = {
    "Profane Circle", "Chaos",--- カオス戦
    "Tyny Lycopodium",  -- アンバス
    --- テスト
    "Mourioche",  -- マンドラ
--    "Apex Toad",  -- トード
    "Knotted Root", "Bedrock Crag", "Icy Palisade", -- コロナイズ
    -- 醴泉島
    "Wretched Poroggo", "Water Elemental", 
    "Indomitable Faaz", "Devouring Mosquito", -- 醴泉島
}

command.send('bind ^d ac start')
command.send('bind !d ac stop')
command.send('bind ^f ac showmob')

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

local utils = require 'utils'
local iamLeader = utils.iamLeader
local printChat = utils.printChat
local turnToPos = utils.turnToPos
local turnToTarget = utils.turnToTarget
local turnToFront = utils.turnToFront
local cureIfPartyHPisLow = utils.cureIfPartyHPisLow

local io_net = require 'io/net'

local acitem = require 'item'
local ws = require 'ws'
local aprob = require 'prob'
local sendCommandProb = aprob.sendCommandProb
local getSendCommandProbTable = aprob.getSendCommandProbTable
local acpos = require 'pos'
local autozone = require 'autozone'
local acincoming = require 'incoming'
local acmob = require 'mob'

local JunkItems = item_data.JunkItems
local _JunkItems = item_data._JunkItems

local getMobPosition = function(pos, target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
---        print("not found mob by target:" ..target)
        return false
    end
    pos.x = mob.x
    pos.y = mob.y
    pos.z = mob.z
    return true
end

local isFar = false
local fightingMobName = nil

--- リーダー待機用
local leaderFunction = function()
---    print("I am a reader")
    local me_pos = {}
    if getMobPosition(me_pos, "me") ~= true then
        print("getMobPosition failed ???")
        return
    end
--    print("mid_pos:", mid_pos.x, mid_pos.y)
    -- 優先する敵
    local mob =  acmob.getNearestFightableMob(start_pos, settings.CampRange, preferedEnemyList)
---    print("nearest prefered mob", mob)
    if mob == nil then
        --- メンバーが戦っている敵がいれば、そちら優先
--        mob = utils.PartyTargetMob()
    end
    if mob == nil then
        --- 優先度の高い敵がいない場合は、誰でも良い
        mob = acmob.getNearestFightableMob(start_pos, settings.CampRange, nil)
    end
    if mob ~= nil then
        windower.ffxi.run(false)
---        printChat(mob.name)
        io_net.targetByMobId(mob.id)
        command.send('wait 0.5; input /attack <t>')
    else 
        local dx = start_pos.x - me_pos.x
        local dy = start_pos.y - me_pos.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 4 then
            isFar = true
        end
        if isFar then
            windower.ffxi.run(dx, dy)
            if dist < 2 then
                windower.ffxi.run(false)
                isFar = false
            end
        end
        return
    end
    if attack then
        command.send('input /attack on')
        ProbRecastTime = {}
    end
end 

--- メンバー待機用
local notLeaderFunction = function()
---    print("I am not a reader")
    local player = windower.ffxi.get_player()
---    if not player or not player.target_index then
    if not player then
        return
    end
    if acitem.checkBagsFreespace() then
        for i, id in pairs(crystal_ids) do
            if acitem.inventoryHasItem(id) then
                acitem.moveToBags(id)
            end
        end
    end
    local mainJob = player.main_job
    local subJob = player.sub_job
---    local level = player.main_job_level
    local item_level = player.item_level
    if item_level < 109 then --- 潜在落とし
--        if math.random(1, 100) < 0 then
--            command.send('input /ma インビジ <me>')
--        end
        if (mainJob == "WHM" or  (mainJob == "SCH" and subJob == "WHM")) and math.random(1, 100) < 10 then
            if math.random(1, 100) < 50 then
                if math.random(1, 100) < 50 then
                    command.send('input /ma ケアル <p1>')
                else
                    command.send('input /ma ストンスキン <me>')
                end                 
            else
                if math.random(1, 100) < 50 then
                    command.send('input /ma バウォタラ <me>')
                else
                    command.send('input /ma ブリンク <me>')   
                end
            end
        end
        if mainJob == "GEO" and math.random(1, 100) <= 5 then
---            command.send('input /ma インデフューリー <me>')
           command.send('input /ma インデリフレシュ <me>')
        end
        if mainJob == "BRD" and math.random(1, 100) < 5 then
            if math.random(1, 100) <= 30 then
                command.send('input /ma 無敵の進撃マーチ <me>')
            elseif math.random(1, 100) <= 50 then
                command.send('input /ma 戦士達のピーアンIII <me>')
            else
                command.send('input /ma ブリンク <me>') 
            end
        end
        if subJob == "RDM" then
            if math.random(1, 100) <= 0 then
                command.send('input /ma リフレシュ <me>')  
            end
            if math.random(1, 100) <= 1 then
                command.send('input /ja コンバート <me>') 

            end
        end
--      return
    end
    local me_pos = {}
    local leader_pos = {}
    getMobPosition(me_pos, "me")
    --- p1 がリーダーだと仮定。
    local target_leader = "p1"
    getMobPosition(leader_pos, target_leader)
    if leader_pos.x == nil then
        return 
    end
    local dx = leader_pos.x - me_pos.x
    local dy = leader_pos.y - me_pos.y
    local dist =  math.sqrt(dx*dx + dy*dy)
    --- リーダーと離れたのを確率的に気づくように
    if math.random(1, 2) <= 1 and dist > math.random(3,5) then
        isFar = true
        turnToTarget(target_leader)
        turnToFront()
        windower.ffxi.run(dx, dy)
    end
    if isFar then
        if dist > math.random(2, 4) then
            return
        end
    end
    isFar = false
    windower.ffxi.run(false)
    -- 119未満は無理しない, 109 は頑張る。潜在外し
    if item_level < 109 then
        local mob = windower.ffxi.get_mob_by_target("bt")
        if mob == nil or mob.hpp > 90 then
            -- 戦闘直後は危ないので、戦いに参加しない
            return
        end
    end
    if attack then
        windower.ffxi.run(false)
        --- p1 がターゲットしてる敵に合わせる
        local p1 = windower.ffxi.get_mob_by_target("p1")
        if p1 == nil or p1.status ~= 1 or p1.target_index == 0 then
            return
        end
        io_net.targetByMobIndex(p1.target_index)
---        command.send('input /target <bt>')
        local mob = windower.ffxi.get_mob_by_target("t")
        if mob ~= nil and mob.hpp < 100 then
            coroutine.sleep(math.random(0,2)/4)
            command.send('input /attack <t>')
        end
        ProbRecastTime = {}
    end
end

--- 戦闘中。リーダー、メンバー共通。
local figtingFunction = function()
---    print("figtingFunction")
--- printChat("figtingFunction")
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
--        print("figtingFunction mob is nil")
        -- 多分、戦闘モードなのにターゲットがいない。
        command.send('input /attack off')
        return
    end
    local player = windower.ffxi.get_player()
    local mainJob = player.main_job
    local subJob = player.sub_job
---    print("XXX", preferedEnemyList)
    -- 優先する敵は、索敵範囲を半分に。
    local preferMob =  acmob.getNearestFightableMob(start_pos, settings.CampRange/2, preferedEnemyList)
---    print("prefereMob", preferMob)
    if preferMob ~= nil and mob.name ~= preferMob.name then
--        print("preferMob:", mob.name)
        if iamLeader() then
            io_net.targetByMobId(preferMob.id)
            coroutine.sleep(1)
            command.send('input /attack <t>')
        else
            --- リーダー(p1)が戦闘している敵に切り替える
            command.send('input /assist <p1>')
        end
    end
 ---   if not player or not player.target_index then
 ---       return
 ---   end
    --- サポ白はPLなので、ずっとインビジ
    local subJob = player.sub_job
    if false and subJob == "WHM" then
        if math.random(1, 100) <= 1 then
---            command.send('input /ma インビジ <me>')
---            coroutine.sleep(2)
        end
        return 
    end
    local enemy_pos = {}
    local me_pos = {}
    getMobPosition(enemy_pos, "t")
    getMobPosition(me_pos, "me")
    --- 戦闘してない？
    if enemy_pos.x == nil then
        print("if enemy_pos.x == nil")
        return
    end
--    cureIfPartyHPisLow()

    local dx = enemy_pos.x - me_pos.x
    local dy = enemy_pos.y - me_pos.y
    local dist =  math.sqrt(dx*dx + dy*dy)

    --- リーダー以外は離れてると気付くのを遅らせる
    if iamLeader() or math.random(1, 2*settings.Period) <= 1 then
        if dist > math.random(2, 5) then
            isFar = true
        end
    end
    if isFar then
        --　戦闘中でないときは、WSやMAを自粛。フェイスが動かないので。
        if dist / mob.model_size > math.random(4,7)/2 or player.status == 0 then
            windower.ffxi.run(dx, dy)
            -- 向きが悪くて戦闘が開始しない問題への対策
            command.send('setkey numpad5 down; wait 0.05; setkey numpad5 up')
            return
        else
            windower.ffxi.run(false)
            sendCommandProb({
                { 150, 0, 'setkey a down; wait 0.05; setkey a up', 0 }, -- 左
                { 150, 0, 'setkey d down; wait 0.05; setkey d up', 0 }, -- 右
                { 150, 0, 'setkey a down; wait 0.1; setkey a up', 0 }, 
                { 150, 0, 'setkey d down; wait 0.1; setkey d up', 0 },
                { 200, 0, 'setkey a down; wait 0.15; setkey a up', 0 },
                { 200, 0, 'setkey d down; wait 0.15; setkey d up', 0 },
                { 200, 0, 'setkey a down; wait 0.2; setkey a up', 0 },
                { 200, 0, 'setkey d down; wait 0.2; setkey d up', 0 },
                { 300, 0, 'setkey a down; wait 0.25; setkey a up', 0 },
                { 300, 0, 'setkey d down; wait 0.25; setkey d up', 0 },
                { 500, 0, 'setkey s down; wait 0.01; setkey s up', 0 }, -- 後ろ
         }, 1.0, ProbRecastTime)
         --- 一回だけなので 1 を入れる。
        end
    end
    -- 羅盤が戦闘場所から離れてたら消す
    if mainJob == "GEO" and math.random(1, 100) <= 30 then
        local petdist = acpos.targetDistance("pet")
        if petdist ~= nil and petdist > math.random(25, 40) then
            printChat("petdist:"..petdist)
            command.send('input /ja フルサークル <me>; wait 2; input /ja グローリーブレイズ <me>; wait 2; input /ma ジオフレイル <bt>')
        end 
    end
    --- 止まって戦闘開始
    isFar = false
    windower.ffxi.run(false)
    --- atan2 のままだと右を向くので、90度の補正
--    local dir = math.atan2(dx, dy) - 3.14/2
--    windower.ffxi.turn(dir)
    turnToTarget("t")
---    if player.vitals.tp >= math.random(1100, 1200) then
    --- PLD はタゲ取り.RNG はエヴィ用。"BLM", "SMN", "SCH"はミルキル
    local tp100Jobs = {-"RNG", "BLM", "SMN", "SCH"}
    --- WAR はスチサイ用。DNC はダンス用？
    local tpJobs = {"DNC"}
    local tpMin = 1200
    local tpMax = 1500
    if utils.contains(tp100Jobs, player.main_job) then
        tpMin = 1050
        tpMax = 1150
    elseif utils.contains(tpJobs, player.main_job) then
        tpMin = 2000
        tpMax = 2500
    end
    if player.vitals.tp >= math.random(tpMin,tpMax) then
        ws.exec()
        return
    else
        if player.item_level > 99 then
            local commprob = getSendCommandProbTable(mainJob, subJob, 1)
--            printChat(commprob)
            sendCommandProb(commprob, settings.Period, ProbRecastTime)
        end
    end
---    if math.random(1, 100) <= 1 then
    --- 戦闘ターゲットがたまに外れる対策。とりあえずの方法。
    if iamLeader() or puller then
        if math.random(1, 10) <= 1 then
            command.send('input /attack <t>')
        end
    end
    --- たまに左や右にずれる。前や後にも。
    sendCommandProb({
        { 10, 10, 'setkey a down; wait 0.1; setkey a up', 0 },
        { 10, 10, 'setkey d down; wait 0.1; setkey d up', 0 },
        { 10, 10, 'setkey w down; wait 0.1; setkey w up', 0 },
        { 10, 10, 'setkey s down; wait 0.1; setkey s up', 0 },
    }, settings.Period, ProbRecastTime)
    if acitem.checkBagsFreespace() then
        for i, id in pairs(crystal_ids) do
            if acitem.inventoryHasItem(id) then
                acitem.moveToBags(id)
            end
        end
    end
    if doPointCheer then  --- アンバス：マンドラ
        sendCommandProb({
            { 200, 1, 'input /point <t>', 1 },
            { 100, 1, 'input /cheer <p1>', 1 },
            { 100, 1, 'input /cheer <p2>', 1 },
            { 100, 1, 'input /clap <p1>', 1 },
            { 100, 1, 'input /clap <p2>', 1 },
        }, settings.Period, ProbRecastTime)     
    end  
end

local idleFunctionTradeItems = function(tname, items, wait, enterWaits)
---    command.send('input /targetnpc')
    local mob = windower.ffxi.get_mob_by_name(tname)
    if mob == nil then
        print("idleFunctionTradeItems: mob not found")
        return 
    end
    if mob.name == tname then
        for i, id in pairs(items) do
            if acitem.checkInventoryFreespace() == false then
                break
            end
            if acitem.bagsHasItem(id) then
                acitem.bagsToInventory(id)
                coroutine.sleep(1)
            end
        end
        for i, id in pairs(items) do
            if acitem.inventoryHasItem(id) then
                acitem.tradeByItemId(mob, id)
                coroutine.sleep(1)
                io_net.targetByMobId(mob.id)
                coroutine.sleep(wait-1)
                for w in pairs(enterWaits) do
                    pushKeys({"enter"})
                    coroutine.sleep(1)
                    io_net.targetByMobId(mob.id)
                    coroutine.sleep(w-1)
                end
            end
        end
    end
    coroutine.sleep(1)
end


-- ジャンクアイテムをかばんに集める
local aggregateJunkItemsToInventory = function()
    local count = 0
    for id in pairs(JunkItems) do
        if acitem.checkInventoryFreespace() == false then
            break
        end
        if acitem.safesHasItem(id) then
            print("safes "..id.."to Inventory")
            acitem.safesToInventory(id)
            count = count + 1
            coroutine.sleep(0.5)
        end
        if acitem.bagsHasItem(id) then
            print("bags id:"..id.." to Inventory")
            acitem.bagsToInventory(id)
            count = count + 1
            coroutine.sleep(0.5)
        end
    end
    print("aggregateJunkItemsToInventory: "..count)
    return count
end

-- かばん内のジャンクアイテムを数える
local countJunkItemsInInventory = function ()
    local count = 0
        for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
--        printChat({"item:", windower.to_shift_jis(res.items[item.id].ja), item.id, item.status})
        if item and utils.contains(JunkItems, item.id) then
            count = count + 1
        end
    end
    return count
end

local sellJunkItemsInInventory = function()
    local total_count = countJunkItemsInInventory()
    printChat(total_count.."回売却 start")
    local remain_count = total_count
    for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
--        printChat({"item:", windower.to_shift_jis(res.items[item.id].ja), item.id, item.status})
        if item and utils.contains(JunkItems, item.id) then
            windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,item.count,0,0,0,
                                        item.id%256,math.floor(item.id/256)%256,index,0))
            windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
--          printChat({"item:", windower.to_shift_jis(res.items[item.id].ja), item.id, item.status})
            remain_count = remain_count - 1
            if remain_count <= 0 then
                break
            end
            if remain_count % 5 == 0 then
                printChat("# "..remain_count.."/"..total_count)
            end
            coroutine.sleep(math.random(6,8)/4)
        end
    end
    print("junk sold out", total_count)
    printChat(total_count.."回売却 end")
---  stop() ---何故か動かない
    auto = false
end

local idleFunctionSellJunkItems = function()
    -- 可搬ストレージのジャンクアイテムをかばんに集める
    print("Aggregate Bag Junk Items to Inventory")
    aggregateJunkItemsToInventory()
    local done = false
    while done == false and auto do
        -- 売却処理
        sellJunkItemsInInventory()
        local move_count = aggregateJunkItemsToInventory()
        if move_count == 0 then
            -- 移動するアイテムがなければ終了
            done = true
        end
    end
end

local dropJunkItemsInInventory = function()
    local remain_count = total_count
    for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
--        printChat({"item:", windower.to_shift_jis(res.items[item.id].ja), item.id, item.status})
        if item and utils.contains(JunkItems, -item.id) then
            local item_id = -item.id
            print("drop???:"..item_id.." x "..item.count)
            -- windower.ffxi.drop_item(item.index, item.count)
            coroutine.sleep(math.random(6,8)/5)
        end
    end
end

--- モグガーデン(280)のみ動作する
local idleFunctionMobGarden = function()
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
---        print("no target")
        return
    end
    if mob.name == "Ephemeral Moogle" then
        if acitem.checkInventoryFreespace() then
            for i, id in pairs(crystal_ids) do
                if acitem.bagsHasItem(id) then
                    acitem.bagsToInventory(id)
                    coroutine.sleep(1)
                end
            end
        end
        for i, id in pairs(crystal_ids) do
            if acitem.inventoryHasItem(id) then
                acitem.tradeByItemId(mob, id)
                coroutine.sleep(3)
                io_net.targetByMobId(mob.id)
            end
        end
        coroutine.sleep(7)
        io_net.targetByMobId(mob.id)
    elseif mob.name == "Garden Furrow" or mob.name == "Garden Furrow #2"
           or mob.name == "Garden Furrow #3" then
        local id = 940 -- 反魂樹の根
        acitem.tradeByItemId(mob, id)
        auto = false
    elseif mob.name == "Mineral Vein" or mob.name == "Mineral Vein #2"
            or mob.name == "Mineral Vein #3"
            or mob.name == "Arboreal Grove" or mob.name == "Arboreal Grove #2"
            or mob.name == "Arboreal Grove #3" then
        while auto do
            pushKeys({"escape", "f8", "enter"})
            coroutine.sleep(2)
            pushKeys({"enter"})
            coroutine.sleep(3)
            if acitem.diffInventoryTotalNum() == 0 or
                acitem.checkInventoryFreespace() == false then
                auto = false
            end
        end
    elseif mob.name == "Pond Dredger" then
        auto = false
        coroutine.sleep(2)
        pushKeys({"escape", "f8", "enter"})
        coroutine.sleep(3)
        pushKeys({"enter"})
    end
end

local idleFunctionJeunoPort = function()
    idleFunctionTradeItems("Shemo", seal_ids, 3, {2,4})  --- or Shami
end

local idleFunctionSouthSand = function()
    idleFunctionTradeItems("Gondebaud", cipher_ids, 5, {10,10})
end

local idleFunctionSandPort = function()
    idleFunctionTradeItems("Joulet", {4401,5789}, 5, {}) -- 堀ブナ
end

local idleFunctionWestAdoulin = function()
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
        return
    end
    if mob.name == "Defliaa" then
        idleFunctionSellJunkItems()
    elseif mob.name == "Eternal Flame" then
        if acitem.inventoryFreespaceNum() > 0 then
            command.send('sparks buyall Acheron Shield')
            auto = false
        end
        auto = false
    elseif mob.name == "Nunaarl Bthtrogg" then
        n = acitem.inventoryFreespaceNum()
        printChat("かばんの空きは"..n.."*99 = "..(n*99))
        auto = false
    end
end

local left_move = function(t)
    command.send('setkey a down')
    coroutine.sleep(t)
    command.send('setkey a up')
end
local right_move = function(t)
    command.send('setkey d down')
    coroutine.sleep(t)
    command.send('setkey d up')
end

local target_lockon = function(b)
    local player = windower.ffxi.get_player()
    local locked = player.target_locked
    if b ~= locked then
        command.send('input /lockon')
    end
end

local N  = 0
local NE = math.pi * (1/4)
local E  = math.pi * (2/4)
local SE = math.pi * (3/4)
local S  = math.pi
local SW = math.pi * (5/4)
local W  = math.pi * (6/4)
local NW = math.pi * (7/4)

-- 0:喜ぶ 1:泣く 2:驚く 3:悔しむ
-- 4:励ます 5:慌てる 6:照れる 7:気合

local stationWorkerBoostTable = {
    [265] = { -- モリマー台地
        [0]  = {SE,S, 4}, [3]  = {S,SW, 5},
        [6]  = {SW,W, 6}, [9]  = {W,NW, 7},
        [12] = {NW,N, 0}, [15] = {N,NE, 1},
        [18] = {NE,E, 2}, [21] = {E,SE, 3},
    },
}

local getStationWorkerBoostInfo = function(zone)
    local timeTable = stationWorkerBoostTable[zone]
    local time = windower.ffxi.get_info().time
    for t, i in pairs(timeTable) do
        if t*60 <= time and time < (t+3)*60 then
            return i
        end
    end
    return nil
end 

-- 範囲は -math.pi < theta < math.pi
local normalangle = function(a)
    if a <= math.pi or math.pi <= a then
        a = a % (2*math.pi)
    end
    if a < math.pi then
        return a
    end
    return a - (2*math.pi)
end

-- 中間の角度
local midangle = function(a, b)
    a = normalangle(a)
    b = normalangle(b)
    if math.abs(a-b) < math.pi then
        return normalangle((a + b) / 2)
    end
    a = a % (2*math.pi)
    b = b % (2*math.pi)
    return normalangle(a - b)
end

local stationWorkerFunction = function(zone, mob)
    target_lockon(true)
    local info = getStationWorkerBoostInfo(zone)
    -- N = 0, E = 3.14*0.5, S = 3.14, W = 3.14*1.5 
    local theta = midangle(info[1], info[2])
    printChat("theta: "..theta.." select:"..info[3])
    local done = false
    -- 向きをあわせる
    while done == false and auto do
        local me_pos = {}
        getMobPosition(me_pos, "me")
        local dx = me_pos.x - mob.x
        local dy = me_pos.y - mob.y
        local t = math.atan2(dx, dy)
        local dt = (theta % (2*math.pi)) - (t % (2*math.pi))
        left_move(0.025)
--        printChat("theta:"..theta.." t:"..t.." dt:"..dt)
        if math.abs(dt) < 2*math.pi/32 then
            done = true
        end
    end
    -- 応援方法を選択する
    keyboard.pushKeys({"enter"})
    coroutine.sleep(2.5)
    if info[2] > 0 then
        for i = 1, info[2] do
            pushKeys({"down"})
            coroutine.sleep(1)
        end
    end
    keyboard.pushKeys({"enter"})
    auto = false
end

local idleFunction = function()
--  87print("idleFunction")
    local ret
    if  useSilt then
        windower.ffxi.run(false)
        useSilt = acitem.useItemIncludeBags(6391)
        return
    end
    if  useBeads then
        windower.ffxi.run(false)
        useBeads = acitem.useItemIncludeBags(6392)
        return 
    end
    if useSilt or useBeads then
        return
    end
    local zone = windower.ffxi.get_info().zone
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
        return
    end
    if zone == 280 then
        --- 以下はモグガーデンのみ処理
        idleFunctionMobGarden()
        if mob and mob.name == "Green Thumb Moogle" then
            idleFunctionSellJunkItems()
        end
    elseif zone == 246 then --- ジュノ港
        idleFunctionJeunoPort()
    elseif zone == 230 then -- 南サンドリア
        idleFunctionSouthSand()
    elseif zone == 232 then -- サンドリア港
        idleFunctionSandPort()
    elseif zone == 256 then -- 西アドゥリン
        idleFunctionWestAdoulin()
    elseif zone == 257 then -- 東アドゥリン
        if mob and mob.name == "Malgrom" then
            idleFunctionSellJunkItems()
        end
    end
    -- ワークス応援
    if mob.name == "Station Worker" then
        stationWorkerFunction(zone, mob)
    end
    if mob.name == "Ergon Locus" then
        pushKeys({"numpad5"})
        while(auto)
        do
            pushKeys({"f8", "numpad*", "numpad2", "enter"})
            coroutine.sleep(3)
            pushKeys({"up", "enter"})
            coroutine.sleep(3)
        end
    end
end

local tickRunning = false


--- 途中での return 抜け禁止。最後でフラグ落とすので。
local tick = function()
---    print("tick")
local prevPos = nil
    if not auto then
        return
    end
    if tickRunning then
        return 
    end
    tickRunning = true
    local player = windower.ffxi.get_player()
    if player ~= nil then   --- ログインし直す時に
        cureIfPartyHPisLow()
       if player.status == 0 then
            --- 待機中
          idleFunction()
          if iamLeader() or puller then
              leaderFunction()
          else
                notLeaderFunction()
            end
        elseif player.status == 1 then
            --- 戦闘中
            figtingFunction()
        end
    end
    tickRunning = false
end


--- ループの終了条件
local loopCnd = function()
    return auto
end

local start2 = function()
    printChat('### AutoA  START')
    printChat({"CampRange: " .. settings.CampRange})
    getMobPosition(start_pos, "me")
    printChat("save start_pos: {x:" .. math.round(start_pos.x,2) .. " y:"..math.round(start_pos.y,2)  .. " z:"..math.round(start_pos.z,2).."}")
    -- true の時は既に動いてる loop を終了させる
    if auto == true then
        auto = false
        socket.sleep(settings.Period * 2)
    end
    settings = config.load(defaults)
    auto = true
    tick:loop(settings.Period, loopCnd)
end

local stop2 = function()
    printChat('### AutoA  STOP')
    auto = false
    acpos.stop()
    windower.add_to_chat(17, '### AutoA  STOP')
end

local start = function()
    if iamLeader() then
        windower.send_ipc_message('AutoA:start')
    end
    start2()
end

local stop = function()
    if iamLeader() then
        windower.send_ipc_message('AutoA:stop')
    end
    stop2()
end

windower.register_event('ipc message', function(message)
--    print("IPC:"..message)
    if message:sub(1, 5) == '__AutoA:' then
        command =  message:sub(6)
        printChat("command:"..command)
        if command == 'start' then
            if iamLeader() == false then
                print("before start2")
                start2()
                print("after start2")
            end
        elseif command == 'stop' then
            if iamLeader() == false then
                stop2()
            end
        end
    end
end)


local changeWS = function(wskey)
    if wskey == nil then
        windower.add_to_chat(17, '' .. ws.getWeaponSkillUsage())
        return
    end
    if wskey == 'any' then
        wskey = ws.getAnyWeaponSkill()
    elseif wskey == 'stop' then
        ws.weaponskill = nil
        printChat("ws stop")
        return
     end
    print('wskey', wskey)
    if ws.weaponskillTable[wskey] == nil then
        print("unknown ws", wskey)
        return
    end
    ws.weaponskill = wskey
    wsName = ws.weaponskillTable[ws.weaponskill]
    windower.add_to_chat(17, 'set any ' .. wskey .. ' => ' .. wsName)
end

local showMob = function()
    print("showMob")
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
---        print("not found mob by target:" ..target)
    else
        printChat(mob)
    end
end

windower.register_event('addon command', function(command, command2)
    command = command and command:lower() or 'help'
    if command == 'start' then
        start()
    elseif command == 'stop' then
        stop()
    elseif command == 'attack' then
        attack = not attack
        printChat({"attack mode", attack})
    elseif command == 'camprange' then
        settings.CampRange = tonumber(command2, 10)
        printChat({"CampRange:", command2})
    elseif command == 'showmob' then
        showMob()
    elseif command == 'silt' then
        useSilt = not useSilt
        printChat({"item silt using start", useSilt})
    elseif command == 'beads' then
        useBeads = not useBeads
        printChat({"item beads using start", useBeads})
    elseif command == 'point' then      
        doPointCheer = not doPointCheer
        printChat({"do point&cheer for ambus", doPointCheer})
    elseif command == 'checkbags' then
        printChat(acitem.checkInventoryFreespace())
        printChat(acitem.checkBagsFreespace())
    elseif command == 'showinventory' then
        acitem.showInventory()
    elseif command == 'ws' then
        changeWS(command2)
    elseif command == 'puller' then
        if command2 == 'on' then
            puller = true
            printChat("puller on")
        elseif command2 == 'off' then
            puller = false
            printChat("puller off")
        else 
            printChat("Usage: aa puller {on|off}")
        end
    elseif command == 'pos' then
        local zone = windower.ffxi.get_info().zone
        printChat("zone id:"..zone)
        local me_pos = {}
        getMobPosition(me_pos, "me")
        local x = math.round(me_pos.x, 1)
        local y = math.round(me_pos.y, 1)
        local z = math.round(me_pos.z, 1)
---    print は - 記号を誤認しやすいので、表示しない
---        print("me potision", " x="..x, "  y="..y, "  z="..z)
        printChat("me potision  x="..x.."  y="..y.."  z="..z)
    elseif command == 'move' then
        local zone = windower.ffxi.get_info().zone
        acpos.autoMoveTo(zone, command2, false)
    elseif command == 'moverev' then
        local zone = windower.ffxi.get_info().zone
        acpos.autoMoveTo(zone, command2, true)
    elseif command == 'info' then
        local zone = windower.ffxi.get_info().zone
        printChat("zone id:"..zone)
        local me_pos = {}
        getMobPosition(me_pos, "me")
        printChat({"me potision", me_pos})
        local dist = utils.distance("t")
        dist = dist or "(nil)"
        printChat("distance to <t>:"..dist)
        printChat("current_sparks:"..current_sparks)
    elseif command == 'test' then
        print("test command")
        utils.PartyTargetMob()
    elseif command == 'enterloop' then
        auto = true
        local i = 0
        while auto do
            print("enter #"..i)
            i = i + 1
            pushKeys({"enter"})
            coroutine.sleep(3)
        end
    elseif command == 'enterloop2' then
        auto = true
        while auto do
            print("down & enter")
            pushKeys({"down", "enter"})
            coroutine.sleep(3)
        end
    elseif command == 'nearest' then
        local preferMob =  acmob.getNearestFightableMob(start_pos, settings.CampRange, preferedEnemyList)
        local mob =  acmob.getNearestFightableMob(start_pos, settings.CampRange, nil)
        printChat("nearest preferMob=====================")
        printChat(preferMob)
        printChat("nearest mob =====================")
        if preferMob == nil or preferMob.name ~= mob.name then
            printChat(mob)
        else
            printChat("same name monster")
        end
    elseif command == 'help' then
        windower.add_to_chat(17, 'AC (AccountCluster)  v' .. _addon.version .. 'commands:')
        windower.add_to_chat(17, '//ac [options]')
        windower.add_to_chat(17, '    start           - Starts auto attack with ranged weapon')
        windower.add_to_chat(17, '    stop            - Stops auto attack with ranged weapon')
        windower.add_to_chat(17, '    ws              - Change weapon skill')
        windower.add_to_chat(17, '    attack          - Change attack mode')
        windower.add_to_chat(17, '    puller {on|off} - Change puller mode')
        windower.add_to_chat(17, '    silt|beads      - Use silt or beads')
        windower.add_to_chat(17, '    showmob         - Show mob info')
        windower.add_to_chat(17, '    pos|info|nearest - Debug command')
        windower.add_to_chat(17, '    help            - Displays this help text')
        windower.add_to_chat(17, ' ')
        windower.add_to_chat(17, 'AC will automate account cluster something.')
        windower.add_to_chat(17, 'To start AC without commands use the key:  Ctrl+D')
        windower.add_to_chat(17, 'To stop AC attacks in the same manner:  Atl+D')
    else
        printChat("See ac help!!!")
    end
end)

windower.register_event('load', 'login', 'logout', function()
    local player = windower.ffxi.get_player()
    player_id = player and player.id
--    wskey = ws.getAnyWeaponSkill()
    ws.init()
end)

windower.register_event('job change', function()
--    wskey = ws.getAnyWeaponSkill()
    ws.init()
end)


--- ゾーンが変わったら停止する
windower.register_event('zone change', function()
    auto = false
    useSilt = false
    useBeads = false
    doPointCheer = false
--    wskey = ws.getAnyWeaponSkill()
    autozone.zone_change_handler()
 end)


 windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    acincoming.incoming_handler()
    local player = windower.ffxi.get_player()
    if id == 0x2D then
--        local packet = packets.parse('incoming', original)
--          printChat("============== packet(0x2D)")
--        if packet["Player Index"] == player.index then  
--            printChat(packet)
--        end
    end
    if id == 0x110 then -- Update Current Sparks via 110
        local data = original
		local header, value1, value2, Unity1, Unity2, Unknown = data:unpack('II')
		current_sparks = value1
--        printChat({"current_sparks", current_sparks})
	end
 end)

local loopConf = function()
    return auto
end

--windower.register_event('load', function()
---    local c = check:loop(1)
--end)

--Copyright ? 2013, Banggugyangu
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
