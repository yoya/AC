-- コルセア

local M = {}

local utils = require 'utils'
local control = require 'control'
local io_chat = require 'io/chat'
local ac_data = require 'ac/data'
local task = require 'task'
local role_Melee = require 'role/Melee'
local incoming_text = require 'incoming/text'
local contents = require 'contents'
local pstatus = require 'player_status'

local split_multi = utils.string.split_multi
local phantom_roll_table = ac_data.phantom_roll_table

M.main_job_prob_table = {
    { 100, 60*10/2, 'input /ja クルケッドカード <me>', 3 }, -- 駄目元で
    { 100, 20*60/2, 'input /ja ランダムディール <me>', 3 },
    -- { 200, 60, 'input /ja コルセアズロール <me>; wait 2; input /ja ダブルアップ <me>', 0 },
--    { 50, 300, 'input /ja ブリッツァロール <me>', 3 },
--    { 100, 300/2, 'input /ja サムライロール  <me>', 3 },
--    { 100, 300/2, 'input /ja カオスロール  <me>', 3 },
--    { 100, 300, 'input /ja ファイターズロール  <me>', 3 },
    -- { 100, 300/2, 'input /ja メガスズロール  <me>', 3 },
    -- { 100, 300/2, 'input /ja ウィザーズロール  <me>', 3 },
    --[[
	{ 100, 300, 'input /ja ガランツロール <me>', 3 },
	{ 100, 300, 'input /ja ダンサーロール <me>', 3 },
    ]]
}

M.sub_job_prob_table = {
    -- { 100, 300, 'input /ja コルセアズロール <me>;'' wait 2; /ja ダブルアップ <me>', 3 },
    { 100, 60, 'input /ja コルセアズロール <me>', 3 },
    -- { 100, 300, 'input /ja サムライロール  <me>', 3 },
    -- { 100, 300, 'input /ja カオスロール  <me>', 3 },
    -- { 100, 300, 'input /ja ファイターズロール  <me>', 3 },
}

function phantom_roll(roll_name, on, delay)
    local c = "input /ja "..roll_name.." <me>"
    local level = task.PRIORITY_MIDDLE
    local period = 300 / 4
    if roll_name == "コルセアズロール" then
	level = task.PRIORITY_HIGH
	period = 20
    end
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, delay, 4, period, true)
    if on then
	--io_chat.set_next_color(6)
	--io_chat.print("phantom_roll", roll_name)
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end

local MAX_ACTIVE_ROLLS = 2
local ROLL_INTERVAL_SEC = 61  -- ロールのリキャストが60秒なので、それより後

-- 優先度の低いロールを撃ち潰して入れ替えるか
local ROLL_REPLACE_ENABLED = true
-- 入れ替えにフォールドを使うか。フォールドはバースト解除に取っておきたいので既定 off
local ROLL_REPLACE_USE_FOLD = false
-- バーストをフォールドで自分から解除するか。テキスト検知の取りこぼし対策
local ROLL_FOLD_BUST = true
-- 撃った直後は buff にまだ乗っていない。落ち着くまで入れ替え判定をしない
local ROLL_SETTLE_SEC = 10
local FOLD_RECAST_ID = 198  -- res/job_abilities.lua [178] Fold の recast_id
local BUST_STATUS_ID = 309  -- res/buffs.lua [309] バスト

