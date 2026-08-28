-- 詩人の歌の選び方 (job/song_plan.lua) のテスト
--
-- job/BRD.lua 本体は io/chat や windower を引くのでここでは触らない。
-- 判断だけを純関数に切り出してあるので、それを直接叩く。

package.path = package.path .. ";../?.lua"
local song_plan = require "job/song_plan"

local ng = 0
local function check(name, got, want)
    if got == want then
	print(("  ok   %s = %s"):format(name, tostring(got)))
    else
	ng = ng + 1
	print(("  NG   %s = %s (want %s)"):format(name, tostring(got),
					          tostring(want)))
    end
end

-- 猛者のメヌエット V/IV/III は status 198 を共有する。
-- 栄光の凱旋マーチは 214、エチュード 2種は 215 を共有する
local PLAN = { "栄光の凱旋マーチ", "猛者のメヌエットV", "猛者のメヌエットIV",
	       "猛者のメヌエットIII", "怪力のエチュード", "妙技のエチュード" }
local STATUS = {
    ["栄光の凱旋マーチ"] = 214,
    ["猛者のメヌエットV"] = 198,
    ["猛者のメヌエットIV"] = 198,
    ["猛者のメヌエットIII"] = 198,
    ["怪力のエチュード"] = 215,
    ["妙技のエチュード"] = 215,
}

print("=== plan_remains: family の突き合わせ")
do
    -- V を 300 秒前、IV を 200 秒前、III を 100 秒前に歌った。
    -- 新しく歌ったものほど残りが長いので、III=400 IV=300 V=200 に対応する
    local sung = { ["猛者のメヌエットV"] = 1000, ["猛者のメヌエットIV"] = 1100,
		   ["猛者のメヌエットIII"] = 1200 }
    local r = song_plan.plan_remains(PLAN, STATUS,
				     { [198] = {400, 300, 200} }, sung, nil)
    check("マーチ (実測なし)", r[1], 0)
    check("メヌエットV (一番古い)", r[2], 200)
    check("メヌエットIV", r[3], 300)
    check("メヌエットIII (一番新しい)", r[4], 400)
end

print("=== plan_remains: 実測が足りない (1曲切れた)")
do
    local sung = { ["猛者のメヌエットV"] = 1000, ["猛者のメヌエットIV"] = 1100,
		   ["猛者のメヌエットIII"] = 1200 }
    local r = song_plan.plan_remains(PLAN, STATUS,
				     { [198] = {400, 300} }, sung, nil)
    check("一番古い V が切れた", r[2], 0)
    check("メヌエットIV", r[3], 300)
    check("メヌエットIII", r[4], 400)
end

print("=== plan_remains: 何も歌っていない / 実測ゼロ")
do
    local r = song_plan.plan_remains(PLAN, STATUS, {}, {}, nil)
    for i = 1, #PLAN do
	check("全曲 0 ["..i.."]", r[i], 0)
    end
end

print("=== plan_remains: 自分で歌っていない曲は不明にする (再読込直後)")
do
    -- my_song が空。実測は3件あるが、どれがどの曲かは決められない。
    -- plan の順で当てずっぽうに割り当てると、残り 400 秒の曲を「残り 200 秒」
    -- と読んで上書きしてしまう。触らない事にする
    local r = song_plan.plan_remains(PLAN, STATUS,
				     { [214] = {350}, [198] = {400, 300, 200},
				       [215] = {280, 250} }, {}, nil)
    check("マーチは family に1曲なので自明", r[1], 350)
    check("メヌエットV", r[2], song_plan.UNKNOWN)
    check("メヌエットIV", r[3], song_plan.UNKNOWN)
    check("メヌエットIII", r[4], song_plan.UNKNOWN)
    check("エチュード (怪力)", r[5], song_plan.UNKNOWN)
    check("エチュード (妙技)", r[6], song_plan.UNKNOWN)
    check("不明なら歌い始めない", song_plan.should_sing(r), false)
    check("不明なら選ばない", song_plan.pick_song(PLAN, r), nil)
end

print("=== plan_remains: 実測が足りない分は 0 (乗っていない)")
do
    -- 3曲ぶん要るのに実測が1件。歌っていないので対応は決められないが、
    -- 2曲は本当に乗っていないので、そこは歌い直す
    local r = song_plan.plan_remains(PLAN, STATUS, { [198] = {400} }, {}, nil)
    check("1件ぶんは不明", r[2], song_plan.UNKNOWN)
    check("残りは乗っていない", r[3], 0)
    check("残りは乗っていない", r[4], 0)
    check("乗っていない曲があれば歌う", song_plan.should_sing(r), true)
end

