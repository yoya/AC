--- packets で送受信する関数はここ

local M = {}

require('pack')  -- 文字列の :pack

local control = require 'control'
local keyboard = require 'keyboard'
local utils = require 'utils'
local io_chat = require 'io/chat'

-- incoming 0x058 (Assist Response) でターゲットを合わせる。
-- https://github.com/DiscipleOfEris/Assist/blob/master/assist.lua
--
-- libs/packets/fields.lua の 0x058 定義には Target Index が無く、
-- packets.new は定義に無いキーを黙って捨てるので、packets 経由では
-- mob.index が常に 0 で注入されていた。ここだけバイト配置を直接書く。
--   00 ヘッダ (id 9bit | size 7bit | sequence 16bit)
--   04 Player ID     (unsigned int)
--   08 Target ID     (unsigned int)
--   0C Player Index  (unsigned short)
--   0E Target Index  (unsigned short)
local ASSIST_ID = 0x058
-- size は dword 単位。4 dword = 16 バイト。b9b7H なので size は 9bit 左シフト
local ASSIST_HEADER = ASSIST_ID + 4 * 0x200

M.target_by_mob = function(mob)
    if mob == nil then
	print(debug.traceback())
	return false
    end
    local player = windower.ffxi.get_player()
    if player == nil then
	return false
    end
    windower.packets.inject_incoming(
	ASSIST_ID,
	('I3H2'):pack(ASSIST_HEADER, player.id, mob.id,
		      player.index, mob.index))
    return true
end

-- ターゲットが一致するまで tab を押し直す。
-- 対象がターゲット不能になると無限に押し続けるので上限を設ける。
local TARGET_RETRY_MAX = 20  -- 約 0.7 秒 x 20 = 14 秒

M.target_by_mob_ex = function(mob)
    M.target_by_mob(mob)
    local retry = 0
    while control.auto do
	retry = retry + 1
	if retry > TARGET_RETRY_MAX then
	    io_chat.warnf("target_by_mob_ex: %s を掴めないので諦める",
			  mob and mob.name or "(nil)")
	    return false
	end
	coroutine.sleep(0.3)
	local m = windower.ffxi.get_mob_by_target("t")
	if m ~= nil then
	    -- print("m.index ~= mob.index", m.index, mob.index)
	end
	if m == nil or m.index ~= mob.index then
	    -- print("tab")
	    utils.target_lockon(false)
	    coroutine.sleep(0.2)
	    keyboard.push_keys({"tab"})
	    M.target_by_mob(mob)
	    coroutine.sleep(0.2)
	else
	    -- print("mob match")
	    return true
	end
    end
    return false
end

M.target_by_mob_name = function(name)
    local mob = windower.ffxi.get_mob_by_name(name)
    if mob == nil then
	print("io/net.target_by_mob_name mob == nil name:"..name)
	return false
    end
    return M.target_by_mob(mob)
end

M.target_by_mob_id = function(mobId)
    local mob = windower.ffxi.get_mob_by_id(mobId)
    if mob == nil then
	print("io/net.target_by_mob_id mob not found by id:", mobId)
	return false
    end
    return M.target_by_mob(mob)
end

M.target_by_mob_index = function(mobIndex)
    if control.debug then
	print("WARNING: io/net.target_by_mob_index:", mobIndex)
    end
    if mobIndex == 0 then
        print("ERROR: io/net.target_by_mob_index mobIndex:", mobIndex)
        return
    end
    local mob = windower.ffxi.get_mob_by_index(mobIndex)
    if mob == nil then
	print("io/net.target_by_mob_index mob not found by index:", mobIndex)
        return
    end
    M.target_by_mob(mob)
end

return M
