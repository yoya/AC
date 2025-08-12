-- 学者

local role_Healer = require 'role/Healer'

local M = {}

local enhance = 'input /ja 令狸執鼠の章 <me>; wait 1; input /ja 女神降臨の章 <me>; wait 1'

M.mainJobProbTable = {
    { 1000, 3600, 'input /ja 白のグリモア <me>; wait 2 ; input /ja 白の補遺 <me>', 3, true },
    { 50, 120*2, enhance..'; input /ma ストンスキン <me>', 10 },
    { 100, 120*2, enhance..'; input /ma リジェネV <me>', 10 },
    { 50, 120*2, enhance..'; input /ma 鼓舞激励の策 <me>', 10 },
    { 100, 180-10, 'input /ma 悪事千里の策 <p1>', 5 },
    { 100, 180-10, 'input /ma 暗中飛躍の策 <p2>', 5 },
    { 50, 120, 'input /ja 机上演習 <me>', 0 },
    -- { 100, 30, 'input /ma サンダーII <t>', 2},
    -- { 200, 30, 'input /ma サンダーIII <t>', 3},
    -- { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p2>', 4 },
}

M.subJobProbTable = { }

function M.main_tick(player)
    if role_Healer.main_tick ~= nil then
	role_Healer.main_tick(player)
    end
end

function M.sub_tick(player)
    if role_Healer.sub_tick ~= nil then
	role_Healer.sub_tick(player)
    end
end

return M
