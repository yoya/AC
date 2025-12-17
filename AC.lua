_addon.author = 'Yoya'
_addon.version = '1.3.0'
_addon.commands = {'accountcluster', 'ac'}

local M = {}

require('functions')
local res = require 'resources'
local socket = require 'socket'
local config = require 'config'
local control = require 'control'
local packets = require 'packets'
local command = require 'command'
local task = require 'task'
local works = require 'works'
local contents = require 'contents'
local pull = require 'pull'
local puller = false
local defaults = {
    Period = 1.0,
---    CampRange = 15.0,
    CampRange = 18.0,
    PullMethod = pull.MELEE,
    Attack = true,
    Calm = true,
}

local settings = config.load(defaults)

-- local player_id
local start_pos = {x = -1, y = -1, z = -1}
local useSilt = false
local useBeads = false
local doPointCheer = false

local ProbRecastTime = {}

local item_data = require 'item/data'

local crystal_ids = item_data.crystal_ids -- クリスタル/塊
local seal_ids = item_data.seal_ids -- 印章
local cipher_ids = item_data.cipher_ids --  盟スクロール

-- 他との戦闘を中断してでも先に倒すべき敵
local moreAttractiveEnemyList = {
    -- カオス戦
    "Profane Circle",
    -- アンバス
    "Tyny Lycopodium",
    "Skullcap", "Bozzetto Elemental",
    -- 醴泉島
    "Wretched Poroggo", "Water Elemental",
    -- Void Watch
    "Gloam Servitor", -- ルフェーゼ
    "Bloodswiller Fly", -- "Tsui-Goab", -- ミザレオ
    "Little Wingman", -- ウルガラン
    "Bloody Skull", -- アットワ
    "Primordial Pugil", -- ビビキー
    -- プロマシア
    "Gargoyle",
    -- アルタナM
    "Atomos", "Aquila", "Haudrale",
}

-- 優先して釣る敵
local preferedEnemyList = {
    -- カオス戦
    "Chaos",
    -- コロナイズ
    "Knotted Root", "Bedrock Crag", "Icy Palisade",
    -- 醴泉島
    "Wretched Poroggo", "Water Elemental",
    "Indomitable Faaz", "Devouring Mosquito",
    -- ドメインベーション
    "Azi Dahaka's Dragon", "Azi Dahaka",
    "Naga Raja's Lamia", "Naga Raja",
    "Quetzalcoatl's Sibilus", "Quetzalcoatl",
    "Mireu",
    -- 実験
    "Apex Toad",  -- ウォーの門、トード。
    "Mourioche",  -- マンドラ
    -- アルタナM
    "Cait Sith Ceithir",
}

command.send('bind ^d ac start')
command.send('bind !d ac stop')
command.send('bind ^f ac show mob')

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

local utils = require 'utils'
local ac_pos = require 'ac/pos'
local ac_move = require 'ac/move'
local ac_record = require 'ac/record'
local ac_char = require 'ac/char'

local turnToPos = ac_move.turnToPos
local turnToTarget = ac_move.turnToTarget
local turnToFront = ac_move.turnToFront

local ac_party = require 'ac/party'
local iamLeader = ac_party.iamLeader

local io_net = require 'io/net'
local io_chat = require 'io/chat'

local io_ipc = require 'io/ipc'
io_ipc.AC = M  -- for calback

local ac_stat = require 'ac/stat'
local acinspect = require 'inspect'

local acitem = require 'item'
local ws = require 'ws'
local aprob = require 'prob'
local sendCommandProb = aprob.sendCommandProb
local getSendCommandProbTable = aprob.getSendCommandProbTable
local aczone = require 'zone'
local zone_change = require 'zone/change'
local outgoing_chunk = require 'outgoing/chunk'
local incoming_chunk = require 'incoming/chunk'
local incoming_text = require 'incoming/text'

local acmob = require 'mob'
local getMobPosition = acmob.getMobPosition

local acjob = require 'job'
local role_Sorcerer = require('role/Sorcerer')
local ac_defeated = require 'ac/defeated'
local ac_equip = require 'ac/equip'

local JunkItems = item_data.JunkItems
local JunkItemsT = item_data.JunkItemsT

local isFar = false
local fightingMobName = nil

