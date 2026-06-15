local M = {}

local utils = require 'utils'
local control = require 'control'
local io_chat = require 'io/chat'--
local io_net = require 'io/net'
local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

M.wantedMobs = {
    "Vedrfolnir" -- テリガン
}

function M.tick(player)
    if not control.auto or not control.attack then return end
    -- "Ethereal Junction" then
    local jct_name = "Ethereal Junction"
    local jct = windower.ffxi.get_mob_by_name(jct_name)
    if jct ~= nil and jct.valid_target then
	io_net.targetByMob(jct)
    end
    local t = windower.ffxi.get_mob_by_target("t")
    if t ~= nil and t.name == jct_name and t.valid_target then
	utils.target_lockon(true)
	windower.ffxi.run(true)
	coroutine.sleep(1)
	windower.ffxi.run(false)
	pushKeys({"enter"})
	coroutine.sleep(1)
	pushKeys({"up", "enter"})
	coroutine.sleep(3)
    end
end

return M