-- ロールの候補表。上から順に match を見て、最初に一致したものを使う。
-- ac show roll がこの表をそのまま表示するので、条件は desc に書いておく。
--   rolls は優先順。上から空き枠の分だけ回す
--   note は効果のラベル (表示用。挙動には影響しない)
--   skip があり true を返す時、そのロールは候補から外れる
local ROLL_PLANS = {
    {
	key = "safety",
	desc = "need_safety (醴泉島のかえる / WKR ボス)",
	match = function(mob) return M.parent.need_safety() end,
	rolls = {
	    { name = "ダンサーロール",     note = "リジェネ" },
	    { name = "ガランツロール",     note = "防御" },
	    { name = "ニンジャロール",     note = "回避" },
	    { name = "メガスズロール",     note = "魔防御" },
	    { name = "ルーニストロール",   note = "魔回避" },
	},
    },
    {
	key = "high_hp",
	desc = "敵HP 40-100% (コルセアズを撃てるよう 33% で止める前段)",
	match = function(mob)
	    return mob ~= nil and 40 <= mob.hpp and mob.hpp <= 100
	end,
	rolls = {
	    { name = "サムライロール",     note = "ストアTP" },
	    { name = "カオスロール",       note = "攻撃力" },
	    { name = "ファイターズロール", note = "ダブルアタック" },
	},
    },
    {
	key = "low_hp",
	desc = "敵HP 3-30% (Apex で3%未満だと戦闘終了と重なる)",
	match = function(mob)
	    return mob ~= nil and 3 <= mob.hpp and mob.hpp <= 30
	end,
	rolls = {
	    { name = "コルセアズロール",   note = "経験値/CP",
	      skip = function() return contents.match_contents_name("sortie") end,
	      skip_desc = "ソーティでは使わない" },
	    { name = "ブリッツァロール",   note = "攻撃間隔短縮" },
	},
    },
}

-- 面倒を見るロール全部。plan に入らなかったものは毎 tick off にして予約を
-- 取り消す。ROLL_PLANS から作るので、候補を足した時の載せ忘れが起きない
local ALL_MANAGED_ROLLS = {}
do
    local seen = {}
    for _, p in ipairs(ROLL_PLANS) do
	for _, r in ipairs(p.rolls) do
	    if not seen[r.name] then
		seen[r.name] = true
		table.insert(ALL_MANAGED_ROLLS, r.name)
	    end
	end
    end
end

-- 自分が撃ったロール。名前 -> 最初に撃った時刻 (ダブルアップでは更新しない)
local my_roll_time = {}

-- ロール名(ja) -> status id。res.buffs で en が "Roll" で終わる31件がロール。
-- ダブルアップチャンス(308)とバスト(309)は含まれないので、ロールが増えても
-- ここを直さなくてよい
local roll_id_by_name = nil
local function get_roll_id_by_name()
    if roll_id_by_name == nil then
	local res = require('resources')
	roll_id_by_name = {}
	for id, buff in pairs(res.buffs) do
	    if type(buff.en) == "string" and buff.en:sub(-4) == "Roll" then
		roll_id_by_name[buff.ja] = id
	    end
	end
    end
    return roll_id_by_name
end

-- 自分が撃って今もかかっているロール。
-- player.buffs には他のコルセアがかけたロールも乗るので、そのままでは枠が
-- 埋まっていると誤判定する。自分が撃った記録との積を取る。
-- 切れた/バーストした記録はここで捨てるので、別途リセットは要らない。
-- 戻り値: { ロール名 = 撃った時刻 }, 個数
local function my_active_rolls(player)
    local active = {}
    local count = 0
    if player == nil or player.buffs == nil then
	return active, count
    end
    local id_by_name = get_roll_id_by_name()
    local buff_set = {}
    for _, id in ipairs(player.buffs) do
	buff_set[id] = true
    end
    -- pairs の途中で既存キーに nil を入れるのは Lua 5.1 で許されている
    for name, t in pairs(my_roll_time) do
	local id = id_by_name[name]
	if id ~= nil and buff_set[id] then
	    active[name] = t
	    count = count + 1
	else
	    my_roll_time[name] = nil
	end
    end
    return active, count
end

-- フォールドの残りリキャスト秒。取れない時は nil。
-- nil の時はどの分岐も「撃たない」側に倒れる
local function fold_recast()
    local recasts = windower.ffxi.get_ability_recasts()
    return recasts ~= nil and recasts[FOLD_RECAST_ID] or nil
end

