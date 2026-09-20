-- 狩りスタイル。書きかけで、まだどこからも使われていない。
--
-- 元は定数を未定義のグローバル N に代入していて、require すると落ちた。
-- M に直し、値が重複していた BASE / BASE_ONE を振り直してある。

local M = {}

M.HUNT_STYLE_IMMOVABLE = 1 -- 一切移動しない
M.HUNT_STYLE_BASE      = 2 -- ベースに近い敵を狩る (デフォルト)
M.HUNT_STYLE_BASE_ONE  = 3 -- 一匹敵を倒したら一旦戻る
M.HUNT_STYLE_BASE_ALL  = 4 -- 敵を全部倒したら戻る
M.HUNT_STYLE_NOBASE    = 5 -- ベースを決めない

M.hunt_style = M.HUNT_STYLE_BASE

return M