--- リーダー待機用
local leaderFunction = function()
---    print("I am a reader")
    local me_pos = {}
    if getMobPosition(me_pos, "me") ~= true then
	-- zone チェンジでよくある
        -- print("getMobPosition failed ???")
        return
    end
    -- リンクしてる敵
    local condition = {
	range = settings.CampRange,
	linkedOnly = true,
	-- nameMatch = control.enemy_filter,
    }
    local mob = acmob.searchNearestMob(me_pos, condition)
    -- 優先する敵
    if mob == nil then
	local condition = {
	    range = settings.CampRange,
	    preferMobs = utils.table.merge_lists(moreAttractiveEnemyList, preferedEnemyList),
	    nameMatch = control.enemy_filter,
	}
	local mob = acmob.searchNearestMob(start_pos, condition)
	-- local mob = acmob.getNearestFightableMob(start_pos, settings.CampRange, )
	---    print("nearest prefered mob", mob)
    end
    if mob == nil then
        --- メンバーが戦っている敵がいれば、そちら優先
        -- mob = ac_mob.PartyTargetMob()
    end
    if mob == nil then
        --- 優先度の高い敵がいない場合は、誰でも良い
	local condition = {
	    range = settings.CampRange,
	    nameMatch = control.enemy_filter,
	}
	mob = acmob.searchNearestMob(start_pos, condition)
        -- mob = acmob.getNearestFightableMob(start_pos, settings.CampRange, nil)
    end
    if mob ~= nil and settings.Attack then
        windower.ffxi.run(false)
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
    if settings.Attack then
        command.send('input /attack on')
	aprob.clearProbRecastTime(ProbRecastTime)
	task.resetByFight()
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
    local me_pos = {}
    local leader_pos = {}
    getMobPosition(me_pos, "me")
    --- p1 がリーダーだと仮定。(リーダーというよりフォローする対象が p1)
    local target_leader = "p1"
    local p1 = windower.ffxi.get_mob_by_target("p1")
    if p1 == nil then
	return  -- リーダーがいない
    end
    -- リーダーがマウントしてたら、自分もマウント
    if p1.status == 85 and player.status ~= 85 then
	command.send('input /mount ラプトル')
    end
    if p1.status ~= 85 and player.status == 85 then
	command.send('input /dismount')
    end
    getMobPosition(leader_pos, target_leader)
    if leader_pos.x == nil then
        return 
    end
    local dx = leader_pos.x - me_pos.x
    local dy = leader_pos.y - me_pos.y
    local dist =  math.sqrt(dx*dx + dy*dy)
    -- リーダーと離れたのを確率的に気づくように
    -- あと離れすぎたり、エリアが違う時や、やめる。
    if p1.hpp > 0 then
	if math.random(1, 3) <= 1 and dist > math.random(3, 5) and
	    dist < 24 then
	    isFar = true
	elseif dist > math.random(6, 7) then -- 離れすぎたらすぐ気付く
	    isFar = true
	end
    end
    if isFar == true then
        turnToTarget(target_leader)
        turnToFront()
        windower.ffxi.run(dx, dy)
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
    -- ワープギミックは target まで追随する。
    local p1 = windower.ffxi.get_mob_by_target("p1")
    if p1 ~= nil and p1.target_index ~= 0 then
	local target = windower.ffxi.get_mob_by_index(p1.target_index)
	if target ~= nil then
	    local target_name = target.name
	    -- print("p1 target_name", target_name)
	    if string.find(target_name, "Home Point") or
		string.find(target_name, "Survival Guide") or
		string.find(target_name, "Waypoint") or
		string.find(target_name, "Undulating Confluence") or
		string.find(target_name, "Ethereal") or
		string.find(target_name, "Affi") or
		string.find(target_name, "Dremi") or
		string.find(target_name, "Shiftrix") then
		-- print("p1 target Found", p1.target_index, target.index)
		io_net.targetByMobIndex(p1.target_index)
		-- io_net.targetByMobId(target.id)
		windower.ffxi.run(true)
	    end
	end
    end
    if settings.Attack then
        windower.ffxi.run(false)
	local condition = {
	    range = settings.CampRange,
	    linkedOnly = true,
	    -- nameMatch = control.enemy_filter,
	}
	local mob = acmob.searchNearestMob(me_pos, condition)
	if mob ~= nil then
	    io_net.targetByMobIndex(mob.index)
	else
	    --- p1 がターゲットしてる敵に合わせる
	    if p1 == nil or p1.status ~= 1 or p1.target_index == 0 then
		return
	    end
	    local target = windower.ffxi.get_mob_by_index(p1.target_index)
	    if target == nil or target.status ~= 1 then
		-- 敵と戦闘開始してなければ様子見
		return
	    end
	    -- p1 が戦闘している敵にターゲット
	    io_net.targetByMobIndex(p1.target_index)
	    mob = windower.ffxi.get_mob_by_target("t")
	end
	---        command.send('input /target <bt>')
	--if mob ~= nil and mob.hpp < 100 then
	if mob ~= nil then
	    if item_level >= 119 or mob.hpp < 100 then
		coroutine.sleep(math.random(0,2)/4)
		command.send('input /attack <t>')
		task.resetByFight()
	    end
        end
        ProbRecastTime = {}
    end
end

--- 戦闘中。リーダー、メンバー共通。
local fightingFunction = function()
---    print("fightingFunction")
--- io_chat.print("fightingFunction")
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
--        print("fightingFunction mob is nil")
        -- 多分、戦闘モードなのにターゲットがいない。
        command.send('input /attack off')
        return
    end
    local player = windower.ffxi.get_player()
    local mainJob = player.main_job
    local subJob = player.sub_job
