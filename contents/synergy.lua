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

function M.tick(player)
    --
end

-- コマンド実行：無し。を前提にする。

function setup(mob)
    pushKeys({"w", "w", "w", "s", "enter"})  -- 前に詰めて改行
    coroutine.sleep(1)
    item_table = {  -- インカンタートルク
	[26012] = 1, -- メリックトルク
	[26013] = 1, -- "ヘニックトルク
	[26014] = 1, -- デシーバートルク
    }
    acitem.tradeByItemTable(mob, item_table)
    coroutine.sleep(1)
    io_chat.info("完成品を提示")
    pushKeys({"enter"})  -- 完成品を提示。改行キー
    coroutine.sleep(1) -- ???
    io_chat.info("錬成を開始する")
    pushKeys({"enter"})  -- 錬成を開始する。改行キー
    coroutine.sleep(4)
end

function start(mob)
    io_net.targetByMob(mob)
    coroutine.sleep(1)
    utils.target_lockon(true)
    coroutine.sleep(1)
    pushKeys({"w", "w", "w", "s", "enter"})  -- 前に詰めて改行
    io_chat.info("錬成メニューを開く")
    pushKeys({"enter"})  -- 錬成メニューを開く (時間かかる)
    coroutine.sleep(3)
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
    io_chat.info("操作する＞安全レバー")
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"down", "enter"}) -- 安全レバー
    coroutine.sleep(2)
    io_chat.info("操作する＞結界メンテナンス")
    pushKeys({"enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"down", "enter"}) -- 結界メンテナンス
    coroutine.sleep(2)
end

function SynergyFurnaceFunction(zone, mob)
    control.auto = false
    utils.target_lockon(true)
    setup(mob)
    start(mob)
    io_chat.info("風クリ投入")
    add(mob, 2) -- 風クリ投入
    if M.explosion == true then
	start(mob)
	M.explosion = false
    end
    operate(mob)
    if M.explosion == true then
	start(mob)
	M.explosion = false
    end
    -- 雷クリ投入
    io_chat.info("雷クリ投入")
    add(mob, 4)
    if M.explosion == true then
	start(mob)
	M.explosion = false
    end
    operate(mob)
    if M.explosion == true then
	start(mob)
	M.explosion = false
    end
    -- 終了
    io_chat.info("終了")
    pushKeys({"down", "down", "down", "enter"})  --  錬成を終了(完成)
    coroutine.sleep(5)
    io_net.targetByMob(mob)
    coroutine.sleep(1)
    utils.target_lockon(true)
    coroutine.sleep(1)
    pushKeys({"w", "w", "w", "enter"})  -- 前に詰めて改行
    coroutine.sleep(1)
    io_chat.info("取り出す")
    pushKeys({"enter"})  -- 取り出す
end

function SynergyEngineerFunction()
    utils.target_lockon(true)
    pushKeys({"enter"})
    coroutine.sleep(2)
    pushKeys({"right", "enter"}) -- 右を押して燃料満タンに合わせる
    coroutine.sleep(2)
    pushKeys({"up", "enter"})  -- 上を選択
    coroutine.sleep(3)
end

M.npcActionHandlers = {
    ["Synergy Furnace"] = SynergyFurnaceFunction,
    ["Synergy Engineer"] = SynergyEngineerFunction,
}

M.explosion = false
M.synergy_finish = false
function M.incoming_text_handler(text)
    if string.contains(text, "ダメージ。") then
	M.explosion = true
    elseif string.contains(text, "錬成プロセスを完了！") then
	M.synergy_finish = true
    end
end

M.listener_id = incoming_text.addListener("", M.incoming_text_handler)

return M