-- バースト中か。バーストしたロールは解除するまで枠を1つ占有し続ける。
-- またフォールドはバーストを優先して消すので、入れ替えの狙いが外れる
local function is_busted(player)
    if player == nil or player.buffs == nil then
	return false
    end
    for _, id in ipairs(player.buffs) do
	if id == BUST_STATUS_ID then
	    return true
	end
    end
    return false
end

local function cast_fold(reason)
    if control.debug then
	io_chat.infof("roll: フォールド (%s)", reason)
    end
    -- command, delay, duration, period, eachfight
    task.set_task(task.PRIORITY_MIDDLE,
		  task.new_task("input /ja フォールド <me>", 0, 2, 10, false))
end

-- 今の状況で欲しいロールの優先順。roll_tick と show_roll が共用する。
-- 戻り値: ロール名の配列, 一致した ROLL_PLANS の要素 (無ければ nil)
local function current_roll_plan()
    local mob = windower.ffxi.get_mob_by_target("t")
    for _, p in ipairs(ROLL_PLANS) do
	if p.match(mob) then
	    local plan = {}
	    for _, r in ipairs(p.rolls) do
		if r.skip == nil or not r.skip() then
		    table.insert(plan, r.name)
		end
	    end
	    return plan, p
	end
    end
    return {}, nil
end

-- plan に対する判断。実行はしない。apply_roll_plan と show_roll が共用する。
-- ここを1つにしておかないと、表示と実際の挙動がずれる
local function decide_rolls(player, plan)
    local rank = {}
    for i, name in ipairs(plan) do
	if rank[name] == nil then rank[name] = i end
    end
    local d = {
	on_delay = {}, enabled = 0,
	rank_of = function(name) return rank[name] or math.huge end,
    }
    d.active, d.rolls_used = my_active_rolls(player)
    d.busted = is_busted(player)
    -- バーストしたロールもフォールドで消すまで枠を1つ占有し続ける
    d.used = d.rolls_used + (d.busted and 1 or 0)
    for name, t in pairs(d.active) do
	if d.oldest == nil or t < d.active[d.oldest] then d.oldest = name end
	if d.newest == nil or t > d.active[d.newest] then d.newest = name end
    end

    local room = MAX_ACTIVE_ROLLS - d.used
    for _, name in ipairs(plan) do
	if d.active[name] == nil and d.enabled < room then
	    d.on_delay[name] = d.enabled * ROLL_INTERVAL_SEC
	    d.enabled = d.enabled + 1
	end
    end
    -- バースト解除は枠の空きに関わらず出す。本命は incoming_text_handler の
    -- テキスト検知で、これは取りこぼした時の保険。task は command 文字列で
    -- 重複を弾くので、二重に積んでも1回しか出ない
    if d.busted and ROLL_FOLD_BUST and fold_recast() == 0 then
	d.replace = { action = "fold", drop = "バースト" }
    end
    if room > 0 then
	d.note = string.format("空き %d 枠%s", room,
			       d.busted and " (バースト解除中)" or "")
	return d
    end
    if d.busted then
	-- 枠は埋まっているが、バーストが解ければ空く。ここで入れ替え
	-- (最古を捨てる / フォールド) をやると、狙いどおりのロールが落ちない
	d.note = (d.replace ~= nil) and "バースト中。フォールドで解除する"
	    or "バースト中。フォールドの解除待ち"
	return d
    end
    if not ROLL_REPLACE_ENABLED then
	d.note = "枠が埋まっている (入れ替えは無効)"
	return d
    end
    local want = nil
    for _, name in ipairs(plan) do
	if d.active[name] == nil then
	    want = name
	    break
	end
    end
    if want == nil then
	d.note = "欲しいロールは全部かかっている"
	return d
    end
    local elapsed = os.time() - d.active[d.newest]
    if elapsed < ROLL_SETTLE_SEC then
	d.note = string.format("撃った直後 (%d/%d秒) なので待つ",
			       elapsed, ROLL_SETTLE_SEC)
	return d
    end
    -- 撃つと消えるのは常に一番古いロール。
    -- フォールドが消すのは「残り効果時間が一番長いロール」で、ロールした時の
    -- 装備が同じなら効果時間も同じになるので、実質は一番新しいロールになる。
    -- (ロールごとに装備を変えていると、この前提は崩れる)
    -- 古い方が価値が高い時だけ、フォールドで新しい方を落としに行く。
    -- 同順位なら無料の経路 (撃って最古を捨てる) に倒す
    local drop, need_fold
    if d.rank_of(d.oldest) < d.rank_of(d.newest) then
	drop, need_fold = d.newest, true
    else
	drop, need_fold = d.oldest, false
    end
    d.replace = { want = want, drop = drop, fold = need_fold, action = "none" }
    if d.rank_of(want) >= d.rank_of(drop) then
	d.note = string.format("%s より %s が優先。入れ替えない", want, drop)
    elseif not need_fold then
	d.on_delay[want] = 0  -- 撃てば drop(=最古) が消える
	d.enabled = d.enabled + 1
	d.replace.action = "roll"
	d.note = string.format("%s を捨てて %s に入れ替え", drop, want)
    elseif not ROLL_REPLACE_USE_FOLD then
	d.note = string.format("%s を落とすにはフォールドが要る (無効)", drop)
    elseif fold_recast() ~= 0 then
	d.note = string.format("%s を落としたいがフォールド残り %s 秒",
			       drop, tostring(fold_recast()))
    else
	d.replace.action = "fold"
	d.note = string.format("フォールドで %s を落として %s を入れる", drop, want)
    end
    return d
