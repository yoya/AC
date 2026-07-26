local M = {}

local utils = require 'utils'
local control = require 'control'
local io_chat = require 'io/chat'--
local io_net = require 'io/net'
local keyboard = require 'keyboard'
local push_keys = keyboard.push_keys

M.wantedMobs = {
    "Vedrfolnir" -- テリガン
}

function M.tick(player)
    if not control.auto or not control.attack then return end
    -- "Ethereal Junction" then
    local jct_name = "Ethereal Junction"
    local jct = windower.ffxi.get_mob_by_name(jct_name)
    if jct ~= nil and jct.valid_target then
	io_net.target_by_mob(jct)
    end
    local t = windower.ffxi.get_mob_by_target("t")
    if t ~= nil and t.name == jct_name and t.valid_target then
	utils.target_lockon(true)
	windower.ffxi.run(true)
	coroutine.sleep(1)
	windower.ffxi.run(false)
	push_keys({"enter"})
	coroutine.sleep(1)
	push_keys({"up", "enter"})
	coroutine.sleep(3)
    end
end

return M
