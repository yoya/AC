-- 吟遊詩人

local M = {}

local command = require 'command'
local contents = require 'contents'
local io_chat = require 'io/chat'
local task = require 'task'
local role_Melee = require 'role/Melee'
local pstatus = require 'player_status'
local res_name = require 'res_name'
local ac_buff = require 'ac/buff'
local ac_party = require 'ac/party'
local song_plan = require 'job/song_plan'

M.main_job_prob_table = {
    -- { 100, 60, 'input /ma 魔法のフィナーレ <t>', 8, true },
    -- { 200, 120, 'input /ma 修羅のエレジー <t>', 8, true },
    -- 単体に入れたい時は "input /ja ピアニッシモ <me>; wait 2; " を前に付ける
    { 1000, 120, 'input /ma 魔物のレクイエムVII <t>', 8, true },
    -- { 200, 120, 'input /ma 光のスレノディII <t>', 8, true },
}

M.sub_job_prob_table = {
    { 300, 180/2, 'input /ma 無敵の進撃マーチ <me>', 8 },
    { 200, 180/2, 'input /ma 猛者のメヌエットIII <me>', 8 },
    -- { 200, 120, 'input /ma 戦場のエレジー <t>', 8, true },
}

--
-- 強化の歌
--
-- 歌うかどうかは残り時間で決める。周期では歌わない。
-- 判断そのものは job/song_plan.lua (純関数) にあり、ここは実測値を集めて
-- 渡し、決まった1曲を task に積むだけ。

-- 歌う曲。配列の順がそのまま優先順で、上から埋める。
-- 楽器で維持できる本数を超えた分は current_plan が切り捨てるので、
-- ここは多めに並べておいてよい (クラリオンコール中は1曲増える)
local SONG_PLANS = {
    attack = { "栄光の凱旋マーチ", "猛者のメヌエットV", "猛者のメヌエットIV",
	       "怪力のエチュード", "妙技のエチュード" },
    safety = { "重装騎兵のミンネV", "闘龍士のマンボ", "栄光の凱旋マーチ",
	       "重装騎兵のミンネIV", "戦士達のピーアンVI"  },
}

-- 歌唱時間 (res/spells.lua の cast_time = 8) に余裕を足したもの。
-- task はこの間だけ次のコマンドを止める
local SONG_DURATION = 12

-- 同じ曲を続けて積み直さないための最低間隔。歌うかどうかは残り時間で
-- 決めるので、ここを長くする必要はない
local SONG_PERIOD = 12

-- 歌の効果範囲。これより離れたメンバーには入らないので、欠けていても見ない
local SONG_RANGE = 10

-- パーティメンバーの歌の欠けを、歌い直しの判断に使うか。
-- 0x076 の復号 (ビットの並び順) は実機で検証していない。間違っていると
-- 「常に欠けている」と読めてしまい、今より歌い過ぎる方に倒れる。
-- ac show song all でメンバーの本数が実際と合う事を確かめてから true にする
local USE_MEMBER_LACK = false

-- 積んだ歌の着弾を待つ上限。歌が中断されると残りが増えないので、
-- いつまでも待たない
local PENDING_MAX = 30

-- クラリオンコールの status (res/job_abilities.lua)。歌える本数が1曲増える
local CLARION_CALL_STATUS = 499

-- task が実行する時に呼ばれるコマンド。歌った時刻をここで記録する
local SONG_COMMAND = "//brdsong "

-- 自分が歌った時刻。歌名 => 時刻。
-- set_task の時点ではなく、task が実際にコマンドを送った瞬間に記録する。
-- 積んだ時刻で記録すると、キューで待っている間のぶん残りを長く見積もる
local my_song = {}

-- 積んだけれど、まだ着弾を確認していない歌の status。
-- 着弾するまで次を積まない。判定できないまま次を積むと、まだ残り 0 に
-- 見えている曲をもう一度積んだり、対応がずれたまま別の曲を選んだりする。
--
-- 「0x063 が来たか」では判定できない (歌に限らずどのバフが変わっても飛ぶ)。
-- 「その曲の残りが増えたか」でも判定できない (status を共有する曲は、歌った
-- 瞬間に対応が入れ替わって別の曲の残りを拾う)。
-- そこで、その status の実測そのものを見る。歌が乗れば、本数が増えるか、
-- 一番短い残りが伸びるかのどちらかが必ず起きる
local pending_sid = nil
local pending_count = 0
local pending_min = 0
local pending_at = 0

