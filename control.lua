local M = {
    auto = false,
    attack = false,
    puller = false,  -- 基本はリーダーのみ true
    calm = false,
    debug = false,
    equip_lock = true,  -- 装備の固定。脱衣攻撃対策
    -- enemy_space
    -- finish_blow
}

-- enemy_space
M.ENEMY_SPACE_NEAR = 1
M.ENEMY_SPACE_MANUAL = 2 -- 動かない。手動操作
M.ENEMY_SPACE_MAGIC = 3 -- 魔法使い用
M.ENEMY_SPACE_ROLE = 4 -- 遠隔は遠隔の、魔法使いは魔法ギリギリ(TODO)

M.enemy_space = M.ENEMY_SPACE_NEAR

-- finish_blow どとめの差し方
M.FINISH_BLOW_ANY = 0
M.FINISH_BLOW_ATTACK = 1 -- 通常攻撃でとどめ(エミネンス目標)
M.FINISH_BLOW_RANGE = 2  -- 遠隔でとどめ(予定なし)
M.FINISH_BLOW_MAGIC = 3  -- 魔法でとどめ (エミネンス目標、ソーティ課題)
M.FINISH_BLOW_WS = 4     -- WS でとどめ
M.FINISH_BLOW_WS_ELEMENT = 5  -- アビセア黄色発光

M.finish_blow = M.FINISH_BLOW_ANY

-- 全共通のグローバルな制御フラグ/データ
-- config/settings とは分けたい

return M
