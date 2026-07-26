_addon.author = 'Yoya'
_addon.version = '1.3.0'
_addon.commands = {'accountcluster', 'ac'}

local M = {}
__AC = M

require('functions')
local res = require 'resources'
local socket = require 'socket'
local config = require 'config'
local control = require 'control'
local packets = require 'packets'

local utils = require 'utils'
local command = require 'command'
local task = require 'task'
local works = require 'works'
local contents = require 'contents'
contents.AC = M
local pull = require 'pull'
local puller = false
local defaults = {
    AccountList = { },
    Control = { Debug = "off", },
}

local settings = config.load(defaults)

local io_chat = require 'io/chat'
local acevent = require 'event'

local ac_focus = require 'ac/focus'

ac_focus.init(settings.AccountList)

local useSilt = false
local useBeads = false
local useFaith = false

local item_data = require 'item/data'

local crystal_ids = item_data.crystal_ids -- クリスタル/塊
local seal_ids = item_data.seal_ids -- 印章
local cipher_ids = item_data.cipher_ids --  盟スクロール
local bayld_swap_ids = item_data.bayld_swap_ids --  ベヤルド交換品
local gob_dial_key_ids = item_data.gob_dial_key_ids -- 不思議箱ダイヤルキー

-- 優先して釣る敵
local preferredEnemyList = {
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


-- https://docs.windower.net/commands/input/
-- 邪魔なショートカットを無効化
-- command.send('bind @d ac print Win+D are disabled') -- デスクトップ表示/非表示
command.send('bind @l ac print Win+L are disabled') -- 画面ロック
command.send('bind @m ac print Win+M are disabled') -- 全ウィンドウ最小化
-- 操作
command.send('bind ^d ac party start') -- alt-d
command.send('bind !d ac party stop')  -- ctl-d
command.send('bind @d ac stop')        -- win-d
command.send('bind ^f ac show mob')

local keyboard = require 'keyboard'
local push_keys = keyboard.push_keys

local ac_pos = require 'ac/pos'
local ac_move = require 'ac/move'
ac_move.AC = M
local ac_record = require 'ac/record'
local ac_char = require 'ac/char'

local turn_to_pos = ac_move.turn_to_pos
local turn_to_front = ac_move.turn_to_front

local ac_party = require 'ac/party'
local iam_leader = ac_party.iam_leader

local io_net = require 'io/net'

local io_ipc = require 'io/ipc'
io_ipc.AC = M  -- for callback

local ac_stat = require 'ac/stat'
local acinspect = require 'inspect'

local acitem = require 'item'

local ws = require 'ws'
local acprob = require 'prob'
local send_command_prob = acprob.send_command_prob
local get_send_command_prob_table = acprob.get_send_command_prob_table
local aczone = require 'zone'
aczone.AC = M  -- for callback
local zone_change = require 'zone/change'
local outgoing_chunk = require 'outgoing/chunk'
local incoming_chunk = require 'incoming/chunk'
local incoming_text = require 'incoming/text'

local acmob = require 'mob'
local get_mob_position = acmob.get_mob_position

local acjob = require 'job'

local battle = require('battle')
local role_Sorcerer = require('role/Sorcerer')
local role_Leader = require('role/Leader')
local role_Follower = require('role/Follower')
local ac_defeated = require 'ac/defeated'
local ac_equip = require 'ac/equip'

local JunkItemIdSet = acitem.junk.JunkItemIdSet  -- 売却+廃棄 (かばんに集める用)
local SellItemIdSet = acitem.junk.SellItemIdSet
local DropItemIdSet = acitem.junk.DropItemIdSet

local isFar = false
local fightingMobName = nil

--- リーダー待機用
local prevDx = 0
local prevDy = 0
local leader_function = function()
    -- print("I am a leader")
    local me_pos = {}
    if get_mob_position(me_pos, "me") ~= true then
	-- zone チェンジでよくある
        -- print("get_mob_position failed ???")
        return
    end
    -- リンクしてる敵
    local condition = {
	range = control.enemy_range,
	linkedOnly = true,
	-- nameMatch = control.enemy_filter,
    }
    local mob = acmob.search_nearest_mob(me_pos, condition)
    -- 優先する敵
    if mob == nil then
	local condition = {
	    range = control.enemy_range,
	    preferMobs = utils.table.merge_lists(acmob.moreAttractiveEnemyList, preferredEnemyList),
	    nameMatch = control.enemy_filter,
	}
	mob = acmob.search_nearest_mob(pull.base_pos, condition)
	---    print("nearest preferred mob", mob)
    end
    if mob == nil then
        --- メンバーが戦っている敵がいれば、そちら優先
        -- mob = acmob.PartyTargetMob()
    end
    if mob == nil then
        --- 優先度の高い敵がいない場合は、誰でも良い
	local condition = {
	    range = control.enemy_range,
	    nameMatch = control.enemy_filter,
	}
	mob = acmob.search_nearest_mob(pull.base_pos, condition)
    end
    if mob ~= nil and control.attack then
        windower.ffxi.run(false)
	io_net.target_by_mob(mob)
	coroutine.sleep(0.2)
	command.send('input /target <t>')
	coroutine.sleep(0.2)
        command.send('input /attack on')
    elseif pull.base_pos ~= nil then
        local dx = pull.base_pos.x - me_pos.x
        local dy = pull.base_pos.y - me_pos.y
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
	-- near の範囲を通り過ぎると永久に往復するのでその対処
	local vec1 = { x=dx, y=dy }
	local vec2 = { x=prevDx, y=prevDy }
	local similarity = utils.vector.CosineSimilarity(vec1, vec2)
	prevDx = dx
	prevDy = dy
	if similarity < -0.8 then
	    -- 逆向きに動いたら近くになったと判断して停止かつ
	    -- print("DEBUG: similarity=", similarity)
	    isFar = false
	    coroutine.sleep(0.2)
	    windower.ffxi.run(false)
	end
    end
    if control.attack then
        command.send('input /attack on')
	acprob.clear_prob_recast_time()
	task.reset_by_fight()
    end
end 

local idle_function_trade_items = function(tname, items, wait, enterWaits)
---    command.send('input /targetnpc')
    local mob = windower.ffxi.get_mob_by_name(tname)
    if mob == nil then
        -- print("idle_function_trade_items: mob not found")
        return 
    end
    if mob.name == tname then
        for i, id in pairs(items) do
            if acitem.check_inventory_freespace() == false then
                break
            end
            if acitem.bags_has_item(id) then
                acitem.bags_to_inventory(id)
                coroutine.sleep(1)
            end
        end
	io_chat.print("↓ トレード開始 ↓")
        for i, id in pairs(items) do
            if acitem.inventory_has_item(id) then
                acitem.trade_by_item_id(mob, id)
		print("trade item:"..id)
                coroutine.sleep(1)
                io_net.target_by_mob(mob)
                coroutine.sleep(wait-1)
                for i, w in ipairs(enterWaits) do
                    push_keys({"enter"})
		    print("push enter > coroutine.sleep:"..w)
                    coroutine.sleep(1)
                    io_net.target_by_mob(mob)
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
local aggregate_junk_items_to_inventory = function(mob)
    local count = 0
    if mob.name == "Green Thumb Moogle" then
	count = count + acitem.safes_to_inventory_by_set(JunkItemIdSet)
	print("aggregate_junk_items_to_inventory(safes): "..count)
    end
    count = count + acitem.bags_to_inventory_by_set(JunkItemIdSet)
    print("aggregate_junk_items_to_inventory(bags): "..count)
    return count
end

-- かばん内のジャンクアイテムを数える
local count_junk_items_in_inventory = function ()
    local count = 0
    for index = 1, 80 do
	local item = windower.ffxi.get_items(0, index)
	if item and item.id ~= 0 then
	    -- io_chat.print({"item:", item.status, item.id,
	    -- res.items[item.id].ja })
	    if SellItemIdSet[item.id] == true then
		count = count + 1
	    end
	end
    end
    return count
end

local sell_junk_items_in_inventory = function()
    local total_count = count_junk_items_in_inventory()
    io_chat.info(total_count.."回売却 start")
    local remain_count = total_count
    for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
	-- io_chat.print({ "item:", item.status, item.id, res.items[item.id].ja })
        if item and SellItemIdSet[item.id] == true then
            windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,item.count,0,0,0,
                                        item.id%256,math.floor(item.id/256)%256,index,0))
            windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
	    if control.debug then
		io_chat.print({"item:", res.items[item.id].ja, item.id, item.status})
	    end
            remain_count = remain_count - 1
            if remain_count <= 0 then
                break
            end
            if remain_count % 5 == 0 then
                io_chat.info("# "..remain_count.."/"..total_count)
            end
            -- coroutine.sleep(math.random(6,8)/4)  -- 店売りUIガード動く
	    coroutine.sleep(math.random(7,8)/4)
        end
    end
    print("junk sold out", total_count)
    io_chat.info(total_count.."回売却 end")