---    print("XXX", preferedEnemyList)
    -- 中断してでも優先する敵
    local condition = {
	range = settings.CampRange,
	preferMobs = moreAttractiveEnemyList,
	nameMatch = control.enemy_filter,
    }
    local preferMob = acmob.searchNearestMob(start_pos, condition)
    -- local  preferMob =  acmob.getNearestFightableMob(start_pos, preferedEnemyList)
    ---    print("prefereMob", preferMob)
    if not utils.table.contains(moreAttractiveEnemyList, mob.name) and preferMob ~= nil and mob.name ~= preferMob.name then
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
    local dx = enemy_pos.x - me_pos.x
    local dy = enemy_pos.y - me_pos.y
    local dist =  math.sqrt(dx*dx + dy*dy)
    local enemy_space = 1
    if control.enemy_space == control.ENEMY_SPACE_NEAR then
	enemy_space = 2
    elseif control.enemy_space ==  control.ENEMY_SPACE_MAGIC then
	enemy_space = 4
    elseif control.enemy_space ==  control.ENEMY_SPACE_MANUAL then
	enemy_space = 99999
    end
    if iamLeader() then
	if dist > enemy_space then
	    isFar = true
	end
    end
    if isFar then
        --　戦闘中でないときは、WSやMAを自粛。フェイスが動かないので。
        if dist / mob.model_size > enemy_space or player.status == 0 then
            windower.ffxi.run(dx, dy)
            -- 向きが悪くて戦闘が開始しない問題への対策
            -- command.send('setkey numpad5 down; wait 0.05; setkey numpad5 up')
            return
        elseif settings.Calm == false then
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
	else
	    windower.ffxi.run(false)
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
    -- local tp100Jobs = {-"RNG", "BLM", "SMN", "SCH"}
    local tp100Jobs = {}
    --- WAR はスチサイ用。DNC はダンス用？
    local tpJobs = {"DNC"}
--    local tpMin = 1200
--    local tpMax = 1500
    local tpMin = 2000
    local tpMax = 2500
    if utils.table.contains(tp100Jobs, player.main_job) then
        tpMin = 1050
        tpMax = 1150
    elseif utils.table.contains(tpJobs, player.main_job) then
        tpMin = 2000
        tpMax = 2300
    end
    local ws_request = false
    local now = os.time()
    -- 連携になるよう 4秒あける。MB を邪魔しないよう 連携から 10秒あける。
    if player.vitals.tp >= 1000 and
	(acinspect.ws_time + 4) < now and (acinspect.sc_time + 10) < now then
		ws_request = true
    end
    if player.vitals.tp >= 2000 and
	(acinspect.ws_time + 3) < now and (acinspect.sc_time + 9) < now then
	-- TP:2000 超えは少しピーキーにする。
	ws_request = true
    end
    if player.vitals.tp >= 2500 and (acinspect.sc_time + 8) < now then
	-- print("(now - sc_time):"..(now - acinspect.sc_time), acinspect.sc_time)
	ws_request = true
    end
    -- ドメインベーションはTP1000即撃ち
    if player.vitals.tp >= 1000 and utils.table.contains({"Azi Dahaka", "Naga Raja", "Quetzalcoatl", "Mireu"}, mob.name) then
	ws_request = true
    end
    if ws_request == true then
	task.setTaskSimple("//ws exec", 0, 3)
	return
    else
        if player.item_level > 99 then
            local commprob = getSendCommandProbTable(mainJob, subJob, 1)
--            io_chat.print(commprob)
            sendCommandProb(commprob, settings.Period, ProbRecastTime)
        end
    end
---    if math.random(1, 100) <= 1 then
    --- 戦闘ターゲットがたまに外れる対策。とりあえずの方法。
    if iamLeader() or control.puller then
        if math.random(1, 10) <= 1 then
            command.send('input /attack <t>')
        end
    end
    --- たまに左や右にずれる。前や後にも。
    if not settings.Calm then
	sendCommandProb({
		{ 10, 10, 'setkey a down; wait 0.1; setkey a up', 0 }, -- left
		{ 10, 10, 'setkey d down; wait 0.1; setkey d up', 0 }, -- right
		{ 20, 10, 'setkey w down; wait 0.1; setkey w up', 0 }, -- forward
		{ 20, 10, 'setkey s down; wait 0.1; setkey s up', 0 }, -- back
			}, settings.Period, ProbRecastTime)
    end
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
        -- print("idleFunctionTradeItems: mob not found")
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
	io_chat.print("↓ トレード開始 ↓")
        for i, id in pairs(items) do
            if acitem.inventoryHasItem(id) then
                acitem.tradeByItemId(mob, id)
		print("trade item:"..id)
                coroutine.sleep(1)
                io_net.targetByMobId(mob.id)
                coroutine.sleep(wait-1)
                for i, w in ipairs(enterWaits) do
                    pushKeys({"enter"})
		    print("push enter > sleep:"..w)
                    coroutine.sleep(1)
                    io_net.targetByMobId(mob.id)
                    coroutine.sleep(w-1)
                end
            end
        end
	io_chat.print("↑ トレード終了 ↑")
	control.auto = false
    end
    coroutine.sleep(1)
end

-- ジャンクアイテムをかばんに集める
local aggregateJunkItemsToInventory = function()
    local count = 0
    count = count + acitem.safesToInventoryT(JunkItemsT)
    count = count + acitem.bagsToInventoryT(JunkItemsT)
    -- print("aggregateJunkItemsToInventoryT: "..count)
    return count
end

