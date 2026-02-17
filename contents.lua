local M = {}

-- Idle, Leveling, Ambus, Works, Mission, ...
M.Idle = 0
M.Leveling = 1
M.Ambus = 2
M.Works = 3
M.Trove = 4
M.Mission = 5
M.AbysYellow = 6
M.MogGarden = 7
M.Trial = 8  -- 試練(各属性プロトクリスタル)
M.Raives = 9
M.WKR = 10
M.LoginPoint = 11
M.Vagary = 12
M.allContents = { M.Idle, M.Leveling, M.Ambus, M.Works, M.Trove,  M.Mission, M.AbysYellow, M.MogGarden, M.Trial, M.Raives, M.WKR, M.LoginPoint, M.Vagary }

M.ambus = require 'contents/ambus'
M.trial = require 'contents/trial'
M.raives = require 'contents/raives'
M.wkr = require 'contents/wkr'
M.vagary = require 'contents/vagary'
M.contentsTable = {
    -- モードが必要なだけで特別な処理のないcontentsは、ここに追加しない
    [M.Ambus] = M.ambus,
    [M.Trial] = M.trial,
    [M.Raives] = M.raives,
    [M.WKR] = M.wkr,
    [M.Vagary] = M.vagary,
}

M.type = M.Idle

function M.setContents(name)
    local nameTable = {
	[M.Idle] = {nil, '', 'idle'},
	[M.Leveling] = {'leveling', 'level'},
	[M.Ambus] = {"ambus"},
	[M.Works] = {'works'},
	[M.Trove] = {'trove'},
	[M.Mission] = {'mission'},
	[M.AbysYellow] = {'abysyellow', 'yellow'},
	[M.MogGarden] = {'moggarden', 'garden'},
	[M.Trial] = {'trial'},
	[M.Raives] = {'raives'},
	[M.WKR] = {'wkr'},
	[M.LoginPoint] = {'loginpoint', 'login', 'logpo'},
	[M.Vagary] = {'vagary'},
    }
    for c, names in pairs(nameTable) do
	for _, n in ipairs(names) do
	    if name == n then
		M.type = c
		return true
	    end
	end
    end
    return false
end

function M.tick(player)
    if M.type == M.Idle then
	return
    end
    if M.contentsTable[M.type] == nil then
	return  -- 未対応
    end
    local tick = M.contentsTable[M.type].tick
    if tick ~= nil then
	tick(player)
    end
end

return M