---  stop() ---何故か動かない
    return total_count
end

local idle_function_sell_junk_items = function(mob)
    -- 可搬ストレージのジャンクアイテムをかばんに集める
    print("Aggregate Bag Junk Items to Inventory")
    aggregate_junk_items_to_inventory(mob)
    while control.auto do
        -- 売却処理
        local sell_count = sell_junk_items_in_inventory()
        local move_count = aggregate_junk_items_to_inventory(mob)
        if sell_count == 0 and move_count == 0 then
            -- 移動するアイテムも売れたアイテムもなければ終了
	    control.auto = false
	    coroutine.sleep(1)
	    break
        end
	coroutine.sleep(2)  -- sleep しないと落ちる事がある
    end
    -- ついでに売れないゴミも捨てる
    drop_junk_items_in_inventory()
    io_chat.notice("all売却 end")
end
M.idle_function_sell_junk_items = idle_function_sell_junk_items

function drop_junk_items_in_inventory()
    local count = 0
    for index = 1, 80 do
        local item = windower.ffxi.get_items(0, index)
        if item and DropItemIdSet[item.id] == true then
            count = count + 1
	    windower.ffxi.drop_item(index, item.count)
	    coroutine.sleep(math.random(6,8)/5)
        end
    end
    if count > 0 then
	io_chat.noticef("廃棄 %d 件 完了", count)
    end
    return count
end



local idle_function_west_adoulin = function()
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
        return
    end
    if mob.name == "Defliaa" then
        idle_function_sell_junk_items(mob)
    elseif mob.name == "Eternal Flame" then
        if acitem.inventory_freespace_num() > 0 then
            command.send('sparks buyall Acheron Shield')
            control.auto = false
        end
        control.auto = false
    elseif mob.name == "Nunaarl Bthtrogg" then
        local n = acitem.inventory_freespace_num()
        io_chat.info("かばんの空きは"..n.."*99 = "..(n*99))
        control.auto = false
    end
end

local idle_function_east_adoulin = function(mob) -- 東アドゥリン
    if mob == nil then return end
    if mob.name == "Malgrom" then
	idle_function_sell_junk_items(mob)
    end
    idle_function_trade_items("Runje Desaali", bayld_swap_ids, 5, {})
--  idle_function_trade_items("Winrix", gob_dial_key_ids, 5, {})
end