task.add_command_handler(SONG_COMMAND, function(song_name)
    my_song[song_name] = os.time()
    command.send("input /song "..song_name.." <me>")
end)

-- 歌名(ja) => status id。res.spells の type == "BardSong" から作る。
-- job/COR.lua の get_roll_id_by_name と同じ作り。
-- status を共有する曲があるので、ID から曲名は引けない (逆向きは作らない)
local song_status_by_name = nil
local function get_song_status_by_name()
    if song_status_by_name == nil then
	local res = require('resources')
	song_status_by_name = {}
	for _, spell in pairs(res.spells) do
	    if spell.type == "BardSong" and type(spell.ja) == "string" then
		song_status_by_name[spell.ja] = spell.status
	    end
	end
    end
    return song_status_by_name
end

-- 今装備している楽器の item id。range スロットが空なら nil。
-- 歌える本数は歌い終わった瞬間の楽器で決まるので、判断のたびに見る。
-- 名前ではなく id を返す。ダウルダヴラとラックナシェードは同じ名前で
-- 歌数が違うものがあり、名前では区別できない
local function equipped_instrument_id()
    local items = windower.ffxi.get_items()
    local equipment = items ~= nil and items.equipment or nil
    if equipment == nil or equipment.range == nil or equipment.range <= 0 then
	return nil  -- 楽器を持っていない (短剣で殴っている時など)
    end
    local bag_items = windower.ffxi.get_items(equipment.range_bag)
    local item = bag_items ~= nil and bag_items[equipment.range] or nil
    if item == nil or item.id == nil then
	return nil
    end
    return item.id
end

local function has_clarion_call(player)
    for _, id in ipairs(player.buffs or {}) do
	if id == CLARION_CALL_STATUS then
	    return true
	end
    end
    return false
end

-- 今の楽器とクラリオンコールで、同時に維持できる歌の本数
local function max_songs(player)
    return song_plan.max_songs(equipped_instrument_id(),
			       has_clarion_call(player))
end

-- 今の状況で歌う曲の並び。
-- need_safety() は今のターゲットで決まるので、戦闘の切れ目で裏返る。
-- 構成が入れ替わると新しい方の曲が全部「未掛かり」に見えて全曲歌い直しに
-- なるので、一定時間続いた時だけ切り替える。
--
-- 最後に、維持できる本数まで切り詰める。切り詰めないと、新しい歌が古い歌を
-- 押し出して、押し出された曲が「残り 0」に見え、休みなく歌い続ける
local PLAN_SWITCH_SEC = 10
local plan_key = "attack"
local plan_pending = nil
local plan_pending_at = 0

local function current_plan(player)
    local want = M.parent.need_safety() and "safety" or "attack"
    local now = os.time()
    if want == plan_key then
	plan_pending = nil
    elseif plan_pending ~= want then
	plan_pending = want
	plan_pending_at = now
    elseif now - plan_pending_at >= PLAN_SWITCH_SEC then
	plan_key = want
	plan_pending = nil
    end
    return song_plan.trim(SONG_PLANS[plan_key], max_songs(player))
end

-- plan を status id ごとの本数に畳む
local function plan_status_count(plan, status_of)
    local need = {}
    for _, name in ipairs(plan) do
	local sid = status_of[name]
	if sid ~= nil then
	    need[sid] = (need[sid] or 0) + 1
	end
    end
    return need
end

-- 歌の範囲内にいるパーティメンバーで、本数が足りていない family を返す。
-- メンバー側は 0x076 の有無しか取れないので、見られるのは本数だけ。
-- 歌えば範囲内の全員に入るので、対象を変える必要はない
local function lacking_status(plan, status_of)
    local lacking = {}
    local me = windower.ffxi.get_mob_by_target("me")
    if not USE_MEMBER_LACK or me == nil or me.x == nil then
	return lacking
    end
    local need = plan_status_count(plan, status_of)
    local party = windower.ffxi.get_party()
    for i = 1, 5 do
	local member = party["p"..i]
	local mob = member ~= nil and member.mob or nil
	if mob ~= nil and mob.x ~= nil then
	    local dx = mob.x - me.x
	    local dy = mob.y - me.y
	    if math.sqrt(dx*dx + dy*dy) <= SONG_RANGE then
		for sid, n in pairs(need) do
		    local c = ac_party.member_buff_count(mob.id, sid)
		    if c ~= nil and c < n then
			lacking[sid] = true
		    end
		end
	    end
	end
    end
    return lacking
