-- モンク

local M = {}

local role_Melee = require 'role/Melee'

M.mainJobProbTable = {
    { 100, 120, 'input /ja 集中 <me>', 0 },
    { 60, 180, 'input /ja チャクラ <me>', 0 },
    { 60, 600, 'input /ja マントラ <me>', 0 },
    { 60, 300, 'input /ja 猫足立ち <me>', 0 },
    { 60, 300, 'input /ja かまえる <me>', 0 },
    { 60, 300, 'input /ja インピタス <me>', 0 },
    -- { 60, 600, 'input /ja 無想無念 <me>', 0 },
}

M.subJobProbTable = {
    { 100, 120, 'input /ja 集中 <me>', 0 },
}

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

return M