-- ジャンクアイテムをかばんに集める (多分、ここが重たい)
local aggregateJunkItemsToInventory___ = function()
    local count = 0
    for i, id in pairs(JunkItems) do
        if acitem.checkInventoryFreespace() == false then
            break
        end
        if acitem.safesHasItem(id) then
            print("safes "..id.." to Inventory")
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
	--[[ -- 怖いので Safes は一旦無し
        if acitem.safesHasItem(-id) then
            print("safes "..id.." to Inventory")
            acitem.safesToInventory(-id)
            count = count + 1
            coroutine.sleep(0.5)
	end
	]]
        if acitem.bagsHasItem(-id) then
            print("bags id:"..id.." to Inventory")
            acitem.bagsToInventory(-id)
            count = count + 1
            coroutine.sleep(0.5)
        end
	-- drop予定アイテムも集める
    end
    print("aggregateJunkItemsToInventory: "..count)
    return count
end

-- かばん内のジャンクアイテムを数える
local countJunkItemsInInventory = function ()
    local count = 0
    for index = 1, 80 do
	local item = windower.ffxi.get_items(0, index)
	if item and item.id ~= 0 then
	    -- io_chat.print({"item:", item.status, item.id,
	    -- res.items[item.id].ja })
	    if JunkItemsT[item.id] == true then
		count = count + 1
	    end
	end
    end
    return count
end

local sellJunkItemsInInventory = function()
    local total_count = countJunkItemsInInventory()
    io_chat.setNextColor(5)
    io_chat.print(total_count.."回売却 start")
    local remain_count = total_count
    for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
	-- io_chat.print({ "item:", item.status, item.id, res.items[item.id].ja })
        if item and JunkItemsT[item.id] == true then
            windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,item.count,0,0,0,
                                        item.id%256,math.floor(item.id/256)%256,index,0))
            windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
	    -- io_chat.print({"item:", windower.to_shift_jis(res.items[item.id].ja), item.id, item.status})
            remain_count = remain_count - 1
            if remain_count <= 0 then
                break
            end
            if remain_count % 5 == 0 then
		io_chat.setNextColor(6)
                io_chat.print("# "..remain_count.."/"..total_count)
            end
            coroutine.sleep(math.random(6,8)/4)
        end
    end
    print("junk sold out", total_count)
    io_chat.setNextColor(5)
    io_chat.print(total_count.."回売却 end")
---  stop() ---何故か動かない
    control.auto = false
end

local idleFunctionSellJunkItems = function()
    -- 可搬ストレージのジャンクアイテムをかばんに集める
    print("Aggregate Bag Junk Items to Inventory")
    aggregateJunkItemsToInventory()
    local done = false
    while done == false and control.auto do
        -- 売却処理
        sellJunkItemsInInventory()
        local move_count = aggregateJunkItemsToInventory()
        if move_count == 0 then
            -- 移動するアイテムがなければ終了
            done = true
        end
    end
    -- ついでに売れないゴミも捨てる
    dropJunkItemsInInventory()
end

function dropJunkItemsInInventory()
    print("dropJunkItemsInInventory")
    local remain_count = total_count
    for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
--        io_chat.print({"item:", windower.to_shift_jis(res.items[item.id].ja), item.id, item.status})
        if item and JunkItemsT[-item.id] == true then
            -- print("drop???:"..item.id.."("..index..") x "..item.count)
            windower.ffxi.drop_item(index, item.count)
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
        control.auto = false
    elseif mob.name == "Mineral Vein" or mob.name == "Mineral Vein #2"
            or mob.name == "Mineral Vein #3"
            or mob.name == "Arboreal Grove" or mob.name == "Arboreal Grove #2"
            or mob.name == "Arboreal Grove #3" then
        while control.auto do
            pushKeys({"escape", "f8", "enter"})
            coroutine.sleep(2)
            pushKeys({"enter"})
            coroutine.sleep(3)
            if acitem.diffInventoryTotalNum() == 0 or
                acitem.checkInventoryFreespace() == false then
                control.auto = false
            end
        end
    elseif mob.name == "Pond Dredger" then
        control.auto = false
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
    idleFunctionTradeItems("Gondebaud", cipher_ids, 4, {15,2})
    -- 盟-マルグレートで失敗するので、以下の調整をしてみたがダメだった
    -- idleFunctionTradeItems("Gondebaud", cipher_ids, 7, {14,14})
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
            control.auto = false
        end
        control.auto = false
    elseif mob.name == "Nunaarl Bthtrogg" then
        n = acitem.inventoryFreespaceNum()
	io_chat.setNextColor(6)
        io_chat.print("かばんの空きは"..n.."*99 = "..(n*99))
        control.auto = false
    end
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
        works.boost.stationWorkerFunction(zone, mob)
	control.auto = false
    end
    if mob.name == "Ergon Locus" then
	works.survey.ergonLocusFunction()
    end
end

local tickRunning = false
function tick()
    if tickRunning then -- 二重に動かないガード。(ちゃんと働いているか不明)
	print("tick tickRunning:", tickRunning)
        return
    end
    tickRunning = true
    tick_serial()
    tickRunning = false
end