local idle_function = function()
    -- print("idle_function")
    local ret
    if  useSilt then
        windower.ffxi.run(false)
        useSilt = acitem.use_item_include_bags(6391)
        return
    end
    if  useBeads then
        windower.ffxi.run(false)
        useBeads = acitem.use_item_include_bags(6392, 4)
        return 
    end
    if  useFaith then -- フェイス手引書
        windower.ffxi.run(false)
        useFaith = acitem.use_item_include_bags(6716, 4)
        return
    end
    if useSilt or useBeads or useFaith then
        return
    end
    local zone = windower.ffxi.get_info().zone
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
        return
    end
    if zone == 246 then --- ジュノ港
	idle_function_trade_items("Shemo", seal_ids, 3, {2,4})  --- or Shami
    elseif zone == 230 then -- 南サンドリア
	idle_function_trade_items("Gondebaud", cipher_ids, 4, {15,2})
	-- 盟-マルグレートで失敗するので、以下の調整をしてみたがダメだった
	-- idle_function_trade_items("Gondebaud", cipher_ids, 7, {14,14})
    elseif zone == 232 then -- サンドリア港
	idle_function_trade_items("Joulet", {4401,5789}, 5, {}) -- 堀ブナ
    elseif zone == 256 then -- 西アドゥリン
        idle_function_west_adoulin()
    elseif zone == 257 then -- 東アドゥリン
	idle_function_east_adoulin(mob)
    end
    -- ワークス応援
    if mob.name == "Station Worker" then
        works.boost.station_worker_function(zone, mob)
	control.auto = false
    end
    if mob.name == "Ergon Locus" then
	works.survey.ergon_locus_function()
    end
    contents.npc_action_handler(zone, mob)
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
    -- print("tick_serial")
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
    --
    -- ここからは control.auto のみ
    --
    ac_equip.tick(player)
    acjob.tick(player)
    -- クリスタルはカバンに仕舞う
    if acitem.check_bags_freespace() then
        for i, id in pairs(crystal_ids) do
            if acitem.inventory_has_item(id) then
                acitem.move_to_bags(id)
            end
        end
    end
    -- 待機、マウント(85)
    -- https://github.com/Windower/Resources/blob/master/resources_data/statuses.lua
    if player.status == 0 or player.status == 85 then
	--- 待機中
	idle_function()
	if ac_move.auto then  -- automove 中
	    pull.base_pos = {x=0, y=0, z=0}
	    get_mob_position(pull.base_pos, "me")  -- start pos を更新
	else -- automove 中は敵を探索して戦ったり、所定の位置に戻ったりしない
	    if iam_leader() == true or control.puller then
		leader_function()
		role_Leader.tick_idle(player, me)
	    elseif iam_leader() == false then
		role_Follower.tick_idle(player, me)
	    end
	end
    elseif player.status == 1 then  -- 戦闘中
	battle.tick(player, me)
    elseif player.status == 3 then  -- 死亡
    elseif player.status == 4 then  -- イベント中
    elseif player.status == 33 then  -- 休憩中
    else
	print("player.status: "..player.status)
    end
end

local start = function()
    settings = config.load(defaults)
    control.attack = true
    pull.base_pos = {x=0,y=0,z=0}
    get_mob_position(pull.base_pos, "me")
    control.auto = true
    io_chat.noticef('<<<<<<< AC START >>>>>>> {x=%d y=%d z=%d}',
		    math.round(pull.base_pos.x,2), math.round(pull.base_pos.y,2),
		    math.round(pull.base_pos.z,2))
    ac_defeated.done()
    io_chat.infof("attack=%s enemy_range=%d, enemy_filter=%s ", tostring(control.attack), control.enemy_range, tostring(control.enemy_filter))
    io_chat.infof("puller=%s wstp=%d provoke=%d, calm=%s", tostring(control.puller), control.wstp, control.provoke, tostring(control.calm))
end
M.start = start

local stop = function()
    io_chat.notice('>>>>>>> AC STOP <<<<<<<')
    control.auto = false
    ac_move.stop()
    works.stop()
    task.all_clear()
    coroutine.sleep(1)
    windower.ffxi.run(false)
    -- command.send('sparks fail')  -- exit_sparks
end
M.stop = stop

local start_party = function()
    if iam_leader() then
	io_chat.notice('<<<<<<< AC START Party >>>>>>>')
	io_ipc.send_party("start")
    end
    start()
end

local stop_party = function()
    if iam_leader() then
	io_chat.notice('>>>>>>> AC STOP Party <<<<<<<')
	io_ipc.send_party("stop")
    end
    stop()
end

windower.register_event('ipc message', function(message)
    if control.debug then
	print("AC: ipc message:", message)
    end
    io_ipc.receive(message)
end)


local change_ws = function(wskey)
    if wskey == nil then
        io_chat.print(ws.get_weapon_skill_usage())
        return
    end
    if wskey == 'any' then
        wskey = ws.get_any_weapon_skill()
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
    local wsName = ws.weaponskillTable[ws.weaponskill]
    io_chat.print('set any', wskey, '=>', wsName)
end

local show_mob = function()
    print("show_mob")
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
---        print("not found mob by target:" ..target)
    else
        io_chat.print(mob)
    end
    local me_pos = {}
    if get_mob_position(me_pos, "me") == true then
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

function M.warp_with_equip(arg, delay)
    io_chat.print("### 指輪ワープ", arg)
    if arg == 'warp' or
	arg == 'dim' or arg == 'holla' or arg == 'mea' then
	local item_name = "デジョンリング"
	local item_id = 28540
	if arg == "holla" then
	    item_name = "Ｄ．ホラリング"
	    item_id = 26176
	elseif arg == "dim" then
	    item_name = "Ｄ．デムリング"
	    item_id = 26177
	elseif arg == "mea" then
	    item_name = "Ｄ．メアリング"
	    item_id = 26178
	end
	task.all_clear()
	io_chat.info(item_name..delay.."秒前")
	local slot_right_ring = 14
	acitem.use_equip_item(slot_right_ring, item_id, item_name, delay)
    else
	print("Unknown arg:", arg)
    end
