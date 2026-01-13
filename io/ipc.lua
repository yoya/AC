-- IPC 通信はここ経由で
-- 名前や宛先、コマンドの build/parse もここ。

local M = {}

local control = require 'control'
local io_chat = require("io/chat")
local utils = require('utils')
local split = utils.split
local task = require 'task'
local acitem = require 'item'

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
    if arg1 == nil then
	command = "%s.%s.%s.%s":format(SIGNATURE, target, name, method)
    elseif arg2 == nil then
	command = "%s.%s.%s.%s.%s":format(SIGNATURE, target, name, method, arg1)
    elseif arg3 == nil then
	command = "%s.%s.%s.%s.%s.%s":format(SIGNATURE, target, name, method, arg1, arg2)
    else
	command = "%s.%s.%s.%s.%s.%s.%s":format(SIGNATURE, target, name, method, arg1, arg2, arg3)
    end
    windower.send_ipc_message(command)
end

function M.send_all(method, arg1, arg2, arg3)
    M.send("*", method, arg1, arg2, arg3)
end

function M.send_party(method, arg)
    print("io/ipc.send_party", method, arg)
    local party = windower.ffxi.get_party()
    for _, x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
	    -- 該当メンバーがいる。かつエリア内にいる
            if member ~= nil and member.mob ~= nil then
		local mob = member.mob
		if not mob.is_npc then
		    io_chat.print("send_party:", mob.name)
		    M.send(mob.name, method, arg)
		    coroutine.sleep(0.3)
		end
            end
        end
    end
    return false
end

function M.recieve(message)
    if control.debug then
	print("io/ipc.recieve:", message)
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
	    io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s arg1:nil", target, source, method)
	elseif arg2 == nil then
	    io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s arg1:%s", target, source, method, arg1)
	elseif arg3 == nil then
	    io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s arg1:%s arg2:%s", target, source, method, arg1, arg2)
	else
	    io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s arg1:%s arg2:%s arg3:%s", target, source, method, arg1, arg2, arg3)
	end
    end
    local player = windower.ffxi.get_player()
    if target ~= '*' and (player == nil or player.name ~= target) then
	if control.debug then
	    print("io/ipc.recieve: not for me")
	end
	return  -- 自分向けじゃない
    end
    if method == 'start' then
	if M.inParty() then
	    M.AC.start()
	else
	    print("not in Party")
	end
    elseif method == 'stop' then
	if M.inParty() then
	    M.AC.stop()
	else
	    print("not in Party")
	end
    elseif method == 'all' then
	M.recieve_all(arg1, arg2, arg3)
    elseif method == 'focus' then
	if M.AC.focusMyIndex == tonumber(arg1) then
	    windower.take_focus()
	end
    elseif method == 'party' then
	M.recieve_party(source, arg1, arg2, arg3)
    else
	print("io/ipc.recieve: unknown method:"..method)
    end
end

function M.warp_with_ring(arg)
    io_chat.print("指輪ワープ", arg)
    if control.debug then
	print("io/ipc.warp_with_ring", arg)
    end
    task.allClear()
    local item_name = 'デジョンリング'
    local item_id = 28540
    io_chat.setNextColor(5)
    io_chat.print(item_name.."発動 10-12秒前")
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
    io_chat.print(item_name.."10-12秒前")
    coroutine.sleep(math.random(1,10)/5)
    local slot_right_ring = 14
    acitem.useEquipItem(slot_right_ring, item_id, item_name, 10)
end
    
function M.recieve_all(arg1, arg2, arg3)
    if control.debug then
	print("io/ipc.recieve_all", arg1, arg2, arg3)
    end
    if arg1 == "dim" or arg1 == "holla" or arg1 == "mea" or arg1 == "warp" then
	M.warp_with_ring(arg1)
    elseif arg1 == "reload" then
	task.setTaskSimple("lua u AC; wait 1; lua l AC", 0, 1)
    elseif arg1 == 'wstp' then
	control.setWSTP(arg2)
    else
	print("io/ipc.recieve_all: unknown arg1:"..arg1)
    end
end

function M.inParty()
    local party = windower.ffxi.get_party()
    if party.party1_leader == nil then
	return false -- パーティに入っていない
    end
    return true -- パーティに入ってる
end

function M.recieve_party(source, arg)
--     io_chat.print("io/ipc.recieve_party", arg)
    if arg == "build" then
	if not M.inParty() then
	    M.send(source, "party", "submit")
	end
    elseif arg == "submit" then
	local c = "input /pcmd add "..source
	-- print("io/ipc.recieve_party", c)
	--  command, delay, period
	task.setTaskSimple(c, 1, 2)
    elseif arg == "dim" or arg == "holla" or arg == "mea" or arg == "warp" then
	if M.inParty() then
	    M.warp_with_ring(arg)
	end
    else
	print("io/ipc.recieve_party: unknown arg:"..arg)
    end
end

return M