end

local function apply_roll_plan(player, plan)
    local d = decide_rolls(player, plan)
    if d.replace ~= nil and d.replace.action == "fold" then
	cast_fold(d.note or "-")
    end
    -- plan に入らなかったロールも必ず off にする。早期 return してしまうと、
    -- 既に積んだ予約が取り消されずに発火する (off は task.remove_task の経路)
    for _, name in ipairs(ALL_MANAGED_ROLLS) do
	local delay = d.on_delay[name]
	phantom_roll(name, delay ~= nil, delay or 0)
    end
    if control.debug and (d.used > 0 or d.enabled > 0) then
	io_chat.infof("roll: 枠 %d/%d、予約 %d 個 (%s)",
		      d.used, MAX_ACTIVE_ROLLS, d.enabled, d.note or "-")
    end
end

function roll_tick(player)
    -- plan が空でも呼ぶ。呼ばないと前の状況で積んだ予約が残って発火する
    apply_roll_plan(player, (current_roll_plan()))
end

-- ロールが2つある時だけ「古/新」を出す。1つの時は両方に該当してしまう
local function order_mark(d, name)
    if d.rolls_used < 2 then
	return ""
    elseif name == d.oldest then
	return " 古"
    elseif name == d.newest then
	return " 新"
    end
    return ""
end

-- 適用中の plan を1ロール1行で出す
local function show_plan_detail(p, d, now)
    for i, r in ipairs(p.rolls) do
	local skipped = r.skip ~= nil and r.skip()
	local t = d.active[r.name]
	local mark, state
	if skipped then
	    mark, state = "x", "除外: "..(r.skip_desc or "条件不一致")
	elseif t ~= nil then
	    mark = "o"
	    state = string.format("かかってる (%d秒経過%s)",
				  now - t, order_mark(d, r.name))
	elseif d.on_delay[r.name] ~= nil then
	    mark, state = "+", string.format("予約 delay=%d", d.on_delay[r.name])
	else
	    mark, state = "-", "待ち"
	end
	io_chat.set_next_color(skipped and 3 or 6)
	io_chat.printf("    %d %s %s (%s)  %s",
		       i, mark, r.name, r.note or "-", state)
    end
end

-- 適用外の plan を、優先順と条件だけ1行にまとめて出す
local function show_plan_compact(p, d)
    local parts = {}
    for i, r in ipairs(p.rolls) do
	local s = string.format("%d.%s(%s", i, r.name, r.note or "-")
	if r.skip_desc ~= nil then
	    s = s .. "/" .. r.skip_desc
	end
	s = s .. ")"
	if d.active[r.name] ~= nil then
	    s = "*" .. s  -- 今かかっている
	end
	table.insert(parts, s)
    end
    io_chat.set_next_color(7)
    io_chat.print("    " .. table.concat(parts, "  "))
