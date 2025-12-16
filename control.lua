local M = {
    auto = false,
    attack = false,  -- 敵と戦う
    calm = false,    -- 戦闘中動かない
    debug = false,   -- デバッグメッセージ
    do_my_best = false, -- 本気を出す (1H アビが使う)
    equip_lock = true,  -- 装備の固定。脱衣攻撃対策
    puller = false,  -- 敵にちょっかい出す。基本はリーダーのみ true
    enemy_filter = nil  -- ちょっかい出す敵を名前で制限。
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

return M
