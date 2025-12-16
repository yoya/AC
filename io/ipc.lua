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


function M.send(target, method, arg)
    local player = windower.ffxi.get_player()
    print(SIGNATURE, target, player.name, method, arg)
    if arg == nil then
	command = "%s.%s.%s.%s":format(SIGNATURE, target, player.name, method)
    else
	command = "%s.%s.%s.%s.%s":format(SIGNATURE, target, player.name, method, arg)
    end
    windower.send_ipc_message(command)
end

function M.send_all(method, arg)
    M.send("*", method, arg)
end

function M.send_party(method, arg)
    local party = windower.ffxi.get_party()
    for _, x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
	    -- 該当メンバーがいる。かつエリア内にいる
            if member ~= nil and member.mob ~= nil then
		local mob = member.mob
		if  mob.id == id then
		    M.send(mob.name, method, arg)
                end
            end
        end
    end
    return false
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
    if arg == nil then
	io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s", target, source, method)
    else
	io_chat.printf("io/ipc.recieve: target:%s source:%s method:%s arg:%s", target, source, method, arg)
    end
    local player = windower.ffxi.get_player()
    if target ~= '*' and (player == nil or player.name ~= target) then
	print("not for me")
	return  -- 自分向けじゃない
    end
    if method == 'start' then
	if M.inParty() then
	    M.AC.start()
	end
    elseif method == 'stop' then
	if M.inParty() then
	    M.AC.stop()
	end
    elseif method == 'all' then
	M.recieve_all(arg)
    elseif method == 'party' then
	M.recieve_party(source, arg)
    else
	print("io/ipc.recieve: unknown method:"..method)
    end
end

function M.warp_with_ring(arg)
    task.allClear()
    local item_name = 'デジョンリング'
    local item_id = 28540
    io_chat.print(item_name.."発動 10-12秒前")
    if arg == "holla" then
	local item_name = "Ｄ．ホラリング"
	local item_id = 26176
    elseif arg == "dim" then
	item_name = "Ｄ．デムリング"
	item_id = 26177
    elseif arg == "mea" then
	item_name = "Ｄ．メアリング"
	item_id = 26178
    end
    task.allClear()
    io_chat.print(item_name.."10-12秒前")
    coroutine.sleep(math.random(0,8)/6)
    local slot_right_ring = 14
    acitem.useEquipItem(slot_right_ring, item_id, item_name, 10)
end
    
function M.recieve_all(arg)
    print("io/ipc.recieve_all", arg)
    if arg == "dim" or arg == "holla" or arg == "mea" or arg == "warp" then
	M.warp_with_ring(arg)
    elseif arg == "reload" then
	task.setTaskSimple("lua u AC; wait 1; lua l AC", 0, 1)
    else
	print("io/ipc.recieve_all: unknown arg:"..arg)
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
