-- 錬成

local M = {}

local control = require 'control'
local utils = require 'utils'
local acitem = require 'item'
local io_chat = require 'io/chat'
local io_net = require 'io/net'
local incoming_text = require('incoming/text')

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local longpushKey = keyboard.longpushKey

local last_time = nil

M.item_table = {  -- インカンタートルク
    [26012] = 1, -- メリックトルク
    [26013] = 1, -- "ヘニックトルク
    [26014] = 1, -- デシーバートルク
}

M.PHASE_None = 0
M.PHASE_Furnace = 1
M.PHASE_Engineer = 2

function M.init()
    M.mob_Furnace = nil
    M.mob_Engineer = nil
    M.phase = M.PHASE_None
    M.FurnaceExplosion = false
    M.FurnaceDone = false
end
M.init()

function M.tick(player)
end

-- コマンド実行：無し。を前提にする。

function target_and_lockon(mob)
    io_net.targetByMobEx(mob)
    coroutine.sleep(1)
    utils.target_lockon(true)
    coroutine.sleep(1)
end

function forward()
    longpushKey("w", 1)  -- 前に詰める
    longpushKey("s", 0.2)  -- 後に下がる
end

local Furnace_setup = {
    {target_and_lockon=true},
    {info="錬成の準備"},
    {forward=1}, {backward=0.2}, -- 近づく
    {keylong={"enter", 1}}, -- 実行
    {wait=2},
}

local Furnace_start = {
    {target_and_lockon=true},
    {info="錬成 Start"},
    {forward=1}, {backward=0.2}, -- 近づく
    {keylong={"enter", 1}}, -- 実行
}

local Furnace_wind = {
    {target_and_lockon=true},
    {forward=1}, {backward=0.2}, -- 近づく
    {info="風クリ追加", add="wind"},
    {keys={"left", "left", "left"}}, -- 選択位置リセット
    {keylong={"enter", 1}}, -- 燃料追加
    {keys={"left", "left", "left"}}, -- 選択位置リセット
    {wait=1},
}

local Furnace_operate = {
    {target_and_lockon=true},
    {forward=1}, {backward=0.2}, -- 近づく
    {info="風クリ追加", add="wind"},
    {keys={"left", "left", "left"}}, -- 選択位置リセット
    {keys={"down", "enter"}}, -- 操作
    {keys={"left", "left", "left"}}, -- 選択位置リセット
    {keys={"down", "down", "enter"}}, -- ？？？
    {wait=2},
}

local Furnace_finish = {
    {target_and_lockon=true},
    {forward=1}, {backward=0.2}, -- 近づく
    {info="錬成を完了"},
    {keys={"left", "left", "left"}}, -- 選択位置リセット
    {keys={"right", "enter"}} -- 錬成を完了
}

local Furnace_sequence = {
    Furnace_setup,
    Furnace_start,
    Furnace_wind,
    Furnace_operate,
    -- Furnace_finish,
}

function M.incoming_text_handler(text)
    if not control.auto then return end -- auto 時だけ処理
    if string.contains(text, "素材を投入して錬成窯を稼働してください。") then
	io_chat.info("錬成トレード")
	acitem.tradeByItemTable(M.mob_Furnace, M.item_table)
	io_chat.info("トレード終わり。3秒待つ")
	coroutine.sleep(2)  --  2でもフライングする事がある？
	io_chat.info("完成品を提示")
	pushKeys({"enter"})  -- 完成品を提示。改行キー
	io_chat.info("enter 押した。3秒待つ")
	coroutine.sleep(2)
	pushKeys({"enter"})  -- はい
	io_chat.info("enter 押した。終わり")
    elseif string.contains(text, "属性力が爆発") then
	M.FurnaceExplosion = true
    elseif string.contains(text, "目的のアイテムはできなかった") then
	if M.mob_Furnace ~= nil then
	    target_and_lockon(M.mob_Furnace)
	end
	pushKeys({"enter"})  -- アイテムを取り出す
	M.FurnaceDone = true
    end
end