print("=== plan_remains: 歌った曲と歌っていない曲が混ざる")
do
    -- V だけ自分で歌った。実測3件のうち一番長いのが V。
    -- 残り2件は再読込前の分なので、IV/III のどちらかは決められない
    local r = song_plan.plan_remains(PLAN, STATUS,
				     { [198] = {400, 300, 200} },
				     { ["猛者のメヌエットV"] = 1000 }, nil)
    check("歌った V は実測の最長", r[2], 400)
    check("歌っていない IV は不明", r[3], song_plan.UNKNOWN)
    check("歌っていない III は不明", r[4], song_plan.UNKNOWN)
end

print("=== plan_remains: メンバーに欠けている family は 0 に落とす")
do
    local r = song_plan.plan_remains(PLAN, STATUS,
				     { [214] = {600}, [198] = {500, 400, 300} },
				     {}, { [198] = true })
    check("マーチは実測どおり", r[1], 600)
    check("メヌエットは欠け扱い", r[2], 0)
end

print("=== max_songs: 楽器の歌数+とクラリオンコールで本数が決まる")
do
    check("楽器なし", song_plan.max_songs(nil, false), 2)
    check("知らない楽器 (ギャッラルホルン)", song_plan.max_songs(18840, false), 2)
    check("マルシュアス (歌数+ なし)", song_plan.max_songs(21398, false), 2)
    check("ミラクルチアー", song_plan.max_songs(22249, false), 3)
    check("ブラーハープ", song_plan.max_songs(21400, false), 3)
    check("ブラーハープ+1", song_plan.max_songs(21401, false), 3)
    check("テルパンダー", song_plan.max_songs(21407, false), 3)
    check("ラックナシェード (歌数+1)", song_plan.max_songs(22306, false), 3)
    check("ラックナシェード (歌数+2)", song_plan.max_songs(22307, false), 4)
    -- 同じ名前で歌数が違うので、名前では引けない
    check("ダウルダヴラ Lv85 (歌数+ なし)", song_plan.max_songs(18574, false), 2)
    check("ダウルダヴラ Lv90", song_plan.max_songs(18575, false), 3)
    check("ダウルダヴラ Lv95", song_plan.max_songs(18576, false), 3)
    check("ダウルダヴラ Lv99", song_plan.max_songs(18571, false), 4)
    check("ダウルダヴラ Lv99 (別 id)", song_plan.max_songs(18839, false), 4)
    -- レイヴの中でしか歌数+1 が乗らないので数えない
    check("カマラデリハープ", song_plan.max_songs(21408, false), 2)
    check("クラリオンコール中は +1", song_plan.max_songs(18571, true), 5)
    check("楽器なし + クラリオンコール", song_plan.max_songs(nil, true), 3)
end