end

windower.register_event('addon command', function(...)
    local subcommand = select(1, ...)
    local arg1 = select(2, ...)
    local arg2 = select(3, ...)
    local arg3 = select(4, ...)
    local arg4 = select(5, ...)
    M.addon_command_handler(subcommand, arg1, arg2, arg3, arg4)
end)

function M.addon_command_handler(subcommand, arg1, arg2, arg3, arg4)
    local player = windower.ffxi.get_player()
    local me = windower.ffxi.get_mob_by_target("me")
    local zone = windower.ffxi.get_info().zone
    subcommand = subcommand and subcommand:lower() or 'help'
    if control.debug then
	print("addon command:", subcommand, arg1, arg2)
    end
    -- start/stop, (諸々ABC順), help の並び
    if subcommand == 'start' then
        start()
    elseif subcommand == 'stop' then
        stop()
    elseif subcommand == 'all' then
	io_chat.notice("ac all ", arg1, arg2, arg3, arg4)
	io_ipc.send_all("all", arg1, arg2, arg3, arg4)
	M.addon_command_handler(arg1, arg2, arg3, arg4)
    elseif subcommand == 'attack' or subcommand == 'att' or subcommand == 'at' then
	local onoff = argument_means_on(arg1)
	if onoff ~= nil then
	    control.attack = onoff
	    io_chat.info("attack mode "..arg1)
	else
	    io_chat.error("Usage: ac attack (on|off)")
	end
    elseif subcommand == 'build' or subcommand == 'b' then
	if arg1 == 'party' or arg1 == 'p'  then
	    io_chat.notice("パーティ作成開始")
	    io_ipc.send_all("build", "party")
	else
	    io_chat.error("Usage: ac build party")
	end
    elseif subcommand == 'calm' then
	local onoff = argument_means_on(arg1)
	if onoff ~= nil then
	    settings.Calm = onoff
	    io_chat.info("ac calm "..arg1)
	else
	    io_chat.error("Usage: ac calm (on|off)")
	end
    elseif subcommand == 'contents' or subcommand == 'cont' then
	if arg1 ~= nil then
	    if not contents.set_contents(arg1) then
		contents.list_contents()
	    end
	end
	contents.show_contents()
    elseif subcommand == 'control' or subcommand == 'cnt' then
	if arg1 == 'automove' then
	    local onoff = argument_means_on(arg2)
	    control.automove = onoff
	    io_chat.info("ac control automove "..tostring(control.automove))
	elseif arg1 == 'debug' then
	    if  arg2 ~= nil then
		local onoff = argument_means_on(arg2)
		control.debug = onoff
		io_chat.info("ac control debug "..tostring(control.debug))
	    else
		io_chat.error("ac control debug {on|off}")
	    end
	elseif arg1 == 'provoke' then
	    if arg2 ~= nil and tonumber(arg2) ~= nil then
		control.provoke = tonumber(arg2)
	    else
		io_chat.error("ac control provoke <hp threshold>")
	    end
	    io_chat.info("ac control provoke", control.provoke)
	elseif arg1 == 'wstp' then
	    control.set_wstp(arg2)
	else
	    io_chat.error("ac control automove | debug | provoke | wstp")
	end
    elseif subcommand == 'debug' then
	if arg1 == 'checkbags' then
	    io_chat.print(acitem.check_inventory_freespace())
	    io_chat.print(acitem.check_bags_freespace())
	elseif arg1 == 'linked' then
	    local mob = windower.ffxi.get_mob_by_target("t")
	    if mob == nil then
		print("no target")
	    else
		print("ac linked => ", is_mob_linked(mob))
	    end
	elseif arg1 == 'nearest' then
	    local prefer_condition = {
		range = control.enemy_range,
		preferMobs = utils.table.merge_lists(acmob.moreAttractiveEnemyList,
						     preferredEnemyList),
		nameMatch = control.enemy_filter,
	    }
	    local preferMob = acmob.search_nearest_mob(pull.base_pos, prefer_condition)
	    local condition = {
		range = control.enemy_range,
		nameMatch = control.enemy_filter,
	    }
	    local mob = acmob.search_nearest_mob(pull.base_pos, condition)
	    io_chat.print("nearest preferMob=====================")
	    io_chat.print(preferMob)
	    io_chat.print("nearest mob =====================")
	    if mob == nil or preferMob == nil or preferMob.name ~= mob.name then
		io_chat.print(mob)
	    else
		io_chat.print("same name monster")
	    end
	else
	    print("ac debug checkbags|linked|nearest")
	end
    elseif subcommand == 'defeated' then
	-- 戦闘終了時の処理
	ac_defeated.done()
    elseif subcommand == 'dothebest' or subcommand == 'do' then
	io_chat.notice("本気出す(do the best)")
	acjob.dothebest(player)
    elseif subcommand == 'dropjunk' then
	io_chat.info("アイテム廃棄開始")
	drop_junk_items_in_inventory()
	io_chat.info("アイテム廃棄終わり")
    elseif subcommand == 'echo' then
	io_chat.info(arg1)
    elseif subcommand == 'enemy' then
	if arg1 == 'filter' then
	    control.enemy_filter = nil
	    if arg2 ~= nil then
		control.enemy_filter = { arg2 }
	    end
	    if arg3 ~= nil then
		control.enemy_filter = {arg2, arg3}
	    end
	    if arg4 ~= nil then
		control.enemy_filter = {arg2, arg3, arg4}
	    end
	    io_chat.info("ac enemy filter", control.enemy_filter)
	elseif arg1 == 'range' then
	    control.enemy_range = tonumber(arg2, 10)
	    io_chat.print("ac enemy range:", control.enemy_range)
	else
	    io_chat.error("ac enemy filter <enemy substring>")
	    io_chat.error("ac enemy range <enemy search range>")
	end
    elseif subcommand == 'enemyspace' or subcommand == 'es' then
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
    elseif subcommand == 'enterloop' then
        control.auto = true
        local i = 0
	local mob = windower.ffxi.get_mob_by_target("t")
        while control.auto do
            print("enter #"..i)
            i = i + 1
            push_keys({"enter"})
            coroutine.sleep(2)
	    io_net.target_by_mob(mob)
	    local m = windower.ffxi.get_mob_by_target("t")
	    if m.id ~= mob.id then
		control.auto = false
	    end
	    coroutine.sleep(1)
        end
    elseif subcommand == 'enterloop2' then
        control.auto = true
        while control.auto do
            print("down & enter")
            push_keys({"down", "enter"})
            coroutine.sleep(3)
        end
    elseif subcommand == 'equip' then
	if arg1 == 'save' then
	    io_chat.info("% equip save")
	    ac_equip.equip_save(arg2)
	elseif arg1 == 'restore' then
	    io_chat.info("% equip restore")
	    ac_equip.equip_restore(arg2)
	elseif arg1 == 'show' then
	    ac_equip.equip_show(arg2)
	else
	    io_chat.error("ac equip (save|restore) [<bank_name>]")
	end
    elseif subcommand == 'finishblow' then
	if control.debug then
	    print("ac finishblow", arg1)
	end
	-- setFinish
    elseif subcommand == 'focus' then
	if control.debug then
	    print("ac focus", arg1)
	end
	if ac_focus.focusMyIndex ~= arg1 then
	    -- index が自分以外なら他にフォーカスを譲る
	    io_ipc.send_all("focus", arg1)
	end
    elseif subcommand == 'garden' or subcommand == 'g' then
	if zone ~= 280 then
	    io_chat.warn("ガーデン以外にいます zone: "..zone)
	    return
	end
	if arg1 == 'return' or arg1 == 'ret' or arg1 == 'r' or -- 元に戻る
	    arg1 == 'west' or arg1 == 'w' or  -- 西アドゥリン
	    arg1 == 'east' or arg1 == 'e' then  -- 東アドゥリン
	    local moogle = windower.ffxi.get_mob_by_name("Green Thumb Moogle")
	    ac_move.run_to_mob(moogle)
	    coroutine.sleep(1)
	    io_net.target_by_mob(moogle)
	    coroutine.sleep(1)
	    utils.target_lockon(true)
	    coroutine.sleep(3)
	    push_keys({"enter"})
	    coroutine.sleep(1)
	    -- 別の場所に移動したい
	    push_keys({"right", "right", "up", "enter"})
	    coroutine.sleep(1)
	    if arg1 == 'return' or arg1 == 'ret' or arg1 == 'r' then
		push_keys({"down", "enter"})          -- 元に戻る
	    elseif arg1 == 'west' or arg1 == 'w' then
		push_keys({"down", "down", "enter"})  -- 西アドゥリン
	    elseif arg1 == 'east' or arg1 == 'e' then
		push_keys({"right", "enter"})         -- 東アドゥリン
	    end
	elseif arg1 == 'flot' or arg1 == 'f' then
	    local flotsam = windower.ffxi.get_mob_by_name("Flotsam")
	    ac_move.run_to_mob(flotsam)
	    coroutine.sleep(1)
	    io_net.target_by_mob(flotsam)
	    coroutine.sleep(2)
	    utils.target_lockon(true)
	    coroutine.sleep(1)
	    push_keys({"enter"})
	    coroutine.sleep(1)
	    push_keys({"enter"})
	else
	    io_chat.errorf("ac garden in|out|flot", zone)
	end
    elseif subcommand == 'house' or subcommand == 'h' then
	if not aczone.in_moghouse(zone, me) then
	    io_chat.warn("モグハウス以外にいます zone: "..zone)
	    return
	end
	if arg1 == 'west' or arg1 == 'w' or  -- 西アドゥリン
	    arg1 == 'east' or arg1 == 'e' or  -- 東アドゥリン
	    arg1 == 'garden' or arg1 == 'g' then  -- モグガーデン
	    push_keys({"escape", "escape", "escape"})
	    local door_pos = {x=-1, y=-7}
	    ac_move.run_to_mob(door_pos)
	    coroutine.sleep(1)
	    ac_move.look_forward()
	    windower.ffxi.run(false)
	    coroutine.sleep(1)
	    push_keys({"enter"})
	    coroutine.sleep(1)
	    push_keys({"enter"})
	    coroutine.sleep(1)
	    push_keys({"up", "enter"})  -- 出るエリアを選択する
	    coroutine.sleep(1)
	    if arg1 == 'west' or arg1 == 'w' then
		push_keys({"enter"})  -- 西アドゥリン
	    elseif arg1 == 'east' or arg1 == 'e' then
		push_keys({"down", "enter"})  -- 東アドゥリン
	    elseif arg1 == 'garden' or arg1 == 'g' then
		push_keys({"up", "enter"})  -- モグガーデン
	    else
		io_chat.error("ac house ???")
	    end
	else
	    io_chat.error("ac house west|east|garden")
	end
    elseif subcommand == 'inject' then
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
    elseif subcommand == 'login' then
	push_keys({"enter"})
	coroutine.sleep(1)
	push_keys({"enter"})
    elseif subcommand == 'logout' then
	io_chat.notice("#### Logout!!!")
	task.set_task_simple("input /logout", 1, 1)
    elseif subcommand == 'magic' or subcommand == 'magick' then
	role_Sorcerer.set_magic(arg1)
    elseif subcommand == 'move' then
	local routeTable = aczone.get_route_table(zone)
	pull.base_pos = nil
        ac_move.auto_move_to(zone, {arg1, arg2}, routeTable)
    elseif subcommand == 'moverev' then
	local routeTable = aczone.get_route_table(zone)
	pull.base_pos = nil
        ac_move.auto_move_to(zone, {"-"..arg1}, routeTable)
    elseif subcommand == 'party' then
	if arg1 == 'start' then
	    start_party()
	elseif arg1 == 'stop' then
	    stop_party()
	else
	    io_ipc.send_party("party", arg1, arg2, arg3, arg4)
	    M.addon_command_handler(arg1, arg2, arg3, arg4)
	end
    elseif subcommand == 'patrol' or subcommand == 'pat' then
	if zone ~= nil and zone ~= 0 then
	    io_chat.errorf("多分、ログイン画面じゃないです zone:%d", zone)
	    return
	end
	-- ログイン
	local n = tonumber(arg1, 10)
	if n == nil or
	    not utils.table.contains({"mailbox", "garden", "m", "mm", "g", "gob"}, arg2) then
	    print("ac patrol <chara number> {all | mailbox | garden | gob} ")
	else
	    for i = 1, n do
		print("Patrol #", i, "/", n)
		push_keys({"enter"})
		coroutine.sleep(1)
		push_keys({"enter"})
		coroutine.sleep(19)
		if arg2 == "mailbox" or arg2 == "m" or arg2 == "mm" then
		    command.send('input /mailbox')  -- 宅配ポストを開ける
		    coroutine.sleep(4)
		    if arg2 == "mm" then
			for i = 1, 8 do
			    push_keys({"enter", "enter"})
			    coroutine.sleep(0.5)
			    push_keys({"right"})
			    coroutine.sleep(0.5)
			    if i == 4 then
				push_keys({"left", "left", "left", "down"})
				coroutine.sleep(1)
			    end
			end
		    end
		    coroutine.sleep(1)
		    ---
		    push_keys({"escape"})
		elseif arg2 == "garden" or arg2 == "g" then  -- 栽培
		    command.send('input /garden')  -- 宅配ポストを開ける
		    coroutine.sleep(5)
		    push_keys({"enter"})
		    coroutine.sleep(3)
		    push_keys({"enter"})
		    coroutine.sleep(2)
		    push_keys({"enter"})
		    coroutine.sleep(1)
		    push_keys({"escape"})
		    coroutine.sleep(1)
		    push_keys({"escape"})
		elseif arg2 == "gob" then  -- ゴブの不思議箱
		    windower.ffxi.turn(3.14/2)  -- ドアの方を向く
		    turn_to_front()
		    io_net.target_by_mob_name("Door:Back to Town")
		    coroutine.sleep(1)
		    push_keys({"enter", "enter"})
		    coroutine.sleep(1)
		    -- 出るエリアを選択するに合わせる
		    push_keys({"down", "down", "down", "enter"})
		    -- coroutine.sleep(1)
		    push_keys({"down", "enter"})  -- 東アドゥリンを選択
		    coroutine.sleep(8)
		    command.send("ac move gob")
		    coroutine.sleep(40)
		    print("after sleep 50")
		else
		    print("internal error: ac patrol <chara number> {mailbox|garden|gob} ")
		    break
		end
		coroutine.sleep(2)
		command.send('input /logout')
		coroutine.sleep(5)
		push_keys({"down"})
	    end
	    for i = 1, n do
		push_keys({"up"})
	    end
	end
    elseif subcommand == 'point' then
        control.point_cheer = not control.point_cheer
        io_chat.print({"do point&cheer for ambus", control.point_cheer})
    elseif subcommand == 'pos' then  -- よく使うので ac 直下のまま
        io_chat.print("zone id:"..zone)
        local x = math.round(me.x, 1)
        local y = math.round(me.y, 1)
        local z = math.round(me.z, 1)
