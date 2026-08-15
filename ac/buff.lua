--- Buff
--- 自分にかかっているバフの残り時間。
--- incoming 0x063 (Order 9) が書き、ジョブ側が読む。
--- windower.ffxi.get_player().buffs は ID の配列だけで残り時間を持たないので、
--- 残り時間が要るならここを使う。
---
--- パーティメンバーのバフ (0x076) は残り時間を持たないので ac/party 側にある。

local M = {}

-- 失効時刻の換算。libs/packets/fields.lua の bufftime と同じ式。
-- 末尾の倍数 (BUFF_CYCLE_NUM) は約 2.27 年ごとに増える定数で、Windower 側が
-- 更新する。ずれると残り時間が桁違いになるので、to_expiry で吸収する
local BUFF_EPOCH = 1009810800
local BUFF_CYCLE = 0x100000000 / 60  -- 約 71582788 秒 (約 2.27 年)
local BUFF_CYCLE_NUM = 10

-- 残り時間として現実的な範囲。歌もバフも 24 時間を超える事はない。
-- 下限に余裕を持たせているのは、切れた直後のバフがまだ載っている為
local REMAIN_MIN = -60
local REMAIN_MAX = 24 * 60 * 60

-- 0x063 (Order 9) を最後に受けた時刻。nil の間は「分からない」であって
-- 「バフが無い」ではない。呼ぶ側はここを見てから判断する
M.self_updated_at = nil

local self_list = {}       -- { {id=, raw=, expiry=}, ... } 受けた順
local self_expiry = {}     -- status id => 失効時刻の配列 (降順)

function M.reset()
    self_list = {}
    self_expiry = {}
    M.self_updated_at = nil
end

-- 生の Time 値を失効時刻 (unix 秒) に直す。現実的な範囲に収まらなければ nil。
-- BUFF_CYCLE_NUM がずれた時に、周期をずらして辻褄を合わせにいく事はしない。
-- もっともらしい嘘の残り時間を返すより「分からない」と言う方が安全で、
-- 分からないバフは「かかっていない」= 歌い直す側に倒れる。
-- 全部が nil になったら定数がずれた合図。ac show song all で生値を確かめる
function M.to_expiry(raw, now)
    local expiry = BUFF_EPOCH + raw / 60 + BUFF_CYCLE * BUFF_CYCLE_NUM
    local remain = expiry - now
    if remain < REMAIN_MIN or REMAIN_MAX < remain then
	return nil
    end
    return expiry
end

-- incoming 0x063 (Order 9) から呼ぶ。
-- entries = { { id = バフID, time = 生の Time 値 }, ... }
function M.update_self(entries)
    local now = os.time()
    local list = {}
    local expiry_table = {}
    for _, e in ipairs(entries) do
	local expiry = M.to_expiry(e.time, now)
	-- 表示用には換算できなかったものも残す (expiry = nil)
	table.insert(list, { id = e.id, raw = e.time, expiry = expiry })
	if expiry ~= nil then
	    local a = expiry_table[e.id]
	    if a == nil then
		a = {}
		expiry_table[e.id] = a
	    end
	    table.insert(a, expiry)
	end
    end
    for _, a in pairs(expiry_table) do
	table.sort(a, function(x, y) return x > y end)
    end
    self_list = list
    self_expiry = expiry_table
    M.self_updated_at = now
end

-- status_id のバフの残り秒。長い順の配列。かかっていなければ空配列。
-- まだ 0x063 を受けていなければ nil (分からない)
function M.self_remains(status_id)
    if M.self_updated_at == nil then
	return nil
    end
    local now = os.time()
    local remains = {}
    for _, expiry in ipairs(self_expiry[status_id] or {}) do
	local r = expiry - now
	if r > 0 then
	    table.insert(remains, r)
	end
    end
    return remains
end

-- status_id のバフの数。分からなければ nil
function M.self_count(status_id)
    local remains = M.self_remains(status_id)
    if remains == nil then
	return nil
    end
    return #remains
end

-- 表示用。受け取ったままの一覧を返す ({ {id=, raw=, expiry=}, ... })
function M.self_all()
    return self_list
end

return M
