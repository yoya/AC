--- Ability
--- 自分に使うジョブアビリティ (/ja 名前 <me>) を、使える時だけ使う為の判定。
---
--- 使わない条件:
---   1. 覚えていない / リキャストが残っている / リキャストが分からない
---   2. res に status (かかるバフ) がある JA で、既にそのバフが自分にかかっている
---
--- 対象外 (素通し): 対象が <me> 以外 (ジャンプ <t>、かばう <p1> 等)、res に無い名前、
--- チャージ制の JA (CHARGE_TYPES)。
--- 「A; wait 1; B」のような連結は、対象の JA が 1 つでも使えなければ全体を使わない。
--- 使わないと決めたコマンドを捨てるかは呼ぶ側の話 (task.get_task は捨てる)。

local utils = require 'utils'

local M = {}

-- リキャストがチャージ制の共有タイマーで、残っていても使える事がある。
-- リキャスト値で「使えない」と言えないので対象から外す
local CHARGE_TYPES = { Rune = true, Scholar = true }

local by_ja = nil  -- 日本語名 => res.job_abilities の行。初回に作る

local function ability_by_ja(name)
    if by_ja == nil then
	by_ja = {}
	local res = require('resources')
	for _, a in pairs(res.job_abilities) do
	    local prev = by_ja[a.ja]
	    -- 同名があればバフを持つ方を残す
	    if prev == nil or (prev.status == nil and a.status ~= nil) then
		by_ja[a.ja] = a
	    end
	end
    end
    return by_ja[name]
end

-- コマンド文字列から /ja を取り出す。{ { name=, target= }, ... }
-- 例) "input /ja ランパート <me>; wait 1; input /ma ケアルIII <me>"
--     => { { name="ランパート", target="me" } }
function M.parse_ja(cmd)
    local list = {}
    for seg in string.gmatch(cmd, "[^;]+") do
	local name, target = string.match(seg, "^%s*input%s+/ja%s+(.-)%s+<(%w+)>%s*$")
	if name ~= nil then
	    table.insert(list, { name = name, target = target })
	end
    end
    return list
end

-- 判定の対象になる JA か。対象外なら nil
local function self_ability(j)
    if j.target ~= 'me' then
	return nil
    end
    local a = ability_by_ja(j.name)
    if a == nil or CHARGE_TYPES[a.type] then
	return nil
    end
    return a
end

-- 1 つの JA が今使えるか。使えなければ false と理由
local function check(a, player, abilities, recasts)
    if not utils.table.contains(abilities.job_abilities, a.id) then
	return false, "未習得"
    end
    -- 覚えていなくても 0 が返り得るので、習得は上で確かめてある。
    -- nil は「分からない」なので使えない側に倒す
    local recast = recasts[a.recast_id]
    if recast == nil then
	return false, "リキャスト不明"
    end
    if recast > 0 then
	return false, "リキャスト中"
    end
    if a.status ~= nil then
	for _, buff_id in ipairs(player.buffs) do
	    if buff_id == a.status then
		return false, "効果中"
	    end
	end
    end
    return true
end

local last_wait = {}  -- command => 最後に表示した理由。同じ理由を毎 tick 出さない為

local function note_wait(cmd, reason)
    if last_wait[cmd] == reason then
	return
    end
    last_wait[cmd] = reason
    local control = require 'control'
    if control.debug then
	local io_chat = require('io/chat')
	io_chat.printf("ja待ち [%s]: %s", reason, cmd)
    end
end

-- cmd を今送ってよいか。判定対象の JA が含まれなければ常に true。
-- sleep しない (即時)。tick から呼んでよい
function M.usable(cmd)
    local targets = {}
    for _, j in ipairs(M.parse_ja(cmd)) do
	local a = self_ability(j)
	if a ~= nil then
	    table.insert(targets, a)
	end
    end
    if #targets == 0 then
	return true
    end
    local player = windower.ffxi.get_player()
    local abilities = windower.ffxi.get_abilities()
    local recasts = windower.ffxi.get_ability_recasts()
    if player == nil or player.buffs == nil or recasts == nil or
       abilities == nil or abilities.job_abilities == nil then
	note_wait(cmd, "状態不明")
	return false
    end
    for _, a in ipairs(targets) do
	local ok, reason = check(a, player, abilities, recasts)
	if not ok then
	    note_wait(cmd, a.ja.." "..reason)
	    return false
	end
    end
    last_wait[cmd] = nil
    return true
end

return M