---    print は - 記号を誤認しやすいので、表示しない
---        print("me position", " x="..x, "  y="..y, "  z="..z)
        io_chat.print("me position  x="..x.."  y="..y.."  z="..z)
    elseif subcommand == 'puller' then
	local onoff = argument_means_on(arg1)
	if onoff ~= nil then
            control.puller = onoff
            io_chat.info("ac puller "..arg1)
        else
            io_chat.error("Usage: ac puller (on|off)")
        end
    elseif subcommand == 'record' or subcommand == 'rec' then
	if arg1 == 'char' then
	    io_chat.info("ac record char")
	    ac_record.record_char()
	elseif arg1 == 'spells' then
	    io_chat.info("ac record spells")
	    ac_record.record_spells()
	end
    elseif subcommand == 'reload' then
	io_chat.notice("ac reload (myself)")
	task.set_task_simple("lua u AC; wait 1; lua l AC", 0, 1)
    elseif subcommand == 'roundtrip' then
	local n = tonumber(arg1, 10)
	control.auto = true
	while control.auto do
	    keyboard.longpush_key("s", 3.0)  -- 後ろに下がる
	    coroutine.sleep(n)
	end
    elseif subcommand == 'show' then
	if arg1 == 'auto' then
	    io_chat.notice("ac show auto")
	    io_chat.info("control.auto", control.auto)
	    io_chat.info("ac/move.auto", ac_move.auto)
	    io_chat.info("ac/works survey.auto, boost.auto:",
			 works.survey.auto, works.boost.auto)
	elseif arg1 == 'char' then
	    ac_char.print()
	elseif arg1 == 'chatcolor' then
	    for i, desc in ipairs({"白", "赤紫", "オレンジ", "ピンク","水色", "エメラルド","紫", "明赤紫", "白", "肌色"}) do
		io_chat.set_next_color(i)
		io_chat.printf("Color:%d => %s", i, desc)
	    end
	elseif arg1 == 'control' then
	    control.show()
	elseif arg1 == 'inventory' then
	    acitem.show_inventory()
	elseif arg1 == 'listener' then
	    incoming_text.show_listener()
	    acevent.show_listener()
	elseif arg1 == 'mob' then
	    show_mob()
	elseif arg1 == 'party' then
	    ac_party.show_party_members()
	elseif arg1 == 'stat' then
	    ac_stat.print()
	elseif arg1 == 'task' then
	    task.print()
	else
	    io_chat.print("ac show { char | chatcolor | control | inventory | listener | mob | party | stat | task }")
	end
    elseif subcommand == 'shutdown' then
	io_chat.notice("#### Shutdown!!!")
	task.set_task_simple("input /shutdown", 1, 1)
    elseif subcommand == 'test' then
        print("test command")
        acmob.PartyTargetMob()
    elseif subcommand == 'tick' then
	local period = tonumber(arg1, 10)
	if period ~= nil and 0.1 < period and period < 10 then
	    control.period = period
	else
	    print("ac tick <period> illegal:", arg1)
	end
    elseif subcommand == 'timer' then
	local start = os.time()
	local period = tonumber(arg1, 10)
	if period == nil then
	    io_chat.error("ac timer <period>", arg1)
	else
	    io_chat.info("<<< timer start >>>", period)
	    local prev = period + 1
	    while (os.time() - start) <=  period do
		local elapse = os.time() - start -- 経過時間
		local remain = period - elapse
		local th = 0
		if remain < 5 then -- 毎秒
		    th = remain
		elseif remain < 30 then -- 5秒毎
		    th = remain - remain % 5
		elseif remain < 60 then -- 10秒毎
		    th = remain - remain % 10
		else -- 30秒分ごと
		    th = remain - remain % 30
		end
		-- print("th remain", th, remain)
		if th == remain then
		    io_chat.printf("=== Timer 残り %d/%d ===", remain, period)
		end
		coroutine.sleep(1)
	    end
	    io_chat.info(">>> Time End <<<", period)
	end
    elseif subcommand == 'toward' or subcommand == 'to' then
	local name_abbreviation_map = { -- 省略形
	    geo = "Geomantic Reservoir",
	    coffer = "Treasure Coffer",
	    airele = "Air Elemental",
	    darkele = "Dark Elemental",
	    faf = "Fafnir",
	    -- chest = "Treasure Chest",
	}
	local mob_name = name_abbreviation_map[arg1]
	if mob_name == nil then
	    mob_name = arg1
	end
	local mob = windower.ffxi.get_mob_by_name(mob_name)
	control.auto = true
	pull.base_pos = nil
	local counter = 0
	while control.auto and mob == nil do
	    if counter == 0 then
		io_chat.errorf("not found mob name:%s", mob_name)
		counter = counter + 1
	    else
		counter = counter + 1
		if counter > 10 then counter = 0 end
	    end
	    coroutine.sleep(1)
	    mob = windower.ffxi.get_mob_by_name(mob_name)
	end
	if mob ~= nil then
	    io_chat.noticef("found mob name:%s", mob_name)
	    ac_move.run_to_mob(mob)
	else
	    io_chat.errorf("give up found mob name:%s", mob_name)
	end
    elseif subcommand == 'use' then
	if arg1 == 'silt' then
	    useSilt = not useSilt
	    io_chat.info("item silt using start", useSilt)
	elseif arg1 == 'beads' then
	    useBeads = not useBeads
	    io_chat.info("item beads using start", useBeads)
	elseif arg1 == 'faith' then
	    useFaith = not useFaith
	    io_chat.info("item faith using start", useFaith)
	elseif arg1 == 'moolah' then
	    -- モグのおひねり
	    local slot_ammo = 3
	    local moolah_item_list = {
		{id=18469, name="モグのおいわい"},
		{id=19181, name="モグのおだちん"},
		{id=19246, name="モグのへそくり"},
		{id=19776, name="モグのおひねり"},
		{id=21369, name="モグのたなぼた"},
		{id=21370, name="ゴブのたなぼた"},
	    }
	    io_chat.notice("ac moolah # start")
	    acitem.use_equip_item_sequence(slot_ammo, moolah_item_list, 11)
	    io_chat.notice("ac moolah # end")
	elseif arg1 == 'dec' then
	    io_chat.print("【包】使用開始")
	    coroutine.sleep(0.5)
	    for i,id in ipairs(item_data.decItems) do
		local c = acitem.inventory_count_by_item_id(id)
		for i = 1, c do
		    acitem.use_item_include_bags(id)
		    coroutine.sleep(3)  -- 2 だと NG
		end
	    end
	    io_chat.print("【包】使用終わり")
	elseif arg1 == 'insne' then
	    io_chat.notice("アイテムでインス二開始")
	    local insne_items = {
		[4165] = "サイレントオイル",
		[4164] = "プリズムパウダー",
	    }
	    for item_id, item_name in pairs(insne_items) do
		if not acitem.inventory_has_item(item_id) then
		    local count = acitem.bags_to_inventory(item_id)
		    if count < 1 then
			io_chat.error("アイテムがバッグに見つかりません:"..item_name)
			return
		    else
			io_chat.info("アイテムをバックに移動:"..item_name)
		    end
		    coroutine.sleep(1)
		end
	    end
	    for _, item_name in pairs(insne_items) do
		windower.ffxi.run(false)
		local c = 'input /item '..item_name..' <me>'
		command.send(c)
		coroutine.sleep(3)
	    end
	elseif arg1 == 'scroll' then
	    io_chat.print("スクロール学習開始")
	    coroutine.sleep(0.5)
	    for i,id in ipairs(item_data.magicScrolls) do
		acitem.use_item_include_bags(id)
	    end
	    io_chat.print("スクロール学習終わり")
	elseif arg1 == 'soulstonesack' then
	    io_chat.notice("石の袋開き開始")
	    control.auto = true
	    while control.auto and
		acitem.inventory_has_item_in_set(item_data.soulStoneSackIdSet) do
		for i,id in ipairs(item_data.soulStoneSacks) do
		    if not acitem.check_bags_freespace() then
			io_chat.info("アイテム満杯")
			break
		    end
		    acitem.use_item_include_bags(id)
		end
	    end
	    io_chat.notice("石の袋開き終わり")
	else
	    io_chat.error("ac use { silt | beads | moolah | dec | scroll | soulstonesack}")
	end
    elseif subcommand == 'warp' or
	subcommand == 'dim' or subcommand == 'holla' or subcommand == 'mea' then
	M.warp_with_equip(subcommand, 10)
    elseif subcommand == 'ws' then
        change_ws(arg1)
    elseif subcommand == 'wstp' then
	control.set_wstp(arg1)
    elseif subcommand == 'help' then
        io_chat.print('AC (AccountCluster)  v' .. _addon.version .. 'subcommands:')
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
	io_chat.print('    record char|spells - Record Status to LogFile')
	io_chat.print('    reload             - Reload AC process')
	io_chat.print('    roundtrip <period> - RoundTrip zone')
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
        io_chat.error("See ac help!!!")
    end