function tick_serial()
    -- print("tick_serial").
    local player = windower.ffxi.get_player()
    local me = windower.ffxi.get_mob_by_target("me")
    if player == nil or me == nil then
	-- ログイン時に player は nil
	-- エリアチェンジ時に me ターゲットできない
	return
    end
    zone_change.warp_handler_tick()
    aczone.tick(player)
    contents.tick(player)
    task.tick()
    if not control.auto then
        return
    end
    -- ここからは control.auto のみ
    ac_equip.tick(player)
    acjob.tick(player)
    -- 待機、マウント(85)
    -- https://github.com/Windower/Resources/blob/master/resources_data/statuses.lua
    if player.status == 0 or player.status == 85 then
	--- 待機中
	idleFunction()
	if iamLeader() == true or puller then
	    leaderFunction()
	elseif iamLeader() == false then
	    notLeaderFunction()
	end
    elseif player.status == 1 then
	--- 戦闘中
	figtingFunction()
    elseif player.status == 4 then
	-- イベント中
    elseif player.status == 33 then
	-- 休憩中
    else
	print("player.status: "..player.status)
    end
end

local start = function()
    io_chat.print('### AC START')
    io_chat.print("CampRange: " .. settings.CampRange)
    getMobPosition(start_pos, "me")
    io_chat.print("save start_pos: {x:" .. math.round(start_pos.x,2) .. " y:"..math.round(start_pos.y,2)  .. " z:"..math.round(start_pos.z,2).."}")
    settings = config.load(defaults)
    control.auto = true
    print("iamLeader()", iamLeader())
    if iamLeader() then
	io_ipc.send_party("start")
    end
end
M.start = start

local stop = function()
    io_chat.print('### AC STOP')
    if iamLeader() then
	io_ipc.send_party("stop")
    end
    control.auto = false
    ac_move.stop()
    works.stop()
    task.allClear()
end
M.stop = stop

windower.register_event('ipc message', function(message)
    --    print("IPC:"..message)
    io_ipc.recieve(message)
end)


local changeWS = function(wskey)
    if wskey == nil then
        io_chat.print(ws.getWeaponSkillUsage())
        return
    end
    if wskey == 'any' then
        wskey = ws.getAnyWeaponSkill()
    elseif wskey == 'stop' or wskey == 'no' then
        ws.weaponskill = nil
        io_chat.print("ws stop")
        return
     end
    print('wskey', wskey)
    if ws.weaponskillTable[wskey] == nil then
        print("unknown ws", wskey)
        return
    end
    ws.weaponskill = wskey
    wsName = ws.weaponskillTable[ws.weaponskill]
    io_chat.print('set any', wskey, '=>', wsName)
end

local showMob = function()
    print("showMob")
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
---        print("not found mob by target:" ..target)
    else
        io_chat.print(mob)
    end
    local me_pos = {}
    if getMobPosition(me_pos, "me") == true then
	io_chat.print("utils.distance: ", ac_pos.distance(me_pos, mob))
    end
end

function argument_means_on(s)
    if utils.table.contains({"on", "yes", "y", "enable", "1"}, s) then
	return true
    end
    if utils.table.contains({"off", "of", "no", "n", "disable", "0"}, s) then
	return false
    end
    return nil
end

