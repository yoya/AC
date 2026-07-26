local M = {}
__AC = __AC or {}
__AC.contents = M

local io_chat = require 'io/chat'
local incoming_text = require 'incoming/text'

-- Idle, Leveling, Ambus, Works, Mission, ...
M.Idle        =  1
M.Leveling    =  2  -- レベル上げ
M.Ambus       =  3  -- アンバス
M.Works       =  4  -- ワークス
M.Trove       =  5  -- AMANトローブ
M.Mission     =  6
M.Abyssea     =  7  -- アビセア(黄色発光含む予定)
M.Garden      =  8  -- モグガーデン
M.Trial       =  9  -- 試練(各属性プロトクリスタル)
M.Raives      = 10  -- コロナイズ/レイアレイブス
M.WKR         = 11  -- ワイルドキーパーレイブス
M.LoginPoint  = 12
M.Vagary      = 13  -- ベガリーインスペクター
M.Synergy     = 14  -- 窯錬成 (スキル上げ)
M.Redeem      = 15  -- 換金(エミネンス/ユニティポイント)
M.GobMys      = 16  -- ゴブの不思議箱 (Gobbie Mystery Box)
M.UnityWanted = 17  -- ユニティ・ウォンテッド
M.Sortie      = 18  -- ソーティ

M.all_contents = { M.Idle, M.Leveling, M.Ambus, M.Works, M.Trove,  M.Mission, M.Abyssea, M.Garden, M.Trial, M.Raives, M.WKR, M.LoginPoint, M.Vagary, M.Synergy, M.Redeem, M.GobMys, M.UnityWanted, M.Sortie }

M.ambus   = require 'contents/ambus'
M.trial   = require 'contents/trial'
M.garden  = require 'contents/garden'
M.raives  = require 'contents/raives'
M.wkr     = require 'contents/wkr'
M.vagary  = require 'contents/vagary'
M.synergy = require 'contents/synergy'
M.trove   = require 'contents/trove'
M.abyssea = require 'contents/abyssea'
M.redeem  = require 'contents/redeem'
M.wanted  = require 'contents/wanted'
M.sortie  = require 'contents/sortie'
M.contents_table = {
    -- モードが必要なだけで特別な処理のないcontentsは、ここに追加しない
    [M.Ambus]       = M.ambus,
    [M.Trial]       = M.trial,
    [M.Garden]      = M.garden,
    [M.Trove]       = M.trove,
    [M.Abyssea]     = M.abyssea,
    [M.Raives]      = M.raives,
    [M.WKR]         = M.wkr,
    [M.Vagary]      = M.vagary,
    [M.Synergy]     = M.synergy,
    [M.Redeem]      = M.redeem,
    [M.UnityWanted] = M.wanted,
    [M.Sortie]      = M.sortie,
}
for c, m in pairs(M.contents_table) do
    m.parent = M
end

M.type = M.Idle


M.name_table = {
    [M.Idle]        = {'Idle', nil, ''},
    [M.Leveling]    = {'Leveling', 'level'},
    [M.Ambus]       = {"Ambus"},
    [M.Works]       = {'Works'},
    [M.Trove]       = {'Trove'},
    [M.Mission]     = {'Mission'},
    [M.Abyssea]     = {'Abyssea', 'Abys'},
    [M.Garden]      = {'MogGarden', 'garden'},
    [M.Trial]       = {'Trial'},
    [M.Raives]      = {'Raives'},
    [M.WKR]         = {'WKR'},
    [M.LoginPoint]  = {'LoginPoint', 'login', 'logpo'},
    [M.Vagary]      = {'Vagary'},
    [M.Synergy]     = {'Synergy'},
    [M.Redeem]      = {'Redeem'},
    [M.GobMys]      = {'GobMys', 'Gob'},
    [M.UnityWanted] = {'UnityWanted', 'wanted'},
    [M.Sortie]      = {'Sortie'},
}

M.incoming_text_listener_id = nil

function M.set_type(c)
    local prev_contents = M.type
    if prev_contents ~= c then
	local prev_c = M.contents_table[prev_contents]
	if prev_c ~= nil and prev_c.contents_out ~= nil then
	    prev_c.contents_out()
	end
	if M.incoming_text_listener_id ~= nil then
	    incoming_text.remove_listener(M.incoming_text_listener_id)
	    M.incoming_text_listener_id = nil
	end
	M.type = c
	local next_c = M.contents_table[c]
	if next_c ~= nil then
	    if next_c.contents_in ~= nil then
		next_c.contents_in()
	    end
	    local incoming_text_handler = next_c.incoming_text_handler
	    if incoming_text_handler ~= nil then
		M.incoming_text_listener_id = incoming_text.add_listener("", incoming_text_handler)
	    end
	end
    end
end

function M.set_contents(name)
    for c, names in pairs(M.name_table) do
	for _, n in ipairs(names) do
	    if name:lower() == n:lower() then
		M.set_type(c)
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
    if M.contents_table[M.type] == nil then
	return  -- 未対応
    end
    local tick = M.contents_table[M.type].tick
    if tick ~= nil then
	tick(player)
    end
end

function M.npc_action_handler(zone, mob)
    for _, c in pairs(M.contents_table) do
	if c.npc_action_handlers ~= nil then
	    for name, handler in pairs(c.npc_action_handlers) do
		if mob.name == name then
		    handler(zone, mob)
		end
	    end
	end
    end
end

function M.zone_out()
    for _, c in pairs(M.contents_table) do
	if c.zone_out ~= nil then
	    c.zone_out()
	end
    end
end

function M.get_contents_by_name(name)
    -- print("contents.get_contents_by_name(name)", name)
    local names = M.name_table[M.type]
    if names == nil then return false end
    for i, n in ipairs(names) do
	if name:lower() == n:lower() then
	    return M.type, M.contents_table[M.type]
	end
    end
    return 0, nil
end

function M.match_contents_name(name)
    -- print("contents.match_contents_name(name)", name)
    local i, c = M.get_contents_by_name(name)
    if i == M.type then
	return true
    end
    return false
end

function M.show_contents()
    local name = M.name_table[M.type]
    if name == nil then
	name = "<nil>"
    else
	name = name[1]
    end
    io_chat.infof("Contents: %s", name)
end

function M.list_contents()
    local str = ''
    for c, names in pairs(M.name_table) do
	str = str .. names[1] .. " "
    end
    io_chat.infof("list_contents: %s", str)
end

return M
