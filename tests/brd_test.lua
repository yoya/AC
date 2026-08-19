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

print("=== pick_song: 優先順の上位から")
do
    -- 切れかけは 4番目 (メヌエットIII) だが、1番目のマーチも閾値割れなので
    -- 優先順の上のマーチを先に埋める
    check("上位が閾値割れなら上位",
	  song_plan.pick_song(PLAN, {100, 300, 300, 50, 300, 300}),
	  "栄光の凱旋マーチ")
    check("上位が足りていれば切れかけ",
	  song_plan.pick_song(PLAN, {300, 300, 300, 50, 300, 300}),
	  "猛者のメヌエットIII")
    check("全曲足りていれば nil",
	  song_plan.pick_song(PLAN, {300, 300, 300, 300, 300, 300}),
	  nil)
end

print(("=== brd_test: %d NG"):format(ng))
assert(ng == 0, "brd_test failed")
