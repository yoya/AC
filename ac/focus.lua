local M = {}

local utils = require 'utils'
local command = require 'command'
local io_chat = require 'io/chat'

M.focus_table = {}
M.focus_my_index = nil

function M.init(accountList)
    local focus_list = { }
    for i, charalist in pairs(accountList) do
	local ii = tonumber(i)
	if focus_list[ii] == nil then
	    focus_list[ii] = {}
	end
	for _, name in ipairs(string.split(charalist, ",")) do
	    table.insert(focus_list[ii], utils.string.trim(name))
	end
    end
    for idx, name_list in pairs(focus_list) do
	for _, name in ipairs(name_list) do
	    M.focus_table[name] = idx
	end
    end
    M.focus_my_index = 0
    for i,_ in pairs(focus_list) do
	-- ex) command.send('bind @1 ac focus 1')
	local bind_command = 'bind @'..tostring(i)..' ac focus '..tostring(i)
	command.send(bind_command)
    end
    -- Alt-tab は乗っ取れなかった。残念。
    command.send('bind ^tab ac focus -1')
    command.send('bind ^DIK_TAB ac focus -1')
end

function M.load(player)
    M.focus_my_index = M.focus_table[player.name]
    io_chat.notice("[load] focus #", M.focus_my_index, player.name, "=======")
end

function M.login()
    local player = windower.ffxi.get_player()
    M.focus_my_index = M.focus_table[player.name]
    io_chat.notice("[login] focus", M.focus_my_index, player.name)
end

function M.focus(idx)
    if M.focus_my_index == tonumber(idx) then
	windower.take_focus()
    end
end

return M
