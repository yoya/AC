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

-- 残りが分からない曲。乗っているらしいが、実測のどれに当たるかを
-- 決められない時に使う。閾値のどちらにも掛からない値なので、
-- should_sing も pick_song もこれを「歌わなくてよい」と扱う。
-- 分からないものを勝手に「切れかけ」と読むと、残りが沢山ある歌を
-- 上書きしてしまう
M.UNKNOWN = math.huge

-- 楽器の「歌数+」(item id => 追加本数)。楽器は range スロット。
-- ここに無い楽器と、楽器を持っていない時は 0 (SONGS_BASE のまま)。
--
-- 名前ではなく id で引く。ダウルダヴラ (4種) とラックナシェード (2種) は
-- 同じ名前で歌数が違うので、名前では正しく引けない。
-- カマラデリハープ (21408) は「レイヴ:歌数+1」で Odyssey レイヴの中だけなので入れない
M.EXTRA_SONGS_BY_ID = {
    [18575] = 1,  -- ダウルダヴラ (Lv90)
    [18576] = 1,  -- ダウルダヴラ (Lv95)
    [18571] = 2,  -- ダウルダヴラ (Lv99)
    [18839] = 2,  -- ダウルダヴラ (Lv99)
    [21400] = 1,  -- ブラーハープ
    [21401] = 1,  -- ブラーハープ+1
    [21407] = 1,  -- テルパンダー
    [22249] = 1,  -- ミラクルチアー
    [22306] = 1,  -- ラックナシェード
    [22307] = 2,  -- ラックナシェード (強化後)
}
-- 楽器を持っていない時に維持できる本数
M.SONGS_BASE = 2

-- 維持できる歌の本数。
---  instrument_id : 今装備している楽器の item id。持っていなければ nil
---  clarion_call  : クラリオンコール中か
--- 知らない楽器は加算しない。多く見積もると plan が歌枠を超え、
--- 新しい歌が古い歌を押し出して永久に歌い続ける事になる
function M.max_songs(instrument_id, clarion_call)
    local n = M.SONGS_BASE + (M.EXTRA_SONGS_BY_ID[instrument_id] or 0)
    if clarion_call then
	n = n + 1
    end
    return n
end

-- 楽器の持ち替え。
--
-- 普段はミラクルチアー (歌数+1) で、維持できる本数まで歌えたら、もう1曲
-- 載せる為だけにダウルダヴラ (歌数+2) へ持ち替え、載ったら戻す。
-- 歌える本数は歌が着弾した瞬間の楽器で決まるので、持ち替えは曲と曲の間で
-- 済んでいればよい。
--
-- ダウルダヴラに持ち替える本数はクラリオンコールで動かさない (依頼通り)。
-- クラリオンコール中はミラクルチアーでも1曲多く持てるので、その1曲まで
-- ミラクルチアーで歌いたいなら、ここも +1 する事になる
M.DAURDABLA_FROM = 3   -- ミラクルチアーで維持できる本数 (SONGS_BASE + 1)
M.MIRACLE_FROM = 4     -- ダウルダヴラで維持できる本数 (SONGS_BASE + 2)

-- 今かかっている歌の本数で、どちらの楽器を着けたいかを返す。
--- song_count   : 自分にかかっている歌の本数
--- clarion_call : クラリオンコール中か
--- 戻り値: "daurdabla" | "miracle"
function M.want_instrument(song_count, clarion_call)
    local back = M.MIRACLE_FROM + (clarion_call and 1 or 0)
    if M.DAURDABLA_FROM <= song_count and song_count < back then
	return "daurdabla"
    end
    return "miracle"
end

-- plan を維持できる本数まで切り詰める。溢れた分は歌わない。
-- 切り詰めずに歌うと押し出し合いになり、残りが沢山ある歌まで歌い直す
function M.trim(plan, n)
    if #plan <= n then
	return plan
    end
    local out = {}
    for i = 1, n do
	out[i] = plan[i]
    end
    return out
end

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
---
--- 突き合わせられるのは自分が歌った曲だけ。sung_at に記録の無い曲は
--- アドオンを読み直す前から乗っていたもので、実測のどれに当たるか決められない。
--- そこを plan の順で埋めると、残りが沢山ある曲を「切れかけ」と読んで
--- 上書きしてしまうので、実測が余っている分だけ UNKNOWN にして触らない。
--- 実測が足りない分は本当に乗っていないので 0 (歌い直す) にする。
---
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
	-- 自分が歌った曲を新しい順に前へ。歌っていない曲は後ろ。
	-- 同じ時刻なら plan の順で決める (毎回同じ結果にする為)
	table.sort(names, function(a, b)
	    local ta, tb = sung_at[a] or 0, sung_at[b] or 0
	    if ta ~= tb then
		return ta > tb
	    end
	    return order[a] < order[b]
	end)
	local known = 0
	for _, name in ipairs(names) do
	    if sung_at[name] ~= nil then
		known = known + 1
	    end
	end
	local remains = remains_of[sid] or {}
	-- 自分の記録に紐付かない実測。アドオンを読み直す前に歌った分がこれ
	local spare = #remains - known
	for i, name in ipairs(names) do
	    if lacking[sid] then
		remain_of_name[name] = 0  -- メンバーに入っていないので歌い直す
	    elseif i <= known then
		-- 自分が歌った曲。後から歌ったものほど残りが長い
		remain_of_name[name] = remains[i] or 0
	    elseif #names == 1 then
		-- その status を使う曲が plan に1つしかないなら、実測が
		-- どれに当たるかは自明。歌っていなくても残りが分かる
		remain_of_name[name] = remains[i] or 0
	    elseif i - known <= spare then
		-- 乗ってはいるが、実測のどれに当たるかは決められない。
		-- ここで残りを当てずっぽうに割り当てると、残りが沢山ある曲を
		-- 「切れかけ」と読んで上書きしてしまう
		remain_of_name[name] = M.UNKNOWN
	    else
		remain_of_name[name] = 0  -- 枠が足りていないので乗っていない
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