windower.register_event('addon command', function(...)
    local command = select(1, ...)
    local arg1 = select(2, ...)
    local arg2 = select(3, ...)
    command = command and command:lower() or 'help'
    -- start/stop, (諸々ABC順), help の並び
    if command == 'start' then
        start()
	ac_defeated.done()
	io_chat.setNextColor(6)
	io_chat.printf("mode attack=%s puller=%s calm=%s", tostring(settings.Attack), tostring(puller), tostring(settings.Calm))
    elseif command == 'stop' then
        stop()
    elseif command == 'all' then
	if arg1 == 'warp' or
	    arg1 == 'dim' or arg1 == 'holla' or arg1 == 'mea' then
	    local item_name = "デジョンリング"
	    local item_id = 28540
	    if arg == "dim" then
		item_name = "Ｄ．ホラリング"
		item_id = 26176
	    elseif arg == "holla" then
		item_name = "Ｄ．デムリング"
		item_id = 26177
	    elseif arg == "mea" then
		item_name = "Ｄ．メアリング"
		item_id = 26178
	    end
	    task.allClear()
	    io_chat.print(item_name.."10秒前")
	    io_ipc.send_all("all", arg1)
	    local slot_right_ring = 14
	    acitem.useEquipItem(slot_right_ring, item_id, item_name, 10)
	elseif arg1 == 'reload' then
	    io_ipc.send_all("all", "reload")
	    task.setTaskSimple("lua u AC; wait 1; lua l AC", 0, 1)
	else
	    print("ac all reload | warp | holla | dim | mea")
	end
    elseif command == 'attack' or command == 'att' or command == 'at' then
	local onoff = argument_means_on(arg1)
	if onoff ~= nil then
	    settings.Attack = onoff
	    io_chat.setNextColor(6)
	    io_chat.print("attack mode "..arg1)
	else
	    io_chat.setNextColor(3)
	    io_chat.print("Usage: ac attack (on|off)")
	end
    elseif command == 'calm' then
	local onoff = argument_means_on(arg1)
	if onoff ~= nil then
	    settings.Calm = onoff
	    io_chat.setNextColor(6)
	    io_chat.print("ac calm "..arg1)
	else
	    io_chat.setNextColor(3)
	    io_chat.print("Usage: ac calm (on|off)")
	end
    elseif command == 'camprange' then
        settings.CampRange = tonumber(arg1, 10)
        io_chat.print("CampRange:", arg1)
    elseif command == 'control' or command == 'cnt' then
	if arg1 == 'debug' and arg2 ~= nil then
	    local onoff = argument_means_on(arg2)
	    control.debug = onoff
	    io_chat.setNextColor(6)
	    io_chat.print("ac control debug "..tostring(onoff))
	else
	    print("ac control debug on|off")
	end
    elseif command == 'debug' then
	if arg1 == 'checkbags' then
	    io_chat.print(acitem.checkInventoryFreespace())
	    io_chat.print(acitem.checkBagsFreespace())
	elseif arg1 == 'linked' then
	    local mob = windower.ffxi.get_mob_by_target("t")
	    if mob == nil then
		print("no target")
	    else
		print("ac linked => ", isMobLinked(mob))
	    end
	elseif arg1 == 'nearest' then
	    local condition = {
		range = settings.CampRange,
		nameMatch = control.enemy_filter,
	    }
	    local mob = acmob.searchNearestMob(start_pos, condition)
	    io_chat.print("nearest preferMob=====================")
	    io_chat.print(preferMob)
	    io_chat.print("nearest mob =====================")
	    if preferMob == nil or preferMob.name ~= mob.name then
		io_chat.print(mob)
	    else
		io_chat.print("same name monster")
	    end
	else
	    print("ac debug checkbags|linked|neaest")
	end
    elseif command == 'defeated' then
	-- 戦闘終了時の処理
	ac_defeated.done()
    elseif command == 'dothebest' then
	acjob.dothebest(player)
    elseif command == 'dropjunk' then
	io_chat.print("アイテム廃棄開始")
	dropJunkItemsInInventory()
	io_chat.print("アイテム廃棄終わり")
    elseif command == 'echo' then
	io_chat.setNextColor(6)
	io_chat.print(arg1)
    elseif command == 'enemy' then
	if arg1 == 'filter' then
	    control.enemy_filter = arg2
	    io_chat.setNextColor(6)
	    io_chat.print("ac enemy filter", control.enemy_filter)
	else
	    print("ac enemy filter <enemy substring>")
	end
    elseif command == 'enemyspace' or command == 'es' then
	if arg1 == 'near' then
	    control.enemy_space = control.ENEMY_SPACE_NEAR
	elseif arg1 == 'manual' then
	    control.enemy_space = control.ENEMY_SPACE_MANUAL
	elseif arg1 == 'magic' then
	    control.enemy_space = control.ENEMY_SPACE_MAGIC
	elseif arg1 == 'role' then
	    control.enemy_space = control.ENEMY_SPACE_ROKE
	else
	    print("ac enemyspace (near|manual|magic|role)")
	end
    elseif command == 'enterloop' then
        control.auto = true
        local i = 0
	local mob = windower.ffxi.get_mob_by_target("t")
        while control.auto do
            print("enter #"..i)
            i = i + 1
            pushKeys({"enter"})
            coroutine.sleep(2)
	    io_net.targetByMobId(mob.id)
	    local m = windower.ffxi.get_mob_by_target("t")
	    if m.id ~= mob.id then
		control.auto = false
	    end
	    coroutine.sleep(1)
        end
    elseif command == 'enterloop2' then
        control.auto = true
        while control.auto do
            print("down & enter")
            pushKeys({"down", "enter"})
            coroutine.sleep(3)
        end
    elseif command == 'equip' then
	if arg1 == 'save' then
	    io_chat.setNextColor(6)
	    io_chat.print("% equip save")
	    ac_equip.equip_save(true)
	elseif arg1 == 'restore' then
	    io_chat.setNextColor(6)
	    io_chat.print("% equip restore")
	    ac_equip.equip_restore()
	else
	    print("ac equip (save|restore)")
	end
    elseif command == 'finishblow' then
	-- setFinish 
    elseif command == 'inject' then
	if arg1 == 'currinfo1' then
	    local p = packets.new('outgoing', 0x10F, {}) -- Curr Info
	    packets.inject(p)
	elseif arg1 == 'currinfo2' then
	    local p = packets.new('outgoing', 0x115, {}) -- Curr Info 2
	    packets.inject(p)
	elseif arg1 == 'partylist' then  -- 落ちる
	    --local p = packets.new('outgoing', 0x078, {}) -- Party list request
	    --packets.inject(p)
	else
	    print("ac inject currinfo1 | currinfo2")
	end
    elseif command == 'magic' or command == 'magick' then
	role_Sorcerer.setMagic(arg1)
    elseif command == 'move' then
        local zone = windower.ffxi.get_info().zone
	local routeTable = aczone.getRouteTable(zone)
        ac_move.autoMoveTo(zone, {arg1, arg2}, routeTable)
    elseif command == 'moverev' then
        local zone = windower.ffxi.get_info().zone
	local routeTable = aczone.getRouteTable(zone)
        ac_move.autoMoveTo(zone, {"-"..arg1}, routeTable)
    elseif command == 'party' then
	if arg1 == 'build' then
	    io_ipc.send_party("party", "build")
	elseif arg1 == 'warp' then
	    io_chat.print("デジョン15秒前")
	    io_ipc.send_party("party", "warp")
	    coroutine.sleep(5)
	    task.allClear()
	    io_chat.print("デジョン10秒前")
	    local slot_right_ring = 14
	    local warpring_id = 28540
	    acitem.useEquipItem(slot_right_ring, warpring_id, 'デジョンリング', 9)
	else
	    print("ac party build | warp")
	end
    elseif command == 'point' then
        doPointCheer = not doPointCheer
        io_chat.print({"do point&cheer for ambus", doPointCheer})
    elseif command == 'pos' then  -- よく使うので ac 直下のまま
        local zone = windower.ffxi.get_info().zone
        io_chat.print("zone id:"..zone)
        local me_pos = {}
        getMobPosition(me_pos, "me")
        local x = math.round(me_pos.x, 1)
        local y = math.round(me_pos.y, 1)
        local z = math.round(me_pos.z, 1)
---    print は - 記号を誤認しやすいので、表示しない
---        print("me potision", " x="..x, "  y="..y, "  z="..z)
        io_chat.print("me potision  x="..x.."  y="..y.."  z="..z)
    elseif command == 'puller' then
	local onoff = argument_means_on(arg1)
	if onoff ~= nil then
            control.puller = onoff
	    io_chat.setNextColor(6)
            io_chat.print("ac puller "..arg1)
        else
	    io_chat.setNextColor(3)
            io_chat.print("Usage: ac puller (on|off)")
        end
    elseif command == 'record' or command == 'rec' then
	if arg1 == 'char' then
	    io_chat.setNextColor(6)
	    io_chat.print("record char")
	    ac_record.record_char()
	elseif arg1 == 'spells' then
	    io_chat.setNextColor(6)
	    io_chat.print("record spells")
	    ac_record.record_spells()
	end
    elseif command == 'show' then
	if arg1 == 'char' then
	    ac_char.print()
	elseif arg1 == 'chatcolor' then
	    for i, desc in ipairs({"白", "赤紫", "オレンジ", "ピンク","水色", "エメラルド","紫", "明赤紫", "白", "肌色"}) do
		io_chat.setNextColor(i)
		io_chat.printf("Color:%d => %s", i, desc)
	    end
	elseif arg1 == 'inventory' then
	    acitem.showInventory()
	elseif arg1 == 'listener' then
	    incoming_text.showListener()
	elseif arg1 == 'mob' then
	    showMob()
	elseif arg1 == 'party' then
	    ac_party.showPartyMembers()
	elseif arg1 == 'stat' then
	    ac_stat.print()
	elseif arg1 == 'task' then
	    task.print()
	else
	    io_chat.print("ac show { char | chatcolor | inventory | listener | mob | party | stat | task }")
	end
    elseif command == 'test' then
        print("test command")
        ac_mob.PartyTargetMob()
    elseif command == 'tick' then
	local period = tonumber(arg1, 10)
	if period ~= nil and 0.1 < period and period < 10 then
	    settings.Period = period
	else
	    print("ac tick <period> illegal:"..arg1)
	end
    elseif command == 'use' then
	if arg1 == 'silt' then
	    useSilt = not useSilt
	    io_chat.print({"item silt using start", useSilt})
	elseif arg1 == 'beads' then
	    useBeads = not useBeads
	    io_chat.print({"item beads using start", useBeads})
	elseif arg1 == 'scroll' then
	    io_chat.print("スクロール学習開始")
	    for i,id in ipairs(item_data.magicScrolls) do
		acitem.useItemIncludeBags(id)
	    end
	    io_chat.print("スクロール学習終わり")
	elseif arg1 == 'soulstonesack' then
	    io_chat.print("石の袋開き開始")
	    control.auto = true
	    while control.auto and
		acitem.inventoryHasItemT(item_data.soulStoneSacksT) do
		for i,id in ipairs(item_data.soulStoneSacks) do
		    if not acitem.checkBagsFreespace() then
			io_chat.print("アイテム満杯")
			break
		    end
		    acitem.useItemIncludeBags(id)
		end
	    end
	    io_chat.print("石の袋開き終わり")
	else
	    io_chat.print("ac use { silt | beads | scroll | soulstonesack}")
	end
    elseif command == 'ws' then
        changeWS(arg1)
    elseif command == 'help' then
        io_chat.print('AC (AccountCluster)  v' .. _addon.version .. 'commands:')
        io_chat.print('//ac [options]')
        io_chat.print('    start              - Starts auto attack')
        io_chat.print('    stop               - Stops auto attack')
        io_chat.print('    all warp           - All member action')
	io_chat.print('    attack on|off      - Change attack mode')
	io_chat.print('    debug ...          - Debug information')
	io_chat.print('    defeated           - Defeated Process')
	io_chat.print('    dropjunk           - Drop JunkItem')
	io_chat.print('    echo               - Echo Arbitrary Text to Chat')
	io_chat.print('    enterloop          - Enter press loop')
	io_chat.print('    finish             - Finish method for fight')
	io_chat.print('    inject             - Inject Packet')
	io_chat.print('    magic fire|ice|... - Set MB Magic attribute')
        io_chat.print('    move <route>       - Auto move')
	io_chat.print('    moverev <route>    - Auto move reverse')
        io_chat.print('    party build|warp   - Party action')
	io_chat.print('    point              - Point action for ambus')
	io_chat.print('    pos                - Show current position')
        io_chat.print('    puller on|off      - Change puller mode')
	io_chat.print('    record char|spells - Reord Status to LogFile')
        io_chat.print('    show mob|...       - Show something')
	io_chat.print('    tick <period>      - Change tick period')
        io_chat.print('    use silt|...       - Use Item')
        io_chat.print('    ws any|...         - Change weapon skill')
        io_chat.print('    help               - Displays this help text')
        io_chat.print(' ')
        io_chat.print('AC will automate account cluster something.')
        io_chat.print('To start AC without commands use the key:  Ctrl+D')
        io_chat.print('To stop AC attacks in the same manner:  Atl+D')
    else
        io_chat.print("See ac help!!!")
    end
end)

