-- IPC 通信はここ経由で
-- 名前や宛先、コマンドの build/parse もここ。

local M = {}

local io_chat = require("io/chat")
local utils = require('utils')
local split = utils.split
local task = require 'task'
local acitem = require 'item'

--[[
    AC.*.Upaupa.WS.1
]]

local SIGNATURE = "AC."

-- { {keyword, callback}, ... }
local listener_table = {}
local listener_table_last_idx = 0


function M.send(target, method, arg)
    local player = windower.ffxi.get_player()
    command = "%s.%s.%s.%s.%s":format(SIGNATURE, target, player.name, method, arg)
    windower.send_ipc_message(command)
end


function M.recieve(message)
    local sig = message:sub(1, SIGNATURE:len())
    print("io/ipc.recieve:", message)
    if sig ~= SIGNATURE then
	print("unknown signature:", sig)
	return
    end
    local words = split(message, ".")
    local target = words[2]
    local source = words[3]
    local method = words[4]
    local arg = words[5]
    -- io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s arg:%s", target, source, method, arg)
    local player = windower.ffxi.get_player()
    if target ~= '*' and (player == nil or player.name ~= target) then
	return  -- 自分向けじゃない
    end
    if method == 'party' then
	M.recieve_party(source, arg)
    end
end

function M.recieve_party(source, arg)
--     io_chat.print("io/ipc.recieve_party", arg)
    if arg == "build" then
	M.send(source, "party", "submit")
    elseif arg == "submit" then
	local c = "input /pcmd add "..source
	-- print("io/ipc.recieve_party", c)
	--  command, delay, period
	task.setTaskSimple(c, 1, 2)
    elseif arg == "warp" then
	local me = windower.ffxi.get_mob_by_target("me")
	if me == nil or not me.in_party then
	    return  -- パーティに入っていない
	end
	io_chat.print("デジョン10-12秒前")
	coroutine.sleep(math.random(0,8)/4)
	local slot_right_ring = 14
	local warpring_id = 28540
	acitem.useEquipItem(slot_right_ring, warpring_id, 'デジョンリング', 9)
    else
	print("io/ipc.recieve_party: unknown arg:"..arg)
    end
end

return M
