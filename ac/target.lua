--- ターゲットの意図
---
--- 「今どこを狙いたいか」をここだけが持つ。<t> をその通りにする手順
--- (0x058 の注入、切り替わったかの確認、掴めない時の復帰) も、ここだけが持つ。
---
--- 分けた理由。注入は「効かない事がある」(タゲロックが残っている等)。
--- 効かないまま /attack を撃つと、その時の <t> (倒した敵の後に隣の味方へ
--- 移ったもの等) を殴りに行き「攻撃対象ではありません」を出し続ける。
--- 対処を呼び出し側に書くと、待機中と戦闘中で同じ手順が二重になる。
---
--- io/net は「注入する」低レベル関数のまま。判断はここに置く。

local M = {}

local io_net = require 'io/net'
local io_chat = require 'io/chat'
local keyboard = require 'keyboard'

-- 掴めなかった回数。これだけ続いたらタゲを落として掴み直す
local fail_count = 0
local FAIL_MAX = 2

-- 落とす度に書くとログが埋まるので、知らせるのは間引く
local last_warn_time = 0
local WARN_INTERVAL_SEC = 30

-- 注入してから <t> に反映されるまでの待ち
local INJECT_WAIT_SEC = 0.3

local function current_target()
    return windower.ffxi.get_mob_by_target("t")
end

-- 掴めない時にタゲを落とす。escape はロックごと外れるので、
-- 次に注入した時は通るようになる
local function release(mob, t)
    local now = os.time()
    if now - last_warn_time >= WARN_INTERVAL_SEC then
	last_warn_time = now
	io_chat.warnf("%s を掴めないのでタゲを外す (今の <t>: %s)",
		      tostring(mob.name), t ~= nil and tostring(t.name) or "なし")
    end
    -- 短押し。呼び出し元の tick 予算を食わないように
    keyboard.longpush_key("escape", 0.05)
    fail_count = 0
end

--- mob を狙う。掴めたら true。
--- 最大 0.3 秒ブロックする (注入の反映待ち)。tick から呼んでよい
function M.want(mob)
    if mob == nil then
	return false
    end
    local t = current_target()
    if t ~= nil and t.index == mob.index then
	fail_count = 0
	return true  -- 既に掴んでいる。入れ直すとタゲが揺れるので触らない
    end
    io_net.target_by_mob(mob)
    coroutine.sleep(INJECT_WAIT_SEC)
    t = current_target()
    if t ~= nil and t.index == mob.index then
	fail_count = 0
	return true
    end
    fail_count = fail_count + 1
    if fail_count >= FAIL_MAX then
	release(mob, t)
    end
    return false
end

--- 狙うのをやめる。次に want した時の為に失敗回数を戻すだけで、
--- <t> は触らない (外すのは release の仕事)
function M.clear()
    fail_count = 0
end

return M