end

windower.register_event('load', function()
    local player = windower.ffxi.get_player()
    if player ~= nil then
	ac_focus.load(player)
    end
    ws.init()
    local zone = windower.ffxi.get_info().zone
    zone_change.zone_in_handler(zone, nil)
    -- command, delay, duration
    task.set_task_simple("ac inject currinfo1", 2, 1)
    task.set_task_simple("ac inject currinfo2", 4, 1)
    task.set_task_simple("//record char", 6, 1)
    local incoming_text_handler = function(text)
	if not control.auto then
	    return
	end
	if string.contains(text, "コマンドが実行できない") and
	    control.enemy_space == control.ENEMY_SPACE_NEAR then
	    if string.contains(text, "近づかないとコマンドが") or
		string.contains(text, "遠くにいるため、コマンドが")then
		if control.debug then
		    io_chat.info("前に詰める")
		end
		keyboard.longpush_key("w", 3.0)  -- 前に詰める
		push_keys({"a"})  -- 少し左にずらす
	    elseif string.contains(text, "姿が見えないためコマンドが") then
		if control.debug then
		    io_chat.info("左>後>前に移動")
		end
		push_keys({"a", "s", "w"})  -- 左>後>前に移動
	    end
	elseif string.contains(text, "の詠唱は中断された") then
	    if control.debug then
		 io_chat.warn("詠唱の中断を検知")
	    end
	elseif string.contains(text, "魔法を唱えることができない") then
	    if control.debug then
		io_chat.warn("魔法 詠唱の失敗を検知")
	    end
	elseif string.contains(text, "の命のカウントダウン") then
	    command.send('input /item 聖水 <me> ; wait 1 ; input /item 聖水 <me>')
	elseif string.contains(text, "ターゲット選択中は使用できません。") then
	    push_keys({"escape"})  -- ターゲットを外す
	end
    end
    incoming_text.add_listener("", incoming_text_handler)
    -- 全ての準備が整ってから tick 起動
    tick:loop(control.period)
end)

