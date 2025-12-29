local io_chat = require "io/chat"

local M = {
    auto = false,
    attack = false,  -- 敵と戦う
    calm = false,    -- 戦闘中動かない
    debug = false,   -- デバッグメッセージ
    do_my_best = false, -- 本気を出す (1H アビが使う)
    equip_lock = true,  -- 装備の固定。脱衣攻撃対策
    puller = false,  -- 敵にちょっかい出す。基本はリーダーのみ true
    enemy_filter = nil  -- ちょっかい出す敵を名前で制限。
    wstp = -1, -- 無条件で WS をうつ TP 量。-1 だと MB 狙いで調整される
    -- enemy_space
    -- finish_blow
}

-- enemy_space
M.ENEMY_SPACE_NEAR   = 1  -- 敵に近づく
M.ENEMY_SPACE_MANUAL = 2  -- 手動操作。勝手に動かない
M.ENEMY_SPACE_MAGIC  = 3  -- 魔法使い用
M.ENEMY_SPACE_RANGE  = 4  -- 遠隔攻撃用
M.ENEMY_SPACE_ROLE   = 5  -- 遠隔は遠隔の、魔法使いは魔法ギリギリ(TODO)a

M.enemy_space = M.ENEMY_SPACE_NEAR

-- finish_blow どとめの差し方
M.FINISH_BLOW_ANY    = 0
M.FINISH_BLOW_ATTACK = 1  -- 通常攻撃でとどめ(エミネンス目標)
M.FINISH_BLOW_RANGE  = 2  -- 遠隔でとどめ(予定なし)
M.FINISH_BLOW_MAGIC  = 3  -- 魔法でとどめ (エミネンス目標、ソーティ課題)
M.FINISH_BLOW_WS     = 4  -- WS でとどめ
M.FINISH_BLOW_WS_ELEMENT = 5  -- アビセア黄色発光

M.finish_blow = M.FINISH_BLOW_ANY

-- 全共通のグローバルな制御フラグ/データ
-- config/settings とは分けたい

function M.setWSTP(wstp)
    if type(wstp) == 'string' then
	wstp = tonumber(wstp)
    end
    if (wstp == nil or wstp < 1000 or 3000 < wstp) and wstp ~= -1 then
	io_chat.warnf("ac control wstp <-1 or 1000-3000>", wstp)
	wstp = -1
    end
    control.wstp = wstp
    io_chat.setNextColor(5)
    io_chat.print("ac control wstp", wstp)
end

return M
