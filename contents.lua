local M = {}

local io_chat = require 'io/chat'

-- Idle, Leveling, Ambus, Works, Mission, ...
M.Idle = 0
M.Leveling = 1    -- レベル上げ
M.Ambus = 2       -- アンバス
M.Works = 3       -- ワークス
M.Trove = 4       -- AMANトローブ
M.Mission = 5
M.AbysYellow = 6  -- アビセアの黄色発光
M.MogGarden = 7
M.Trial = 8       -- 試練(各属性プロトクリスタル)
M.Raives = 9      -- コロナイズ/レイアレイブス
M.WKR = 10        -- ワイルドキーパーレイブス
M.LoginPoint = 11
M.Vagary = 12     -- ベガリーインスペクター
M.Synergy = 13    -- 窯錬成 (スキル上げ)
M.Redeem = 14    -- 換金(エミネンス/ユニティポイント)
M.allContents = { M.Idle, M.Leveling, M.Ambus, M.Works, M.Trove,  M.Mission, M.AbysYellow, M.MogGarden, M.Trial, M.Raives, M.WKR, M.LoginPoint, M.Vagary, M.Synergy, M.Redeem }

M.ambus = require 'contents/ambus'
M.trial = require 'contents/trial'
M.raives = require 'contents/raives'
M.wkr = require 'contents/wkr'
M.vagary = require 'contents/vagary'
M.synergy = require 'contents/synergy'
M.trove = require 'contents/trove'
M.redeem = require 'contents/redeem'
M.contentsTable = {
    -- モードが必要なだけで特別な処理のないcontentsは、ここに追加しない
    [M.Ambus] = M.ambus,
    [M.Trial] = M.trial,
    [M.Raives] = M.raives,
    [M.WKR] = M.wkr,
    [M.Vagary] = M.vagary,
    [M.Synergy] = M.synergy,
    [M.Trove] = M.trove,
    [M.Redeem] = M.redeem,
}

M.type = M.Idle

M.nameTable = {
    [M.Idle] = {'idle', nil, ''},
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
    [M.Synergy] = {'synergy'},
    [M.Trove] = {'trove'},
}

function M.setContents(name)
    for c, names in pairs(M.nameTable) do
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

function M.npcActionHandler(zone, mob)
    for _, c in pairs(M.contentsTable) do
	if c.npcActionHandlers ~= nil then
	    for name, handler in pairs(c.npcActionHandlers) do
		if mob.name == name then
		    handler(zone, mob)
		end
	    end
	end
    end
end

function M.zone_out()
    for _, c in pairs(M.contentsTable) do
	if c.zone_out ~= nil then
	    c.zone_out()
	end
    end
end

function M.matchContentsName(name)
    -- print("contents.matchContentsName(name)", name)
    local names = M.nameTable[M.type]
    print(names);
    if names == nil then return false end
    for _, n in ipairs(names) do
	print(name, "==", n);
	if name == n then
	    return true
	end
    end
    return false
end

function M.showContents()
    local name = M.nameTable[M.type]
    if name == nil then
	name = "<nil>"
    else
	name = name[1]
    end
    io_chat.infof("Contents: %s", name)
end

return M
