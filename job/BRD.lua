-- 吟遊詩人

local M = {}

local command = require 'command'
local contents = require 'contents'
local io_chat = require 'io/chat'
local task = require 'task'
local acmob = require 'mob'
local role_Melee = require 'role/Melee'
local pstatus = require 'player_status'
local res_name = require 'res_name'
local ac_buff = require 'ac/buff'
local ac_party = require 'ac/party'
local ac_equip = require 'ac/equip'
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
-- 何曲維持するかは song_plan.keep_plan が決める (自分から増やすのは
-- target_songs まで。それを超えて既にかかっている曲は維持する) ので、
-- ここは多めに並べておいてよい
local SONG_PLANS = {
    attack = { "栄光の凱旋マーチ", "猛者のメヌエットV",
	       "怪力のエチュード", "妙技のエチュード",
	       "猛者のメヌエットIV" },
    safety = { "重装騎兵のミンネV", "闘龍士のマンボ", "栄光の凱旋マーチ",
	       "重装騎兵のミンネIV", "戦士達のピーアンVI" },
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

-- コマンドを送ってから着弾を待つ上限。歌が中断されると残りが増えないので、
-- いつまでも待たない。歌唱時間 (8秒) に 0x063 が届くまでの余裕を足したもの
local PENDING_MAX = 30
-- 積んでからコマンドが出るまでの上限。task のキューが詰まっている時に、
-- 出ない歌を待ち続けて他の曲まで切らさない為
local QUEUE_MAX = 60

-- クラリオンコールの status (res/job_abilities.lua)。歌える本数が1曲増える
local CLARION_CALL_STATUS = 499

-- task が実行する時に呼ばれるコマンド。実体は song_sent
local SONG_COMMAND = "//brdsong "

-- 自分が歌った時刻。歌名 => 時刻。
-- 記録するのは「着弾を確認した瞬間」。コマンドを送った時点で記録すると、
-- 中断された歌 (移動中・沈黙・戦闘不能) まで歌った事になる。
-- status を共有する曲は、この時刻の新しい順と実測の長い順を突き合わせて
-- 対応を決めているので、乗っていない歌を「一番新しく歌った」と記録すると
-- 対応が入れ替わり、まだ残りのある曲を歌い直して、本当に切れかけの曲を
-- そのまま切らす (4曲が3曲に減る)。
-- 着弾で記録する限り、時刻の新しい順と残りの長い順は必ず一致する
local my_song = {}

-- 積んだけれど、まだ着弾を確認していない歌。
--   name  : 歌名
--   sid   : status id
--   count : コマンドを送った時の、その status の本数
--   min   : コマンドを送った時の、その status の一番短い残り
--   at    : コマンドを送った時刻 (まだ送っていなければ積んだ時刻)
--   sent  : コマンドを送ったか
--   want  : その歌の為に選んだ楽器。着弾するまで持ち替え直さない為
-- 着弾するまで次を積まない。判定できないまま次を積むと、まだ残り 0 に
-- 見えている曲をもう一度積んだり、対応がずれたまま別の曲を選んだりする。
--
-- 「0x063 が来たか」では判定できない (歌に限らずどのバフが変わっても飛ぶ)。
-- 「その曲の残りが増えたか」でも判定できない (status を共有する曲は、歌った
-- 瞬間に対応が入れ替わって別の曲の残りを拾う)。
-- そこで、その status の実測そのものを見る。歌が乗れば、本数が増えるか、
-- 一番短い残りが伸びるかのどちらかが必ず起きる。
-- 見るのは「コマンドを送った時」の値。積んだ時の値と比べると、キューで
-- 待っている間に同じ status の曲が切れただけで「着弾した」と読んでしまう
local pending = nil

-- 歌名(ja) => status id。res.spells の type == "BardSong" から作る。
-- job/COR.lua の get_roll_id_by_name と同じ作り。
-- status を共有する曲があるので、ID から曲名は引けない (逆向きは作らない)。
-- 歌の status の集合 (何本かかっているかを数える為) も同じ所で作る
local song_status_by_name = nil
local song_status_set = nil
local function build_song_status()
    if song_status_by_name ~= nil then
	return
    end
    local res = require('resources')
    song_status_by_name = {}
    song_status_set = {}
    for _, spell in pairs(res.spells) do
	if spell.type == "BardSong" and type(spell.ja) == "string" then
	    song_status_by_name[spell.ja] = spell.status
	    if type(spell.status) == "number" and spell.status > 0 then
		song_status_set[spell.status] = true
	    end
	end
    end
end

local function get_song_status_by_name()
    build_song_status()
    return song_status_by_name
end

-- 自分にかかっている歌の本数。0x063 をまだ受けていなければ nil。
-- 他の詩人 (トラスト含む) の歌も 0x063 には並ぶので、これは「自分の枠が
-- 何本埋まっているか」ではない。歌う判断には使わず (そちらは filled_slots)、
-- ac show song で「誰かが同じ歌を載せていないか」を見る為だけに使う
local function song_count()
    if ac_buff.self_updated_at == nil then
	return nil
    end
    build_song_status()
    local n = 0
    for sid in pairs(song_status_set) do
	n = n + (ac_buff.self_count(sid) or 0)
    end
    return n
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

--
-- 楽器の持ち替え
--
-- 普段はミラクルチアー (歌数+1)。歌の枠を増やす時だけダウルダヴラ (歌数+2)
-- に着替え、増やしたら戻す。判断は song_plan.want_instrument にある。
--
-- 枠が増えるのは「今かかっていない曲」を歌った時だけで、かかっている曲を
-- 歌い直しても増えも減りもしない。だから普段はミラクルチアーで歌えばよく、
-- 逆に一度落とした枠はダウルダヴラを持ち直すまで戻らない

local MIRACLE_CHEER_ID = 22249  -- ミラクルチアー
-- ダウルダヴラ。歌数+2 の Lv99 だけを見る。歌数+1 の物はミラクルチアーと
-- 同じ本数までしか載らないので、持ち替える意味がない
local DAURDABLA_IDS = { 18839, 18571 }

-- 持ち替えの対象。これ以外の物を着けている時は、自分で選んだものとして触らない
local SWAP_TARGET = { [MIRACLE_CHEER_ID] = true }
for _, id in ipairs(DAURDABLA_IDS) do SWAP_TARGET[id] = true end

-- 持っているダウルダヴラの item id。持っていなければ nil。
-- 維持したい本数がこれで決まる。毎 tick 全バッグを走査するのは重いので
-- 覚えておき、装備を入れ替えた時に追随できるよう時々引き直す
local GROW_RECHECK = 300
local grow_id = nil  -- nil:まだ見ていない  false:持っていない
local grow_id_at = 0
local function grow_instrument_id()
    local now = os.time()
    if grow_id == nil or now - grow_id_at >= GROW_RECHECK then
	grow_id = false
	for _, id in ipairs(DAURDABLA_IDS) do
	    if ac_equip.search_equip_item(id) ~= nil then
		grow_id = id
		break
	    end
	end
	grow_id_at = now
    end
    return grow_id or nil
end

-- 今の楽器まわりの状況。get_items を何度も引かないよう、1 tick に1回作る。
--   id       : 今着けている楽器の item id (楽器を持っていなければ nil)
--   swap     : 持ち替えの対象か。短剣や、自分で選んだ楽器なら false
--   keep_cap : 普段の楽器で載る本数。クラリオンコール中は1曲多い
--   target   : 維持したい歌の本数
--
-- target を今着けている楽器で決めないのは、ダウルダヴラに持ち替えている間
-- だけ本数が増えると、その隙に余分な1曲を歌ってしまい (クラリオンコール中
-- なら5曲目)、ミラクルチアーに戻した時にその曲が plan から外れて、誰も
-- 残り時間を見ないまま切れる為
local function instrument_state(player)
    local id = equipped_instrument_id()
    local swap = id ~= nil and SWAP_TARGET[id] ~= nil
    return {
	id = id,
	swap = swap,
	keep_cap = song_plan.max_songs(MIRACLE_CHEER_ID,
				       has_clarion_call(player)),
	-- 持ち替えないなら、今の楽器で載る本数がそのまま目標
	target = swap
	    and song_plan.target_songs(MIRACLE_CHEER_ID, grow_instrument_id())
	    or song_plan.max_songs(id, false),
    }
end

-- 着けたい楽器に着替える。
-- 着弾待ちの間は選び直さない。歌い終わる前に戻すと、その歌は戻した後の
-- 楽器の歌数で載る事になり、増やすつもりだった枠が増えない。
--- filled : 自分が押さえている枠の数
--- grow   : 枠を増やしてよいか。周囲に敵がいない間は増やさない
--- 戻り値: 選んだ楽器 ("daurdabla" | "miracle")。触らなかったなら nil
local function instrument_tick(inst, filled, grow)
    if not inst.swap then
	return nil
    end
    local want = pending and pending.want
    if want == nil then
	want = grow
	    and song_plan.want_instrument(filled, inst.keep_cap, inst.target)
	    or "miracle"
    end
    -- ダウルダヴラを持っていなければ普段の楽器のまま (歌数は増やせない)
    local id = want == "daurdabla" and grow_instrument_id() or MIRACLE_CHEER_ID
    if id ~= inst.id then
	ac_equip.equip_item("range", id)
    end
    return want
end

-- 今の状況で歌う曲の並び (優先順の全曲)。何曲維持するかは
-- song_plan.keep_plan が決めるので、ここでは切り詰めない。
-- need_safety() は今のターゲットで決まるので、戦闘の切れ目で裏返る。
-- 構成が入れ替わると新しい方の曲が全部「未掛かり」に見えて全曲歌い直しに
-- なるので、一定時間続いた時だけ切り替える
local PLAN_SWITCH_SEC = 10
local plan_key = "attack"
local plan_pending = nil
local plan_pending_at = 0

local function current_plan()
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
    return SONG_PLANS[plan_key]
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
-- plan は song_plan.keep_plan が維持できる本数まで絞ってあるので、埋まらない
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

-- 今維持する曲と、その残り秒。song_tick と表示で共用する。
-- 優先順の全曲で残りを出してから選ぶ。先に切り詰めると、優先順の下にある
-- 「今かかっている曲」が消えて、誰も歌い直さないまま切れる
local function current_plan_remains(target)
    local full = current_plan()
    return song_plan.keep_plan(full, plan_remains(full), target)
end

-- 自分が押さえている歌の枠の数。plan の曲で、今かかっているものを数える。
-- ac_buff には他の詩人 (トラスト含む) の歌も並ぶので、そちらを数えると枠が
-- 埋まって見えて、ダウルダヴラに持ち替えられず4曲目を足せなくなる。
-- 歌の枠は詩人ごとに別なので、数えるのは自分の plan の分だけでよい
local function filled_slots(remains)
    local n = 0
    for _, r in ipairs(remains) do
	if r > 0 then
	    n = n + 1
	end
    end
    return n
end

-- status_id の実測の、本数と一番短い残り。self_remains は降順なので末尾が最短
local function family_state(sid)
    local rs = sid ~= nil and ac_buff.self_remains(sid) or nil
    if rs == nil then
	return 0, 0
    end
    return #rs, rs[#rs] or 0
end

-- task がコマンドを送る時に呼ばれる。ここが「歌い始めた瞬間」なので、
-- 着弾の判定に使う実測はここで取り直す。
-- 積んだ歌と違う曲が出て来る事がある (待っている間に諦めた後で task の
-- キューから出て来た時) ので、送った曲でそのまま作り直す
local function song_sent(song_name)
    local sid = get_song_status_by_name()[song_name]
    if sid == nil then
	pending = nil  -- status が引けない曲は着弾を判定できない。待たない
    else
	-- 積んだ時に選んだ楽器は引き継ぐ。捨てると歌っている間に選び直して、
	-- 増やすつもりだった枠が増えない
	local want = pending and pending.name == song_name and pending.want or nil
	local count, min = family_state(sid)
	pending = { name = song_name, sid = sid, count = count, min = min,
		    at = os.time(), sent = true, want = want }
    end
    command.send("input /song "..song_name.." <me>")
end

task.add_command_handler(SONG_COMMAND, song_sent)

-- 積んだ歌の着弾待ちか。着弾した/諦めたら pending を畳んで false を返す
local function waiting_song()
    if pending == nil then
	return false
    end
    local now = os.time()
    if not pending.sent then
	if now - pending.at >= QUEUE_MAX then
	    pending = nil  -- キューから出て来ない。積み直す
	    return false
	end
	return true
    end
    local count, min = family_state(pending.sid)
    if count > pending.count or min > pending.min then
	my_song[pending.name] = now  -- 着弾した。歌った時刻はここで記録する
	pending = nil
	return false
    end
    if now - pending.at >= PENDING_MAX then
	-- 中断されたらしい。歌った事にはしないので、この曲は残りの実測どおり
	-- 「切れかけ」のまま見え、次の tick で歌い直される
	pending = nil
	return false
    end
    return true
end

-- 周囲に敵がいるか。街中で歌い続けない為の門番。
--
-- ゾーンでは判断できない。アルザビやアトルガン白門は普段は街だが、
-- ビシージ中は敵が湧く。街を除外すると、そこで歌わなくなる。
--
-- acmob.is_mob_attackable は使わない。あちらは「自分が殴れるか」なので、
-- NPC にヘイトが向いている敵を弾く。ビシージの敵はほとんどそれに当たる。
-- ここで見たいのは「敵がそこに居るか」だけ。
--
-- 範囲は視界の広さに合わせる。get_mob_array に載るのはクライアントが
-- 持っている範囲 (50 前後) までなので、ここを大きくすると実質
-- 「クライアントが敵を1体でも知っているか」になる。街ではそれが 0 なので、
-- 街を弾く目的はこれで足りる。狭くするとビシージで門から寄って来る敵に
-- 気付くのが遅れ、4曲揃う前に接敵する
local SONG_ENEMY_RANGE = 50

local function enemy_near(player)
    if player.status == pstatus.ENGAGED then
	return true  -- 戦闘中。相手が索敵の外に居ても敵は居る
    end
    local me = windower.ffxi.get_mob_by_target("me")
    if me == nil or me.x == nil then
	return false
    end
    for _, mob in pairs(windower.ffxi.get_mob_array()) do
	-- is_mob_attackable ではなく is_enemy。前者は claim まで見るので、
	-- NPC にヘイトが向いている敵 (ビシージはほとんどそれ) を弾いてしまう
	if acmob.is_enemy(mob) and mob.x ~= nil and
	    acmob.distance(mob, me) <= SONG_ENEMY_RANGE then
	    return true
	end
    end
    return false
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
    -- 積んだ歌が着弾するまで次を積まない。
    -- 残りを出すより先に見る。着弾した時刻の記録がここで入るので、後から
    -- 見ると status を共有する曲の対応が1 tick ずれ、乗ったばかりの曲を
    -- もう一度歌ってしまう
    local waiting = waiting_song()
    local enemy = enemy_near(player)
    local inst = instrument_state(player)
    local plan, remains = current_plan_remains(inst.target)
    -- 楽器は歌っていない間も見る (着弾したら普段の楽器に戻す為)
    local want = instrument_tick(inst, filled_slots(remains), enemy)
    if waiting then
	return
    end
    -- 周囲に敵がいない間は歌わない。街に立っているだけで歌い続けない為。
    -- 着弾待ちより後に見る。歌い終わる前に敵が居なくなっても、その歌の
    -- 着弾は記録しないと status を共有する曲の対応が狂う
    if not enemy then
	return
    end
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
	-- 積んだ印。実測は song_sent (コマンドを送る時) で取り直す
	local count, min = family_state(sid)
	pending = { name = name, sid = sid, count = count, min = min,
		    at = os.time(), sent = false, want = want }
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
    local inst = instrument_state(player)
    local plan, remains = current_plan_remains(inst.target)
    local status_of = get_song_status_by_name()
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
    io_chat.printf("楽器:%s クラリオンコール:%s 維持したい本数:%d (plan %d曲中%d曲)",
		   inst.id == nil and "なし"
		       or (res_name.item_ja(inst.id).."("..inst.id..")"),
		   tostring(has_clarion_call(player)), inst.target,
		   #SONG_PLANS[plan_key], #plan)
    local filled = filled_slots(remains)
    io_chat.printf("押さえている枠:%d 普段の楽器で載る本数:%d 着けたい楽器:%s",
		   filled, inst.keep_cap,
		   song_plan.want_instrument(filled, inst.keep_cap, inst.target))
    -- 他の詩人 (トラスト含む) の歌も混ざる。判断には使っていない
    io_chat.printf("自分に乗っている歌 (他の詩人の分も含む):%s",
		   tostring(song_count()))
    io_chat.printf("歌う:%s 次の曲:%s メンバー参照:%s 周囲の敵:%s",
		   tostring(song_plan.should_sing(remains)),
		   tostring(song_plan.pick_song(plan, remains)),
		   tostring(USE_MEMBER_LACK),
		   tostring(enemy_near(player)))
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
