-- 錬成

local M = {}

local control = require 'control'
local acitem = require 'item'
local utils = require 'utils'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local io_chat = require 'io/chat'
local io_net = require 'io/net'
local incoming_text = require('incoming/text')

local last_time = nil

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

function forward()
    pushKeys({"w", "w", "w", "s", "s", "s"})  -- 前に詰める
end

function setup(mob)
    target_and_lockon(mob)
    forward()
    pushKeys({"enter"})  -- 前に詰めて改行
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
    pushKeys({"left", "left"}) -- 初期位置
    pushKeys({"down", "enter"}) -- 圧力ハンドル調整
    coroutine.sleep(2)
    if M.explosion == true then	return end
    io_chat.info("操作する＞安全レバー")
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"down", "enter"}) -- 安全レバー
    coroutine.sleep(2)
    if M.explosion == true then	return end
    io_chat.info("操作する＞結界メンテナンス")
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"down", "enter"}) -- 結界メンテナンス
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
    coroutine.sleep(1)
    io_chat.info("取り出す")
    pushKeys({"enter"})  -- 取り出す
    coroutine.sleep(2)
end

function SynergyFurnaceFunction(zone, mob)
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
    io_chat.info("風クリ投入")
    add(mob, 2) -- 風クリ投入
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    operate(mob)
    if M.synergy_finish then return end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    -- 雷クリ投入
    io_chat.info("雷クリ投入")
    add(mob, 4)
    if M.synergy_finish then return end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    operate(mob)
    if M.synergy_finish then return end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    -- 闇クリ投入
    io_chat.info("闇クリ投入")
    add(mob, 7)
    if M.synergy_finish then return end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    operate(mob)
    add(mob, 7)
    if M.synergy_finish then return end
    if M.explosion == true then
	coroutine.sleep(10)
	start(mob)
	M.explosion = false
    end
    coroutine.sleep(2)
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

function SynergyEngineerFunction(zone, mob)
    last_time = nil
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

M.npcActionHandlers = {
    ["Synergy Furnace"] = SynergyFurnaceFunction,
    ["Synergy Engineer"] = SynergyEngineerFunction,
}

function M.incoming_text_handler(text)
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
	item_table = {  -- インカンタートルク
	    [26012] = 1, -- メリックトルク
	    [26013] = 1, -- "ヘニックトルク
	    [26014] = 1, -- デシーバートルク
	}
	acitem.tradeByItemTable(M.mob_Furnace, item_table)
	coroutine.sleep(1)
	io_chat.info("完成品を提示")
	pushKeys({"enter"})  -- 完成品を提示。改行キー
    end
end

M.listener_id = incoming_text.addListener("", M.incoming_text_handler)

function M.zone_in()
    M.init()
end

function M.zone_out()
    M.init()
end

return M