end

-- 直近で plan を一巡して歌ったのに、まだ枠が埋まっていないか。
-- plan は current_plan が維持できる本数まで切り詰めてあるので、埋まらない
-- のは song_plan.EXTRA_SONGS_BY_ID の見積もりが実機とずれている時。
-- 放っておくと新しい歌が古い歌を押し出して永久に歌い続ける
local WARN_INTERVAL = 300
local warned_at = 0
local function warn_overflow(plan, remains)
    local now = os.time()
    local window = #plan * SONG_DURATION * 2
    for _, name in ipairs(plan) do
	local at = my_song[name]
	if at == nil or now - at > window then
	    return  -- 直近で全曲を歌ってはいないので、判断できない
	end
    end
    for _, r in ipairs(remains) do
	if r <= 0 then
	    if now - warned_at > WARN_INTERVAL then
		warned_at = now
		io_chat.warnf("歌が %d 曲は維持できていません。"..
			      "song_plan.EXTRA_SONGS_BY_ID を見直してください",
			      #plan)
	    end
	    return
	end
    end
end

-- plan の各曲の残り秒を出す。表示コマンドと共用する
local function plan_remains(plan)
    local status_of = get_song_status_by_name()
    local remains_of = {}
    for _, name in ipairs(plan) do
	local sid = status_of[name]
	if sid ~= nil and remains_of[sid] == nil then
	    remains_of[sid] = ac_buff.self_remains(sid)
	end
    end
    return song_plan.plan_remains(plan, status_of, remains_of, my_song,
				  lacking_status(plan, status_of))
end

-- status_id の実測の、本数と一番短い残り。self_remains は降順なので末尾が最短
local function family_state(sid)
    local rs = sid ~= nil and ac_buff.self_remains(sid) or nil
    if rs == nil then
	return 0, 0
    end
    return #rs, rs[#rs] or 0
end

local function song_tick(player)
    -- 待機中と戦闘中だけ。死亡/イベント/休憩/マウント中は歌えない
    if player.status ~= pstatus.IDLE and player.status ~= pstatus.ENGAGED then
	return
    end
    -- 0x063 をまだ受けていない間は残り時間が分からない。未掛かり扱いで
    -- 歌い出すと今より無駄になるので、届くまで何もしない
    if ac_buff.self_updated_at == nil then
	return
    end
    -- 積んだ歌が着弾するまで次を積まない
    if pending_sid ~= nil then
	local count, min = family_state(pending_sid)
	if count > pending_count or min > pending_min or
	    os.time() - pending_at >= PENDING_MAX then
	    pending_sid = nil  -- 着弾した、または中断されたので諦める
	else
	    return
	end
    end
    local plan = current_plan(player)
    local remains = plan_remains(plan)
    warn_overflow(plan, remains)
    if not song_plan.should_sing(remains) then
	return
    end
    local name = song_plan.pick_song(plan, remains)
    if name == nil then
	return
    end
    local sid = get_song_status_by_name()[name]
    if sid ~= nil then
	pending_sid = sid
	pending_count, pending_min = family_state(sid)
	pending_at = os.time()
    end
    -- command, delay, duration, period, eachfight
    task.set_task(task.PRIORITY_MIDDLE,
		  task.new_task(SONG_COMMAND..name, 0, SONG_DURATION,
				SONG_PERIOD, false))
end

-- ララバイは強化ではなく敵への睡眠。残り時間の管理とは別枠で、
-- ソーティの戦闘中だけ <t> に歌う (元の song_tick の挙動そのまま)
local function lullaby(song_name, on, delay)
    -- command, delay, duration, period, eachfight
    local t = task.new_task("input /song "..song_name.." <t>", delay, 10, 24, true)
    if on then
	task.set_task(task.PRIORITY_MIDDLE, t)
    else
	task.remove_task(task.PRIORITY_MIDDLE, t)
    end
end

local function lullaby_tick(player)
    local on = contents.match_contents_name("sortie") and
	player.status == pstatus.ENGAGED
    lullaby("魔物達のララバイ", on, 0)
    lullaby("魔物達のララバイII", on, 20)
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    song_tick(player)
    lullaby_tick(player)
end

-- ac show song [all]
-- 判断に使っている値をそのまま出す。USE_MEMBER_LACK を有効にしてよいか、
-- 換算定数がずれていないかを、実機で確かめる為の窓口でもある
function M.show_song(player, arg)
    local plan = current_plan(player)
    local status_of = get_song_status_by_name()
    local remains = plan_remains(plan)
    local now = os.time()
    io_chat.set_next_color(5)
    io_chat.print("=== song")
    if ac_buff.self_updated_at == nil then
	io_chat.warn("まだバフの残り時間 (0x063 Order 9) を受け取っていません")
    end
    for i, name in ipairs(plan) do
	local at = my_song[name]
	-- 自分で歌っていない曲は、実測のどれに当たるか決められない
	local remain = remains[i] == song_plan.UNKNOWN and "不明"
	    or (math.floor(remains[i]).."秒")
	io_chat.printf("%d %s status:%s 残り:%s 歌った:%s",
		       i, name, tostring(status_of[name]), remain,
		       at == nil and "-" or (now - at).."秒前")
    end
    io_chat.set_next_color(6)
    local inst = equipped_instrument_id()
    io_chat.printf("楽器:%s クラリオンコール:%s 維持できる本数:%d (plan %d曲中%d曲)",
		   inst == nil and "なし"
		       or (res_name.item_ja(inst).."("..inst..")"),
		   tostring(has_clarion_call(player)), max_songs(player),
		   #SONG_PLANS[plan_key], #plan)
    io_chat.printf("歌う:%s 次の曲:%s メンバー参照:%s",
		   tostring(song_plan.should_sing(remains)),
		   tostring(song_plan.pick_song(plan, remains)),
		   tostring(USE_MEMBER_LACK))
    if arg ~= "all" then
	return
    end
    io_chat.set_next_color(5)
    io_chat.print("--- 0x063 自分のバフ")
    for _, b in ipairs(ac_buff.self_all()) do
	io_chat.printf("id:%d raw:%d 残り:%s", b.id, b.raw,
		       b.expiry == nil and "換算できず"
			   or (math.floor(b.expiry - now).."秒"))
    end
    -- 0x076 の復号が合っているかは、ここの本数が実際と合うかで見る
    io_chat.print("--- 0x076 メンバーの歌 (範囲内)")
    for sid, n in pairs(plan_status_count(plan, status_of)) do
	local line = "status:"..sid.." 必要:"..n
	for id, info in pairs(ac_party.member_table) do
	    local c = ac_party.member_buff_count(id, sid)
	    line = line.."  "..tostring(info.name)..":"..tostring(c)
	end
	io_chat.print(line)
    end
end

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local ja_list = { "クラリオンコール", "ナイチンゲール", "ソウルボイス"}
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	task.set_task(level, task.new_task(c, (i-1)*2, 2, 10, false))
    end
    windower.ffxi.run(false)
    level = task.PRIORITY_HIGH
    local song_list = { "栄光の凱旋マーチ", "猛者のメヌエットV",
		       "怪力のエチュード", "妙技のエチュード",
		       "剣豪のマドリガル", "猛者のメヌエットV",
		       "栄光の凱旋マーチ" }
    for i, song_name in ipairs(song_list) do
	-- 通常の歌と同じ経路にして、歌った時刻を残す
	local c = SONG_COMMAND..song_name
	-- command, delay, duration, period, eachfight
	local task_obj = task.new_task(c, 6+(i-1)*2, 5, 180/2, false)
	task.set_task(level, task_obj)
    end

end

M.attack_equip = {
    main = {
	21565, -- トーレット
    },
    sub = {
	21565, -- トーレット
	21585, -- クレパスクラナイフ
    },
    body = {
	25786, -- アシェーラハーネス
    },
    left_ring = {
        26229,  -- レコリング
        26190,  -- 月光の指輪
	26189,  -- 月明の指輪
        26182,  -- シーリチリング+1
        26212,  -- ムンムリング
    },
    right_ring = {
        26173,  -- アペートリング
        15543,  -- ラジャスリング
        26182,  -- シーリチリング+1
	26189,  -- 月明の指輪
        26181,  -- シーリチリング
    },
}

return M
