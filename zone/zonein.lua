--- ゾーンイン完了
---
--- クライアントは背景の読み込みを終えると Zone In 1/2/3
--- (outgoing 0x00C / 0x00F / 0x011) を送る。0x011 が最後のもの。
--- 一方 Windower の 'zone change' イベントは incoming 0x00A (Zone update =
--- 読み込みの開始) で飛ぶ。つまりイベントから固定秒数で動き出す作りは、
--- 読み込みが長引くと読み込み中に走る事になる。読み込み中の移動
--- (outgoing 0x015) は、背景が出ないまま操作不能になる原因になる。
---
--- outgoing/chunk が 0x011 で notify_done を呼び、待つ側が wait_done を使う。

local M = {}

local io_chat = require 'io/chat'
local control = require 'control'

-- 最後に outgoing 0x011 を受けた時刻。nil は「まだ見ていない」であって
-- 「ゾーンインしていない」ではない
M.done_at = nil

-- 完了を待つ上限。読み込みが遅い環境でも足りるよう長めに取る。
-- ここを超えるという事は 0x011 を観測できていないという事なので、
-- 黙って動き出さずに警告を出して止まる (走って固まる方が高くつく)
local WAIT_MAX_SEC = 60
-- 待ち始めた時刻より少し前の 0x011 も、このゾーンインのものとして拾う。
-- 'zone change' イベントと 0x011 の前後が環境で入れ替わっても動くように
local GRACE_SEC = 3
local POLL_SEC = 0.5

function M.reset()
    M.done_at = nil
end

-- outgoing/chunk の 0x011 から呼ぶ
function M.notify_done()
    M.done_at = os.time()
    if control.debug then
	print("zone/zonein: ゾーンイン完了 (outgoing 0x011)")
    end
end

-- 既に世界に入っていると分かっている時に呼ぶ。アドオンのロード時など、
-- ゾーンインを跨いでいないので 0x011 が来ないところ用
function M.assume_done()
    M.done_at = os.time()
end

-- since 以降 (GRACE_SEC の猶予付き) のゾーンイン完了を待つ。
-- 待てたら true。時間切れと中断は false。
-- is_current は「この起動がまだ最新か」を返す関数 (省略可)
function M.wait_done(since, is_current)
    local deadline = os.time() + WAIT_MAX_SEC
    while true do
	if M.done_at ~= nil and M.done_at >= since - GRACE_SEC then
	    return true
	end
	if os.time() > deadline then
	    io_chat.warnf("ゾーンイン完了 (outgoing 0x011) が %d 秒来ない",
			  WAIT_MAX_SEC)
	    return false
	end
	coroutine.sleep(POLL_SEC)
	if is_current ~= nil and not is_current() then
	    return false
	end
    end
end

return M
