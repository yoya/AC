--- 歌の選び方
---
--- 「今の残り時間で歌うか」「どの曲を歌うか」を決める純関数だけを置く。
--- windower にも他のモジュールにも触らないので tests から呼べる。
--- 実際に歌うのは job/BRD.lua。

local M = {}

-- 残りがこれ (秒) を切った曲が1つでもあれば歌い始める
M.EXPIRE_SOON = 60
-- 残りがこれ (秒) を切った曲が EXPIRE_SOON_NUM 曲以上あれば歌い始める
M.EXPIRE_SOON_ALL = 120
M.EXPIRE_SOON_NUM = 2

-- plan の各曲の残り秒を出す。かかっていない曲は 0。
---  plan       : 歌名の配列。並びがそのまま優先順
---  status_of  : 歌名 => status id
---  remains_of : status id => 実測の残り秒の配列 (降順)。取れないなら nil
---  sung_at    : 歌名 => 最後に歌った時刻。歌っていなければ nil
---  lacking    : status id => true。パーティメンバーに足りていない family
--- 戻り値: plan と同じ並びの残り秒の配列
---
--- status を共有する曲がある (猛者のメヌエット I〜V は全部 198、怪力/妙技の
--- エチュードは両方 215)。実測の側は「どの曲か」を持っていないので、
--- 新しく歌ったものほど残りが長い事を使って、family ごとに
--- 「歌った時刻の新しい順」と「残りの長い順」を突き合わせる。
--- ソウルボイス等で1曲だけ効果時間が伸びると family 内の対応はずれるが、
--- 残り秒の集合そのものは正しいので、歌うか否かの判断は狂わない。
function M.plan_remains(plan, status_of, remains_of, sung_at, lacking)
    sung_at = sung_at or {}
    lacking = lacking or {}
    local order = {}
    for i, name in ipairs(plan) do
	order[name] = i
    end
    -- status id => その family に属する plan 上の歌名
    local family = {}
    for _, name in ipairs(plan) do
	local sid = status_of[name]
	if sid ~= nil then
	    if family[sid] == nil then
		family[sid] = {}
	    end
	    table.insert(family[sid], name)
	end
    end
    local remain_of_name = {}
    for sid, names in pairs(family) do
	-- 新しく歌った順。同じ時刻なら plan の順で決める (毎回同じ結果にする為)
	table.sort(names, function(a, b)
	    local ta, tb = sung_at[a] or 0, sung_at[b] or 0
	    if ta ~= tb then
		return ta > tb
	    end
	    return order[a] < order[b]
	end)
	local remains = remains_of[sid] or {}
	for i, name in ipairs(names) do
	    if lacking[sid] then
		remain_of_name[name] = 0  -- メンバーに入っていないので歌い直す
	    else
		remain_of_name[name] = remains[i] or 0
	    end
	end
    end
    local out = {}
    for i, name in ipairs(plan) do
	out[i] = remain_of_name[name] or 0
    end
    return out
end

-- 歌い始めるか。plan_remains の戻り値を渡す
function M.should_sing(remains)
    local soon = 0
    local soon_all = 0
    for _, r in ipairs(remains) do
	if r < M.EXPIRE_SOON then
	    soon = soon + 1
	end
	if r < M.EXPIRE_SOON_ALL then
	    soon_all = soon_all + 1
	end
    end
    return soon >= 1 or soon_all >= M.EXPIRE_SOON_NUM
end

-- 次に歌う1曲。優先順の上から、未掛かり/閾値割れの最初のもの。無ければ nil
function M.pick_song(plan, remains)
    for i, name in ipairs(plan) do
	if (remains[i] or 0) < M.EXPIRE_SOON_ALL then
	    return name
	end
    end
    return nil
end

return M