end

-- ac show roll [all]
--   既定 : 適用中の plan だけ詳細、他は見出しだけ
--   all  : 適用外の plan も候補と条件を出す
function M.show_roll(player, mode)
    local show_all = (mode == "all")
    local plan, current = current_roll_plan()
    local d = decide_rolls(player, plan)
    local mob = windower.ffxi.get_mob_by_target("t")
    local now = os.time()

    io_chat.set_next_color(5)
    io_chat.printf("=== COR roll plan%s", show_all and " (all)" or "")
    io_chat.set_next_color(6)
    io_chat.printf("枠 %d/%d (ロール%d%s)  入れ替え:%s  フォールド:%s(残り%s秒)",
		   d.used, MAX_ACTIVE_ROLLS, d.rolls_used,
		   d.busted and " +バースト1" or "",
		   tostring(ROLL_REPLACE_ENABLED),
		   tostring(ROLL_REPLACE_USE_FOLD),
		   tostring(fold_recast()))
    if mob == nil then
	io_chat.print("ターゲット: なし")
    else
	io_chat.printf("ターゲット: %s HP %d%%", mob.name, mob.hpp)
    end

    for _, p in ipairs(ROLL_PLANS) do
	local is_current = (p == current)
	io_chat.set_next_color(is_current and 6 or 7)
	io_chat.printf("%s [%s] %s", is_current and "*" or " ", p.key, p.desc)
	if is_current then
	    show_plan_detail(p, d, now)
	elseif show_all then
	    show_plan_compact(p, d)
	end
    end
    if current == nil then
	io_chat.set_next_color(3)
	io_chat.print("  (どの条件にも一致しないので、今は回しません)")
    end
    if not show_all then
	io_chat.set_next_color(7)
	io_chat.print("  (候補を全部見るには ac show roll all)")
    end

    -- 今の plan に入っていないのにかかっているロール (入れ替え判断の対象)
    for name, t in pairs(d.active) do
	if d.rank_of(name) == math.huge then
	    io_chat.set_next_color(3)
	    io_chat.printf("  ! plan外 %s (%d秒経過%s)",
			   name, now - t, order_mark(d, name))
	end
    end

    io_chat.set_next_color(3)
    io_chat.printf("=> %s", d.note or "-")
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    if player.status == pstatus.ENGAGED then -- 戦闘中
	roll_tick(player)
    end
    -- ロールrecastを考慮してないので、駄目元のコルセアズロール。
end

-- ダブルアップの on/off
function phantom_roll_double_up(on)
    assert(type(on) == "boolean")
    local c = "input /ja ダブルアップ <me>"
    local level = task.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 2, 4, 5, false)  -- dalay:1 だとたまに失敗する
    if on == true then
	-- io_chat.set_next_color(6)
	-- io_chat.print("phantom_roll_double_up")
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end

