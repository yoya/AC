-- 踊り子

local M = {}

local role_Melee = require 'role/Melee'

M.mainJobProbTable = {
    {200, 300, 'input /ja 剣の舞い <me>', 0 },
    -- {500, 100, 'input /ja 扇の舞い <me>', 0 },
    {50, 90, 'input /ja ヘイストサンバ <me>', 0 },
    {50, 90, 'input /ja ドレインサンバII <me>', 0 },
    {100, 60, 'input /ja B.フラリッシュ <me>', 0 },
    {100, 90, 'input /ja C.フラリッシュ <me>', 0 },
    {100, 90, 'input /ja S.フラリッシュ <me>', 0 },
    {100, 90, 'input /ja T.フラリッシュ <me>', 0 },
    {100, 5*3, 'input /ja クイックステップ <t>', 0},
    {100, 5*3, 'input /ja ボックスステップ <t>', 0},
    {100, 5*3, 'input /ja フェザーステップ <t>', 0},
}

M.subJobProbTable = { }

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

return M
