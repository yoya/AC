-- 学者

local task = require 'task'
local role_Healer = require 'role/Healer'
local role_Sorcerer = require 'role/Sorcerer'

local M = {}

local enhance = 'input /ja 令狸執鼠の章 <me>; wait 1; input /ja 女神降臨の章 <me>; wait 1'


M.mainJobProbTable = {
    { 100, 120*2, 'input /ma 鼓舞激励の策 <me>', 10 },
    { 100, 120*2, 'input /ma 鼓舞激励の策 <p1>', 10 },
    { 100, 120*2, 'input /ma 鼓舞激励の策 <p2>', 10 },
    { 100, 120*2, 'input /ma 鼓舞激励の策 <p3>', 10 },
    { 100, 120*2, 'input /ma リジェネV <p1>', 10 },
    { 1000, 3600, 'input /ja 黒のグリモア <me>; wait 2 ; input /ja  黒の補遺 <me>', 3, true },
    -- { 100, 120-30, 'input /ma ヘイスト <p1>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p2>', 4 },
}

M.subJobProbTable = {
    { 1000, 3600, 'input /ja 白のグリモア <me>; wait 2 ; input /ja 白の補遺 <me>', 3, true },
    { 100, 120*2, enhance..'; input /ma 鼓舞激励の策 <me>', 10 },
    { 100, 120*2, enhance..'; input /ma ストンスキン <me>', 10 },
    { 100, 120*2, enhance..'; input /ma リジェネV <me>', 10 },
    { 100, 180-10, 'input /ma 悪事千里の策 <p1>', 5 },
    { 100, 180-10, 'input /ma 暗中飛躍の策 <p2>', 5 },
    { 50, 120, 'input /ja 机上演習 <me>', 0 },
}

function M.main_tick(player)
    if role_Sorcerer.main_tick ~= nil then
	role_Sorcerer.main_tick(player)
    end
    if player.status == 1 then -- 戦闘中
	if player.vitals.mp >= 1000 then  -- MP に余裕があれば
	    role_Sorcerer.invoke_magic(2, true, task.PRIORITY_LOW)
	    role_Sorcerer.invoke_magic(3, true, task.PRIORITY_LOW)
	end
    end
end

function M.sub_tick(player)
    if role_Healer.sub_tick ~= nil then
	role_Healer.sub_tick(player)
    end
end

return M
