-- 錬成

local M = {}

local control = require 'control'
local acitem = require 'item'
local utils = require 'utils'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys
local io_chat = require 'io/chat'
local io_net = require 'io/net'

function M.tick(player)
    --
end

function SynergyFurnaceFunction(zone, mob)
    control.auto = false
    utils.target_lockon(true)
    pushKeys({"w", "w", "w", "enter"})  -- 前に詰めて改行
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
    coroutine.sleep(2)
    io_chat.info("錬成を開始する")
    pushKeys({"enter"})  -- 錬成を開始する。改行キー
    coroutine.sleep(2)
    io_net.targetByMob(mob)
    coroutine.sleep(1)
    utils.target_lockon(true)
    coroutine.sleep(1)
    io_chat.info("錬成メニューを開く")
    pushKeys({"enter"})  -- 錬成メニューを開く (時間かかる)
    coroutine.sleep(3)
    -- 風クリ投入
    io_chat.info("燃料を投入する")
    pushKeys({"enter"})  -- 燃料を投入する
    coroutine.sleep(2)
    pushKeys({"down", "down", "enter"})  --  風を選ぶ
    coroutine.sleep(2)
    -- 操作する
    io_chat.info("操作する > たたく, 圧力ハンドル")
    pushKeys({"down", "enter"})  -- 操作する
    coroutine.sleep(1)
    pushKeys({"enter"}) -- たたく
    coroutine.sleep(1)  -- 合間が必要
    pushKeys({"enter"})
    coroutine.sleep(1)
    pushKeys({"enter"}) -- 操作する
    coroutine.sleep(1)
    pushKeys({"down", "enter"}) -- 圧力ハンドル調整
    coroutine.sleep(1)  -- 合間が必要
    pushKeys({"enter"})
    coroutine.sleep(2)
    -- 雷クリ投入
    io_chat.info("雷クリ投入")
    pushKeys({"up", "enter"})  -- 燃料を投入する
    coroutine.sleep(2)
    pushKeys({"down", "down", "enter"})  --  雷を選ぶ
    coroutine.sleep(2)
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

M.npcActionHandlers = {
    ["Synergy Furnace"] = SynergyFurnaceFunction,
}

return M
