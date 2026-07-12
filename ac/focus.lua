local M = {}

local utils = require 'utils'
local command = require 'command'
local io_chat = require 'io/chat'

M.focusTable = {}
M.focusMyIndex = nil

function M.init(accountList)
    local focusList = { }
    for i, charalist in pairs(accountList) do
	local ii = tonumber(i)
	if focusList[ii] == nil then
	    focusList[ii] = {}
	end
	for _, name in ipairs(string.split(charalist, ",")) do
	    table.insert(focusList[ii], utils.string.trim(name))
	end
    end
    for idx, name_list in pairs(focusList) do
	for _, name in ipairs(name_list) do
	    M.focusTable[name] = idx
	end
    end
    M.focusMyIndex = 0
    for i,_ in pairs(focusList) do
	-- ex) command.send('bind @1 ac focus 1')
	local bind_command = 'bind @'..tostring(i)..' ac focus '..tostring(i)
	command.send(bind_command)
    end
    -- Alt-tab は乗っ取れなかった。残念。
    command.send('bind ^tab ac focus -1')
    command.send('bind ^DIK_TAB ac focus -1')
end

function M.load(player)
    M.focusMyIndex = M.focusTable[player.name]
    io_chat.notice("[load] focus #", M.focusMyIndex, player.name, "=======")
end

function M.login()
    local player = windower.ffxi.get_player()
    M.focusMyIndex = M.focusTable[player.name]
    io_chat.notice("[login] focus", M.focusMyIndex, player.name)
end

function M.focus(idx)
    if M.focusMyIndex == tonumber(idx) then
	windower.take_focus()
    end
end

return M
