-- 全共通のグローバルな制御フラグ/データ
-- config/settings とは分けたい

local M = {}

M.auto = false

M.FINISH_ANY = 0
M.FINISH_ATTACK = 1  -- エミネンス目標
M.FINISH_RANGE = 2  -- 予定なし
M.FINISH_MAGIC = 3  -- エミネンス目標、ソーティ課題
M.FINISH_WS = 4
M.FINISH_WS_ELEMENT = 5  -- アビセア黄色発光

M.finish = M.FINISH_ANY

return M
