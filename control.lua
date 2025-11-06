-- 全共通のグローバルな制御フラグ/データ
-- config/settings とは分けたい

local M = {
    auto = false,
    debug = false,
}

M.ENEMY_SPACE_NEAR = 1
M.ENEMY_SPACE_MANUAL = 2 -- 動かない。手動操作
M.ENEMY_SPACE_MAGIC = 3 -- 魔法使い用
M.ENEMY_SPACE_ROLE = 4 -- 遠隔は遠隔の、魔法使いは魔法ギリギリ(TODO)

M.enemy_space = M.ENEMY_SPACE_NEAR

M.FINISH_ANY = 0
M.FINISH_ATTACK = 1  -- エミネンス目標
M.FINISH_RANGE = 2  -- 予定なし
M.FINISH_MAGIC = 3  -- エミネンス目標、ソーティ課題
M.FINISH_WS = 4
M.FINISH_WS_ELEMENT = 5  -- アビセア黄色発光

M.finish = M.FINISH_ANY

return M