windower.register_event('load', function()
    tick:loop(1.0)
    ws.init()
    local zone = windower.ffxi.get_info().zone
    zone_change.zone_in_handler(zone, nil)
    -- command, delay, duration
    task.setTaskSimple("ac inject currinfo1", 2, 1)
    task.setTaskSimple("ac inject currinfo2", 4, 1)
    task.setTaskSimple("//record char", 6, 1)
    local incoming_text_handler = function(text)
	if not control.auto then
	    return
	end
	if string.contains(text, "コマンドが実行できない") and
	    control.enemy_space == control.ENEMY_SPACE_NEAR then
	    if string.contains(text, "近づかないとコマンドが") or
		string.contains(text, "遠くにいるため、コマンドが")then
		--io_chat.setNextColor(6)
		--io_chat.print("前に詰める")
		keyboard.longpushKey("w", 3.0)  -- 前に詰める
	    elseif string.contains(text, "姿が見えないためコマンドが") then
		--io_chat.setNextColor(6)
		--io_chat.print("左後ろに回る")
		pushKeys({"numpad*"})  -- ターゲットを一瞬外して
		pushKeys({"a", "s"})  -- 左後ろ
		pushKeys({"numpad*"})  -- ターゲットを戻す
	    end
	elseif string.contains(text, "の詠唱は中断された") then
	    -- io_chat.setNextColor(3)
	    -- io_chat.print("詠唱の中断を検知")
	elseif string.contains(text, "魔法を唱えることができない") then
	    -- io_chat.setNextColor(3)
	    -- io_chat.print("魔法唱える失敗を検知")
	elseif string.contains(text, "の命のカウントダウン") then
	    command.send('input /item 聖水 <me>')
	end
    end
    incoming_text.addListener("", incoming_text_handler)
end)

