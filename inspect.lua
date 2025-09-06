-- 行動を判断する為の監視データ
-- 最後に WS をうった時間とか。

local utils = require 'utils'
local io_chat = require 'io/chat'
local task = require 'task'
local ac_party = require 'ac/party'
local iamLeader = ac_party.iamLeader

local M = {
    ws_time = 0,
    sc_time = 0,
    sc_attr = 0,
    mb_time = 0,
}

utils.inspect = M

M.skillchain_table = {
    {en="Light", ja="光", magic="サンダー"}, -- 1
    {en="Darkness", ja="闇", magic="ストーン"}, -- 2
    {en="Gravitation", ja="重力", magic="ストーン"}, -- 3
    {en="Fragmentation", ja="分解", magic="サンダー"} , -- 4
    {en="Distortion", ja="湾曲", magic="ブリザド"}, -- 5
    {en="Fusion", ja="核熱", magic="ファイア"}, -- 6
    {en="Compression", ja="収縮", magic="ブリザド"}, -- 7
    {en="Liquefaction", ja="溶解", magic="ファイア"},
    {en="Induration", ja="硬化", magic="ブリザド"},
    {en="Reverberation", ja="振動", magic="ウォータ"},
    {en="Transfixion", ja="貫通", magic="サンダー"},
    {en="Scission", ja="切断", magic="ストーン"},
    {en="Detonation", ja="炸裂", magic="エアロ"},
    {en="Impaction", ja="衝撃", magic="サンダー"},
    {en="Radiance", ja="極光", magic="サンダー"},
    {en="Umbra", ja="黒闇", magic="ブリザド"},
}

function M.ws()
    local now = os.time()
    local datetime = os.date("%X", now)
    M.ws_time = now
    io_chat.setNextColor(6)
    io_chat.printf("-%s- WeaponSkill", datetime)
end

function M.sc(message, attr)
    local now = os.time()
    local datetime = os.date("%X", now)
    M.sc_time = now
    M.sc_attr = attr
    local sc = M.skillchain_table[attr]
    if sc == nil then
	io_chat.setNextColor(3)
	io_chat.printf("-%d- mesg(%d) 連携(%d)", datetime, message, attr)
	return
    end
    io_chat.setNextColor(6)
    io_chat.printf("-%s- mesg(%d) 連携(%d:%s) => %s",
		   datetime, message, attr, sc.ja, sc.magic)
end

function M.mb(duration)
    M.mb_time = os.time() + duration
end

M.alliance_table = {}

function is_alliance_joined(alliance_table)
    for id, member in pairs(alliance_table) do
	if M.alliance_table[id] == nil then
	    print("found", id)
	    return true  -- メンバーが増えてる
	end
    end
    return false
end

function M.party_update(alliance_table)
    if is_alliance_joined(alliance_table) and iamLeader() then
	io_chat.setNextColor(5)
	io_chat.print("パーティorアライアンスのメンバー追加")
	local remain_list = { 90, 60, 30, 10, 3 }
	for i, remain in ipairs(remain_list) do
	    local c = "//echo フェイス呼び出し可能@"..remain.."秒"
	    local delay = 120-remain
	    -- io_chat.print(c)
	    task.removeTaskSimple(c)
	    task.setTaskSimple(c, delay, 1)
	end
    end
    M.alliance_table = alliance_table
end

return M
