local M = {}

local io_chat = require 'io/chat'

-- Idle, Leveling, Ambus, Works, Mission, ...
M.Idle       =  1
M.Leveling   =  2  -- レベル上げ
M.Ambus      =  3  -- アンバス
M.Works      =  4  -- ワークス
M.Trove      =  5  -- AMANトローブ
M.Mission    =  6
M.AbysYellow =  7  -- アビセアの黄色発光
M.MogGarden  =  8
M.Trial      =  9  -- 試練(各属性プロトクリスタル)
M.Raives     = 10  -- コロナイズ/レイアレイブス
M.WKR        = 11  -- ワイルドキーパーレイブス
M.LoginPoint = 12
M.Vagary     = 13  -- ベガリーインスペクター
M.Synergy    = 14  -- 窯錬成 (スキル上げ)
M.Redeem     = 15  -- 換金(エミネンス/ユニティポイント)
M.GobMys     = 16  -- ゴブの不思議箱 (Gobbie Mystery Box)

M.allContents = { M.Idle, M.Leveling, M.Ambus, M.Works, M.Trove,  M.Mission, M.AbysYellow, M.MogGarden, M.Trial, M.Raives, M.WKR, M.LoginPoint, M.Vagary, M.Synergy, M.Redeem, M.GobMys }

M.ambus   = require 'contents/ambus'
M.trial   = require 'contents/trial'
M.raives  = require 'contents/raives'
M.wkr     = require 'contents/wkr'
M.vagary  = require 'contents/vagary'
M.synergy = require 'contents/synergy'
M.trove   = require 'contents/trove'
M.redeem  = require 'contents/redeem'
M.contentsTable = {
    -- モードが必要なだけで特別な処理のないcontentsは、ここに追加しない
    [M.Ambus]   = M.ambus,
    [M.Trial]   = M.trial,
    [M.Trove]   = M.trove,
    [M.Raives]  = M.raives,
    [M.WKR]     = M.wkr,
    [M.Vagary]  = M.vagary,
    [M.Synergy] = M.synergy,
    [M.Redeem]  = M.redeem,
}
for c, m in pairs(M.contentsTable) do
    m.parent = M
end

M.type = M.Idle


M.nameTable = {
    [M.Idle]       = {'Idle', nil, ''},
    [M.Leveling]   = {'Leveling', 'level'},
    [M.Ambus]      = {"Ambus"},
    [M.Works]      = {'Works'},
    [M.Trove]      = {'Trove'},
    [M.Mission]    = {'Mission'},
    [M.AbysYellow] = {'AbysYellow', 'yellow'},
    [M.MogGarden]  = {'MogGarden', 'garden'},
    [M.Trial]      = {'Trial'},
    [M.Raives]     = {'Raives'},
    [M.WKR]        = {'WKR'},
    [M.LoginPoint] = {'LoginPoint', 'login', 'logpo'},
    [M.Vagary]     = {'Vagary'},
    [M.Synergy]    = {'Synergy'},
    [M.Redeem]     = {'Redeem'},
    [M.GobMys]     = {'GobMys', 'Gob'},
}

function M.setContents(name)
    for c, names in pairs(M.nameTable) do
	for _, n in ipairs(names) do
	    if name:lower() == n:lower() then
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

function M.getContentsByName(name)
    print("contents.getContentsByName(name)", name)
    local names = M.nameTable[M.type]
    if names == nil then return false end
    for i, n in ipairs(names) do
	if name:lower() == n:lower() then
	    return i, M.contentsTable[n]
	end
    end
    return 0, nil
end

function M.matchContentsName(name)
    -- print("contents.matchContentsName(name)", name)
    local i, c = M.getContentsByName(name)
    if i == M.type then
	return true
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

function M.listContents()
    local str = ''
    for c, names in pairs(M.nameTable) do
	str = str .. names[1] .. " "
    end
    io_chat.infof("listContents: %s", str)
end

return M