windower.register_event('login', function()
    -- ws.init()  -- このタイミングだと前のキャラのジョブが反映される
    ac_stat.init()
end)

windower.register_event('logout', function()
    -- command, delay, duration
    --task.setTaskSimple("ac inject currinfo1", 2, 1)
    --task.setTaskSimple("ac inject currinfo2", 4, 1)
    --task.setTaskSimple("//record char", 6, 1)
    task.setTaskSimple("//record char", 0, 1)
end)

windower.register_event('job change', function()
    ws.init()
    ac_stat.init()
    -- command, delay, duration
    task.setTaskSimple("ac inject currinfo1", 2, 1)
    task.setTaskSimple("ac inject currinfo2", 4, 1)
    task.setTaskSimple("//record char", 6, 1)
end)

windower.register_event('status change', function(new, old)
    task.setTaskSimple("//record char", 1, 1)
end)

--- ゾーンが変わったらリーダーだけ停止する
windower.register_event('zone change', function(zone, prevZone)
    ac_record.record_char()
    ac_record.record_spells()
    ac_stat.init()
    task.init()
    if iamLeader() then
	control.auto = false
    end
    useSilt = false
    useBeads = false
    doPointCheer = false
    zone_change.zone_change_handler(zone, prevZone)
    ws.init()
    -- command, delay, duration
    task.setTaskSimple("ac inject currinfo1", 2, 1)
    task.setTaskSimple("ac inject currinfo2", 4, 1)
    task.setTaskSimple("//record char", 6, 1)
    control.enemy_filter = nil
    control.puller = false
end)

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    incoming_chunk.incoming_handler(id, data, modified, injected, blocked)
end)

windower.register_event('outgoing chunk', function(id, data, modified, injected, blocked)
    outgoing_chunk.outgoing_handler(id, data, modified, injected, blocked)
end)

windower.register_event('incoming text', function(data, modified, original_mode, modified_mode, blocked)
    incoming_text.incoming_handler(data, modified, original_mode, modified_mode, blocked)
end)

local loopConf = function()
    return control.auto
end

--windower.register_event('load', function()
---    local c = check:loop(1)
--end)

--Copyright 2025, yoya@awm.jp
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