print("=== keep_plan: 維持する曲を選ぶ")
do
    -- 何もかかっていなければ、優先順の上から target 曲
    local t, r = song_plan.keep_plan(PLAN, {0, 0, 0, 0, 0, 0}, 2)
    check("2曲になる", #t, 2)
    check("優先順の上から埋める", t[1], "栄光の凱旋マーチ")
    check("2曲目", t[2], "猛者のメヌエットV")
    check("残りも同じ並びで返る", r[2], 0)
    check("0 本なら空", #song_plan.keep_plan(PLAN, {0,0,0,0,0,0}, 0), 0)
    check("本数が足りていれば全曲",
	  #song_plan.keep_plan(PLAN, {0,0,0,0,0,0}, 10), #PLAN)
    check("切り詰めた plan では溢れた曲を選ばない",
	  song_plan.pick_song(t, r), "栄光の凱旋マーチ")
end

print("=== keep_plan: 今かかっている曲は落とさない")
do
    -- 優先順が下の 5,6番目がかかっている。target は 2 曲だが、落とすと
    -- 誰も歌い直さないまま切れて枠が減るので、維持する側に入れる
    local t, r = song_plan.keep_plan(PLAN, {0, 0, 0, 0, 300, 200}, 2)
    check("かかっている2曲だけ", #t, 2)
    check("1曲目", t[1], "怪力のエチュード")
    check("2曲目", t[2], "妙技のエチュード")
    check("残りも同じ並び", r[1], 300)
    -- 楽器から可能な本数 (target) より多くかかっている時も、その本数を維持する
    local t2 = song_plan.keep_plan(PLAN, {300, 300, 300, 300, 300, 0}, 4)
    check("target を超えていても5曲維持", #t2, 5)
    check("溢れている分は足さない", t2[5], "怪力のエチュード")
    -- かかっている分が target に足りなければ、優先順の上から足す
    local t3 = song_plan.keep_plan(PLAN, {0, 0, 0, 0, 300, 0}, 3)
    check("足りない分を優先順の上から足す", #t3, 3)
    check("かかっている曲", t3[3], "怪力のエチュード")
    check("足した曲", t3[1], "栄光の凱旋マーチ")
    check("足した曲", t3[2], "猛者のメヌエットV")
    -- 不明 (乗ってはいる) も枠を押さえているものとして数える
    local t4 = song_plan.keep_plan(PLAN,
				   {song_plan.UNKNOWN, song_plan.UNKNOWN,
				    0, 0, 0, 0}, 2)
    check("不明は落とさない", #t4, 2)
    check("不明の曲", t4[1], "栄光の凱旋マーチ")
end

print("=== should_sing")
do
    check("1曲が 59 秒", song_plan.should_sing({300, 300, 59}), true)
    check("2曲が 119 秒", song_plan.should_sing({300, 119, 119}), true)
    check("1曲だけ 119 秒", song_plan.should_sing({300, 300, 119}), false)
    check("全曲 300 秒", song_plan.should_sing({300, 300, 300}), false)
    check("境界: 60 秒ちょうどが1曲", song_plan.should_sing({300, 300, 60}), false)
    check("境界: 120 秒ちょうどが2曲", song_plan.should_sing({300, 120, 120}), false)
    check("未掛かりが1曲", song_plan.should_sing({300, 300, 0}), true)
end

print("=== pick_song: 未掛かりは優先順、歌い直しは切れかけ順")
do
    -- 全部乗っているなら、閾値割れの中で残りの一番短いものを歌い直す。
    -- 優先順で選ぶと、切れかけの曲を後回しにして枠を落としてしまう
    check("閾値割れが2曲なら残りの短い方",
	  song_plan.pick_song(PLAN, {100, 300, 300, 50, 300, 300}),
	  "猛者のメヌエットIII")
    check("閾値割れが1曲ならその曲",
	  song_plan.pick_song(PLAN, {300, 300, 300, 50, 300, 300}),
	  "猛者のメヌエットIII")
    check("同じ残りなら優先順の上",
	  song_plan.pick_song(PLAN, {50, 300, 300, 50, 300, 300}),
	  "栄光の凱旋マーチ")
    -- 乗っていない曲は枠を増やす歌。切れかけより先に、優先順の上から埋める
    check("未掛かりがあれば優先順の上から",
	  song_plan.pick_song(PLAN, {300, 0, 300, 10, 300, 300}),
	  "猛者のメヌエットV")
    check("全曲足りていれば nil",
	  song_plan.pick_song(PLAN, {300, 300, 300, 300, 300, 300}),
	  nil)
    check("境界: 120 秒ちょうどは選ばない",
	  song_plan.pick_song(PLAN, {120, 300, 300, 300, 300, 300}),
	  nil)
end

print("=== target_songs: 維持したい本数")
do
    local MIRACLE, DAURDABLA = 22249, 18839
    check("ミラクルチアー + ダウルダヴラ",
	  song_plan.target_songs(MIRACLE, DAURDABLA), 4)
    check("ダウルダヴラを持っていない",
	  song_plan.target_songs(MIRACLE, nil), 3)
    check("ミラクルチアーを持っていない",
	  song_plan.target_songs(nil, DAURDABLA), 4)
    check("どちらも無い", song_plan.target_songs(nil, nil), 2)
    -- クラリオンコールは数えない。切れた後に増やし直せないので、
    -- 数えると押し出し合いのまま歌い続ける事になる
    check("引数にクラリオンコールは無い", song_plan.target_songs(MIRACLE), 3)
end

print("=== want_instrument: 楽器の持ち替え")
do
    -- ミラクルチアーで3曲、クラリオンコール中は4曲まで載る。
    -- 目標はダウルダヴラ込みの4曲
    local MIRACLE_CAP, CLARION_CAP, TARGET = 3, 4, 4
    check("0曲", song_plan.want_instrument(0, MIRACLE_CAP, TARGET), "miracle")
    check("2曲", song_plan.want_instrument(2, MIRACLE_CAP, TARGET), "miracle")
    check("3曲でダウルダヴラ",
	  song_plan.want_instrument(3, MIRACLE_CAP, TARGET), "daurdabla")
    check("4曲でミラクルチアーに戻す",
	  song_plan.want_instrument(4, MIRACLE_CAP, TARGET), "miracle")
    -- クラリオンコール中はミラクルチアーのまま4曲目まで載る。
    -- ここでダウルダヴラに持ち替えると5曲目を歌ってしまう
    check("クラリオンコール中の3曲はミラクルチアー",
	  song_plan.want_instrument(3, CLARION_CAP, TARGET), "miracle")
    check("クラリオンコール中の4曲もミラクルチアー",
	  song_plan.want_instrument(4, CLARION_CAP, TARGET), "miracle")
    check("数え過ぎてもミラクルチアー",
	  song_plan.want_instrument(6, MIRACLE_CAP, TARGET), "miracle")
    -- ダウルダヴラを持っていなければ目標は3曲。持ち替えようとしない
    check("目標に届いていれば持ち替えない",
	  song_plan.want_instrument(3, MIRACLE_CAP, 3), "miracle")
end

print(("=== brd_test: %d NG"):format(ng))
assert(ng == 0, "brd_test failed")