-- 出目に応じてロールアップを続けるか否かの処理
function COR_phantom_roll_up(roll_name, roll_number, is_double_up)
    assert(type(roll_name) == "string")
    assert(type(roll_number) == "number")
    -- io_chat.set_next_color(6)
    -- io_chat.print("COR_phantom_roll_up", roll_name, roll_number)
    local full_name = roll_name.."ロール"
    -- 自分が撃ったロールとして覚える。呼び出し元が player.name で自分の行だけを
    -- 拾っているので、ここに来るのは自分の分だけ。ダブルアップでは更新しない。
    -- ダブルアップは効果時間を延ばさないので、消される順番が変わらないため。
    -- phantom_roll_table は一部のロールしか持っていないので、下の nil チェック
    -- より前に、res 由来の表で確かめて記録する
    if get_roll_id_by_name()[full_name] ~= nil then
	if not is_double_up or my_roll_time[full_name] == nil then
	    my_roll_time[full_name] = os.time()
	end
    end
    local roll_info = phantom_roll_table[full_name]
    if roll_info == nil then
	io_chat.set_next_color(3)
	io_chat.print("Unknown phantom roll:"..roll_name)
	return
    end
    if roll_number == roll_info.lucky then
	io_chat.set_next_color(6)
	io_chat.print(roll_name.."("..roll_number..") ラッキーロール！")
	return
    end
    if roll_number >= 6 then
	-- TODO: フォールド使える場合は return しない
	if roll_number == roll_info.unlucky then
	    if control.debug then
		io_chat.set_next_color(6)
		io_chat.print("アンラッキーロール("..roll_number..")！ > スネークアイ&ダブルアップ")
	    end
	    local c = "input /ja スネークアイ <me>; wait 2; input /ja ダブルアップ <me>"
	    task.set_task(task.PRIORITY_MIDDLE,
			 -- command, delay, duration, period, eachfight
			 task.new_task(c, 1, 1, 5, false))
	    return
	end
	if control.debug then
	     io_chat.set_next_color(6)
	     io_chat.print(roll_name.." "..roll_number.." で打ち止め ("..roll_info.lucky.."/"..roll_info.unlucky..")")
	end
	phantom_roll_double_up(false) -- たまに暴発するのを防ぎたい
	return
    end
    if control.debug then
	io_chat.set_next_color(6)
	io_chat.print("出目:"..roll_number.." => ダブルアップ！")
    end
    phantom_roll_double_up(true)
end

-- ロールの文字列を見つけたら動く。
function M.incoming_text_handler(text)
    local player = windower.ffxi.get_player()
    if player == nil or string.contains(text, player.name) == false then
	return
    end
    -- Upachanのダブルアップ\n→ファイターズロールの合計値が5になった！
    local s2 = split_multi(text, {'ダブルアップ', '→', 'ロール', 'が', 'に'})
    if s2 ~= nil then
	local roll_name = s2[3]
	local roll_number = tonumber(s2[5])
	COR_phantom_roll_up(roll_name, roll_number, true)
	return
    end
    -- Upachanのファイターズロール→合計値が5になった！
    local s = split_multi(text, {'の', 'ロール', 'が', 'に'})
    if s ~= nil then
	local roll_name = s[2]
	local roll_number = tonumber(s[4])
	COR_phantom_roll_up(roll_name, roll_number, false)
	return
    end
    if string.contains(text,"ロールがBust") then
	if control.debug then
	     io_chat.set_next_color(3)
	     io_chat.print("Bust => フォールド！")
	end
	local c = "input /ja フォールド <me>"
	task.set_task(task.PRIORITY_MIDDLE,
		     -- command, delay, duration, period, eachfight
		     task.new_task(c, 1, 1, 5, false))
	return
    end
end

M.battle_equip = {
    main = {
	21581, -- ロスタム
	21565, -- トーレット
    },
    sub = {
	21565, -- トーレット
    },
    head = {
	26657, -- ＬＡトリコルヌ+1 ロール性能+50
	24270, -- 無の面
	23732, -- マリグナスシャポー
	25614, -- アデマボンネット+1
    },
    body = {
	23733, -- マリグナスタバード
    },
    left_ring = {
	26229,  -- レコリング
	10772,  -- ペトロフリング
	26182,  -- シーリチリング+1
	26212,  -- ムンムリング
    },
    right_ring = {
	26186,  -- イラブラットリング
	26212,  -- ムンムリング
	26173,  -- アペートリング
	15543,  -- ラジャスリング
	26182,  -- シーリチリング+1
	26181,  -- シーリチリング
    },
}

M.roll_equip = {
    main = {
	21581, -- ロスタム
    },
    head = {
	26657, -- ＬＡトリコルヌ+1 ロール性能+50
    },
}

print(incoming_text, incoming_text.addListener)
M.listener_id = incoming_text.add_listener("ロール", M.incoming_text_handler)

return M