function M.action(mob, a)
    -- 表示
    if a.info ~= nil then
	io_chat.info(a.info)
    end
    -- 移動
    if a.forward ~= nil then
	longpushKey("w", tonumber(a.forward))
    end
    if a.backward ~= nil then
	longpushKey("s", tonumber(a.backward))
    end
    if a.trade ~= nil then
	acitem.tradeByItemTable(mob, a.trade)
	coroutine.sleep(1)
    end
    -- キーボード
    if a.keys ~= nil then
	pushKeys(a.keys)
    end
    if a.keylong ~= nil then
	-- print(a.keylong[1],a.keylong[2])
	longpushKey(a.keylong[1],a.keylong[2])
    end
    -- その他
    if a.target_and_lockon then
	target_and_lockon(mob)
    end	
    if a.wait ~= nil then
	coroutine.sleep(a.wait)
    end
end

-- 錬成のスキル上げ
function SynergyFurnaceFunction(zone, mob)
    if not control.auto then return end -- auto 時だけ処理
    M.mob_Furnace = mob
    if M.phase == M.PHASE_Engineer then
	io_chat.warn("Engineer phase now")
	utils.target_lockon(false)
	coroutine.sleep(5)
	return
    end
    io_chat.notice("<<<< 錬成 Start >>>>")
    M.FurnaceExplosion = false
    M.FurnaceDone = false
    -- メリックトルク(26012)を持っていない場合は、窯に置きっぱなしのはず
    if not acitem.inventoryHasItem(26012) then
	pushKeys({"enter"})  -- アイテムを窯から取り出す
	coroutine.sleep(1)
    end
    for _, actions in ipairs(Furnace_sequence) do
	for _, a in ipairs(actions) do
	    if M.FurnaceExplosion then
		io_chat.notice("爆発したので少し待機")
		coroutine.sleep(10)
		target_and_lockon(mob)
		forward()
		M.FurnaceExplosion = false
	    end
	    if M.FurnaceDone then
		break
	    else
		M.action(mob, a)
	    end
	end
	if M.FurnaceDone then
	    io_chat.notice("==== M.FurnaceDone ====")
	    break
	end
    end
    io_chat.notice(">>>> 錬成 End <<<<")
    for _, a in ipairs(Furnace_finish) do
	M.action(mob, a)
    end
    M.phase = M.PHASE_Engineer
    utils.target_lockon(false)
    coroutine.sleep(1)
    if M.mob_Engineer ~= nil then
	-- target_and_lockon(M.mob_Engineer)
    end
end

-- 燃料をマンタンにする
function SynergyEngineerFunction(zone, mob)
    if not control.auto then return end -- auto 時だけ処理
    M.mob_Engineer = mob
    if M.phase == M.PHASE_Furnace then
	io_chat.warn("Furnace phase now")
	utils.target_lockon(false)
	coroutine.sleep(5)
	return
    end
    io_chat.notice("<<<< 補給 Start >>>>")
    -- 処理
    io_chat.notice(">>>> 補給 End <<<<")
    M.phase = M.PHASE_Furnace
    utils.target_lockon(false)
    coroutine.sleep(1)
    if M.mob_Furnace ~= nil then
	target_and_lockon(M.mob_Furnace)
    end
end

function M.zone_in()
    M.init()
end

function M.zone_out()
    M.init()
end

--
-- 古いコード、参考のため一時的に残す
--

function M.init()
    M.mob_Furnace = nil
    M.mob_Engineer = nil
    M.explosion = false
    M.synergy_finish = false
    M.engineer_retry = false
end
M.init()

function M.tick(player)
    if not control.auto or last_time == nil then
	last_time = nil
    else
	if (last_time + 60) < os.time() then
	    if M.mob_Furnace ~= nil then
		target_and_lockon(M.mob_Furnace)
		coroutine.sleep(1)
	    end
	    last_time = os.time()
	end
    end
end

-- コマンド実行：無し。を前提にする。

function target_and_lockon(mob)
    io_net.targetByMobEx(mob)
    coroutine.sleep(1)
    utils.target_lockon(true)
    coroutine.sleep(1)
end

