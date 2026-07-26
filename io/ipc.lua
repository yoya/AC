-- IPC 通信はここ経由で
-- 名前や宛先、コマンドの build/parse もここ。

local M = {}

local control = require 'control'
local io_chat = require "io/chat"
local utils = require 'utils'
local split = utils.split
local task = require 'task'
local acitem = require 'item'
local ac_focus = require 'ac/focus'

--[[
    AC.*.Upaupa.WS.1
    sig, target, source, method, arg
]]

local SIGNATURE = "AC"

-- { {keyword, callback}, ... }
local listener_table = {}
local listener_table_last_idx = 0

local player_name = nil

function M.send(target, method, arg1, arg2, arg3)
    local player = windower.ffxi.get_player()
    if control.debug then
	print("io/ipc.send", SIGNATURE, target, player.name, method, arg1)
    end
    local name = "*"
    -- ログイン切り替え時は前のプレイヤー名でメッセージを送る
    if player ~= nil and player.name ~= nil then
	name = player.name
    end
    local command
    if arg1 == nil then
	command = ("%s.%s.%s.%s"):format(SIGNATURE, target, name, method)
    elseif arg2 == nil then
	command = ("%s.%s.%s.%s.%s"):format(SIGNATURE, target, name, method, arg1)
    elseif arg3 == nil then
	command = ("%s.%s.%s.%s.%s.%s"):format(SIGNATURE, target, name, method, arg1, arg2)
    else
	command = ("%s.%s.%s.%s.%s.%s.%s"):format(SIGNATURE, target, name, method, arg1, arg2, arg3)
    end
    windower.send_ipc_message(command)
end

function M.send_all(method, arg1, arg2, arg3)
    M.send("*", method, arg1, arg2, arg3)
end

function M.send_party(method, arg1, arg2, arg3)
    -- print("io/ipc.send_party", method, arg)
    local party = windower.ffxi.get_party()
    for _, x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
	    -- 該当メンバーがいる。かつエリア内にいる
            if member ~= nil and member.mob ~= nil then
		local mob = member.mob
		if not mob.is_npc then
		    -- io_chat.print("send_party:", mob.name)
		    M.send(mob.name, method, arg1, arg2, arg3)
		    coroutine.sleep(0.2)
		end
            end
        end
    end
    return false
end

function M.receive(message)
    if control.debug then
	print("io/ipc.receive:", message)
    end
    local sig = message:sub(1, SIGNATURE:len())
    if sig ~= SIGNATURE then
	print("unknown signature:", sig)
	return
    end
    local words = split(message, ".")
    local target = words[2]
    local source = words[3]
    local method = words[4]
    local arg1 = words[5]
    local arg2 = words[6]
    local arg3 = words[7]
    if control.debug then
	print(target, source, method, arg1)
	if arg1 == nil then
	    io_chat.printf("io/ipc.receive: target:%s source:%s method:%s arg1:nil", target, source, method)
	elseif arg2 == nil then
	    io_chat.printf("io/ipc.receive: target:%s source:%s method:%s arg1:%s", target, source, method, arg1)
	elseif arg3 == nil then
	    io_chat.printf("io/ipc.receive: target:%s source:%s method:%s arg1:%s arg2:%s", target, source, method, arg1, arg2)
	else
	    io_chat.printf("io/ipc.receive: target:%s source:%s method:%s arg1:%s arg2:%s arg3:%s", target, source, method, arg1, arg2, arg3)
	end
    end
    local player = windower.ffxi.get_player()
    if target ~= '*' and (player == nil or player.name ~= target) then
	if control.debug then
	    print("io/ipc.receive: not for me")
	end
	return  -- 自分向けじゃない
    end
    if method == 'start' then
	if M.in_party() then
	    M.AC.start()
	else
	    print("not in Party")
	end
    elseif method == 'stop' then
	if M.in_party() then
	    M.AC.stop()
	else
	    print("not in Party")
	end
    elseif method == 'all' then
	M.receive_all(arg1, arg2, arg3)
    elseif method == 'build' then
	if arg1 == 'party' then
	    if not M.in_party() then
		M.send(source, "submit", "party")
	    end
	else
	    print("ac all build party")
	end
    elseif method == 'focus' then
	ac_focus.focus(arg1)
    elseif method == 'party' then
	M.receive_party(source, arg1, arg2, arg3)
    elseif method == 'submit' then
	if arg1 == 'party' then
	    local c = "input /pcmd add "..source
	    -- print("io/ipc.receive_party", c)
	    --  command, delay, period
	    task.set_task_simple(c, 1, 2)
	end
    else
	print("io/ipc.receive: unknown method:"..method)
    end
end

function M.warp_with_ring(arg)
    io_chat.print("指輪ワープ", arg)
    if control.debug then
	print("io/ipc.warp_with_ring", arg)
    end
    task.all_clear()
    local item_name = 'デジョンリング'
    local item_id = 28540
    -- io_chat.info(item_name.."発動 10-12秒前")
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
    io_chat.info(item_name.."10-12秒前")
    coroutine.sleep(math.random(1,10)/5)
    local slot_right_ring = 14
    acitem.use_equip_item(slot_right_ring, item_id, item_name, 10)
end
    
function M.receive_all(arg1, arg2, arg3)
    if control.debug then
	print("io/ipc.receive_all", arg1, arg2, arg3)
    end
    M.AC.addon_command_handler(arg1, arg2, arg3)
end

function M.in_party()
    local party = windower.ffxi.get_party()
    if party.party1_leader == nil then
	return false -- パーティに入っていない
    end
    return true -- パーティに入ってる
end

function M.receive_party(source, arg1, arg2, arg3)
    if control.debug then
	io_chat.print("io/ipc.receive_party", arg)
    end
    if arg1 == "build" then
	if not M.in_party() then
	    M.send(source, "party", "submit")
	end
    elseif arg1 == "submit" then
	local c = "input /pcmd add "..source
	-- print("io/ipc.receive_party", c)
	--  command, delay, period
	task.set_task_simple(c, 1, 2)
    else
	if M.in_party() then
	    M.AC.addon_command_handler(arg1, arg2, arg3)
	end
    end
end

return M
