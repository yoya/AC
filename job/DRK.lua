-- 暗黒騎士

local M = {}

local role_Melee = require 'role/Melee'
local role_Sorcerer = require 'role/Sorcerer'

M.mainJobProbTable = {
    { 100, 180-30, 'input /ma エンダークII <me>', 3 },
    { 100, 180, 'input /ma ドレッドスパイク <me>', 3 },
    { 60, 120, 'input /ma ドレインIII <t>', 3 },
    { 100, 120, 'input /ma アブゾースト <t>', 3, true },
    { 100, 120, 'input /ma アブゾバイト <t>', 3, true },
    { 100, 120, 'input /ma アブゾタック <t>', 3, true },
    { 100, 120, 'input /ma アブゾデック <t>', 3, true },
    { 100, 120, 'input /ma アブゾアキュル <t>', 3, true },
    -- { 100, 3000, 'input /ja 暗黒 <me>', 0 },
    -- { 100, 180, 'input /ja コンスームマナ <me>', 0 }, -- MP全部消える
    { 100, 90/2, 'input /ja レッドデリリアム <me>', 0 },
    -- 盾では無理
    -- { 100, 3000/2, 'input /ja ラストリゾート <me>', 0 }, -- 盾では無理
    -- { 100, 3000/2, 'input /ja ディアボリクアイ <me>', 0 },
}

M.subJobProbTable = {
    { 100, 3000, 'input /ja ラストリゾート <me>', 0 },
    { 100, 3000, 'input /ja 暗黒 <me>', 0 },
}

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    if role_Sorcerer.main_tick ~= nil then
	role_Sorcerer.main_tick(player)
    end
end

return M