function setup(mob)
    target_and_lockon(mob)
    forward()
    -- メリックトルク(26012)
    if not acitem.inventoryHasItem(26012) then
	pushKeys({"enter"})  -- アイテムを取り出す
	coroutine.sleep(1)
    end
    pushKeys({"enter"})  -- 改行で開始
    coroutine.sleep(1)
    --[[
    item_table = {  -- インカンタートルク
	[26012] = 1, -- メリックトルク
	[26013] = 1, -- "ヘニックトルク
	[26014] = 1, -- デシーバートルク
    }
    acitem.tradeByItemTable(mob, item_table)
    coroutine.sleep(1)
    io_chat.info("完成品を提示")
    pushKeys({"enter"})  -- 完成品を提示。改行キー
    ]]
    coroutine.sleep(2)  -- 1 だとたまにフライングする
    io_chat.info("錬成を開始する")
    pushKeys({"enter"})  -- 錬成を開始する。改行キー
    coroutine.sleep(4)
end

local key_sequence = {
    {  -- start
	{echo="start"},
	{keys={"w","w","w","s",}},
    },
    {
    },
    {
    },
    {
    },
}

function start(mob)
    target_and_lockon(mob)
    forward()
    pushKeys({"enter"})  -- 前に詰めて改行
    io_chat.info("錬成メニューを開く")
    pushKeys({"enter"})  -- 錬成メニューを開く (時間かかる)
    coroutine.sleep(4)
end

function add(mob, downCount)
    -- クリスタル燃料投入
    pushKeys({"left"})  -- 初期位置
    pushKeys({"enter"})  -- 燃料を投入する
    coroutine.sleep(1)
    pushKeys({"left", "left", "left"}) -- 一番上に
    for i = 1, downCount do
	pushKeys({"down"}) -- 属性を選択
    end
    pushKeys({"enter"})  -- 選択
    coroutine.sleep(2)
end

function operate(mob) -- 操作する
    io_chat.info("操作する＞圧力ハンドル")
    pushKeys({"left"})  -- 初期位置
    pushKeys({"down", "enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"left", "left"}) -- 初期位置
    pushKeys({"down", "enter"}) -- 圧力ハンドル調整
    coroutine.sleep(3)
    if M.explosion == true then	return end
    io_chat.info("操作する＞安全レバー")
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    io_chat.info("安全レバー")
    pushKeys({"down", "enter"}) -- 安全レバー
    coroutine.sleep(3)
    if M.explosion == true then	return end
    io_chat.info("操作する＞結界メンテナンス")
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"down", "enter"}) -- 結界メンテナンス
    coroutine.sleep(2)
    if M.explosion == true then	return end
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"enter"}) -- もう一度、結界メンテナンス
    coroutine.sleep(2)
end

function finish(mob)
    io_chat.info("終了")
    pushKeys({"left", "left"}) -- 初期位置
    pushKeys({"down", "down", "down", "enter"})  --  錬成を終了(完成)
    coroutine.sleep(5)
    io_net.targetByMob(mob)
    coroutine.sleep(1)
    utils.target_lockon(true)
    coroutine.sleep(1)
    -- pushKeys({"w", "w", "w", "enter"})  -- 前に詰めて改行
    coroutine.sleep(2)
    io_chat.info("取り出す")
    pushKeys({"enter"})  -- 取り出す
    coroutine.sleep(2)
end

function common(mob, downCount)
    add(mob, downCount)
    if M.synergy_finish then return end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    operate(mob)
    if M.synergy_finish then return false end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    return true
end

function wind(mob)
    io_chat.info("風クリ投入")
    return common(mob, 2)
end
function thunder(mob)
    io_chat.info("雷クリ投入")
    return common(mob, 4)
end
function dark(mob)
    io_chat.info("闇クリ投入")
    return common(mob, 7)
end