windower.register_event('login', function()
    -- ws.init()  -- このタイミングだと前のキャラのジョブが反映される
    ac_stat.init()
    ac_focus.login()
end)

windower.register_event('logout', function()
    -- command, delay, duration
    task.set_task_simple("//record char", 0, 1)
end)

windower.register_event('job change', function()
    ws.init()
    ac_stat.init()
    -- command, delay, duration
    task.set_task_simple("ac inject currinfo1", 2, 1)
    task.set_task_simple("ac inject currinfo2", 3, 1)
    task.set_task_simple("//record char", 6, 1)
end)

windower.register_event('status change', function(new, old)
    local acstatus = require 'status'
    -- command, delay, duration
    acstatus.status_change_handler(new, old)
end)

--- ゾーンが変わったらリーダーだけ停止する
windower.register_event('zone change', function(zone, prevZone)
    ac_record.record_char()
    ac_record.record_spells()
    ac_stat.init()
    task.init()
    if iam_leader() then
	control.auto = false
    end
    ac_move.auto = false
    useSilt = false
    useBeads = false
    control.point_cheer = false
    if zone == prevZone then
	-- ログイン直後は zone ==  prevZone なので細工する
	prevZone = nil
    end
    zone_change.zone_change_handler(zone, prevZone)
    ws.init()
    -- command, delay, duration
    task.set_task_simple("ac inject currinfo1", 2, 1)
    task.set_task_simple("ac inject currinfo2", 4, 1)
    task.set_task_simple("//record char", 6, 1)
    control.enemy_filter = control.INIT_VALUES.enemy_filter
    control.enemy_range = control.INIT_VALUES.enemy_range
    control.puller = control.INIT_VALUES.puller
    control.wstp = control.INIT_VALUES.wstp
    pull.base_pos = nil
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

windower.register_event('gain experience', function(amount, chain_number, limit)
    ac_record.record_char()
    ac_record.record_spells()
end)

windower.register_event('level up', function(level)
    ac_record.record_char()
    ac_record.record_spells()
end)

--[[
windower.register_event('pipe message', function(message)
    io_chat.notice(message)
end)
]]

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