function SynergyFurnaceFunction_old(zone, mob)
    if not control.auto then
	return
    end
    if mob == nil then
	return
    end
    last_time = nil
    if M.mob_Furnace ~= nil then
	if mob.index ~= M.mob_Furnace.index then
	    utils.target_lockon(false)
	    return
	end
    end
    M.mob_Furnace = mob
    M.synergy_finish = false
    setup(mob)
    start(mob)
    --if not dark(mob) then return end    -- 闇クリ投入
    if not wind(mob) then return end    -- 風クリ投入
    if not thunder(mob) then return end -- 雷クリ投入
    --if not dark(mob) then return end    -- 闇クリ投入
    --coroutine.sleep(2)
    -- 終了
    finish(mob)
    utils.target_lockon(false)
    coroutine.sleep(1)
    if M.mob_Engineer ~= nil then
	pushKeys({"s", "s", "s"})  -- 後ろに下がる
	pushKeys({"tab"})
	target_and_lockon(M.mob_Engineer)
	coroutine.sleep(1)
    else
	control.auto = false
    end
    last_time = os.time()
end

function SynergyEngineerFunction_old(zone, mob)
    if not control.auto then
	return
    end
    if M.mob_Engineer ~= nil then
	if mob.index ~= M.mob_Engineer.index then
	    utils.target_lockon(false)
	    return 
	end
    end
    M.mob_Engineer = mob
    utils.target_lockon(true)
    forward()
    pushKeys({"enter"})  -- 前に詰めて改行
    coroutine.sleep(2)
    pushKeys({"right"}) -- 右を押して燃料満タンに合わせる
    coroutine.sleep(0.5)
    pushKeys({"enter"}) -- 燃料満タンを選択
    coroutine.sleep(2)
    pushKeys({"up"})  -- 上の「はい」を選択
    coroutine.sleep(1)
    pushKeys({"enter"})  -- 上の「はい」を実行
    coroutine.sleep(3)
    utils.target_lockon(false)
    coroutine.sleep(1)
    if M.engineer_retry then return end
    if M.mob_Furnace ~= nil then
	pushKeys({"s", "s", "s"})  -- 後ろに下がる
--	pushKeys({"tab"})
	target_and_lockon(M.mob_Furnace)
	coroutine.sleep(1)
    else
	control.auto = false
    end
    last_time = os.time()
end

function M.incoming_text_handler_old(text)
    if string.contains(text, "ダメージ。") then
	M.explosion = true
    elseif string.contains(text, "錬成プロセスを完了！") then
	M.synergy_finish = true
    elseif string.contains(text, "錬成中のようですね！") then
	M.engineer_retry = true
    elseif string.contains(text, "燃料をマンタンにしました。") then
	M.engineer_retry = false
    elseif string.contains(text, "錬成窯を占有中です。") then
	M.synergy_finish = true
	coroutine.sleep(1)
	pushKeys({"enter"})  --  占有解除。
	coroutine.sleep(1)
	pushKeys({"up", "enter"})  -- 上の「はい」を選択
	coroutine.sleep(1)
    elseif string.contains(text, "錬成窯の占有が解除されました") then
	M.synergy_finish = false
    elseif string.contains(text, "目的のアイテムはできなかった") then
	if M.mob_Furnace ~= nil then
	    coroutine.sleep(4)
	    target_and_lockon(M.mob_Furnace)
	    pushKeys({"enter"})  --  アイテム取り出し
	end
    elseif string.contains(text, "占有権が失われました") then
	pushKeys({"enter"})  --  アイテム取り出し
	coroutine.sleep(1)
    elseif string.contains(text, "素材を投入して錬成窯を稼働してください。") then
	io_chat.info("錬成トレード")
	acitem.tradeByItemTable(M.mob_Furnace, M.item_table)
	coroutine.sleep(3)  --  2でもフライングする事がある？
	io_chat.info("完成品を提示")
	pushKeys({"enter"})  -- 完成品を提示。改行キー
    end
end

--- 切り替え

M.npcActionHandlers = {
--    ["Synergy Furnace"] = SynergyFurnaceFunction,
--    ["Synergy Engineer"] = SynergyEngineerFunction,
    ["Synergy Furnace"] = SynergyFurnaceFunction_old,
    ["Synergy Engineer"] = SynergyEngineerFunction_old,
}

-- M.listener_id = incoming_text.addListener("", M.incoming_text_handler)
M.listener_id = incoming_text.addListener("", M.incoming_text_handler_old)


return M
