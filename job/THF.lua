-- シーフ

local M = {}

local role_Melee = require 'role/Melee'

M.mainJobProbTable = {
    { 10, 300, 'input /ja ぬすむ <t>', 0 },
    { 10, 300, 'input /ja かすめとる <t>', 0 },
    { 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja 不意打ち <me>; wait 1; input /ws マンダリクスタッブ <t>', 0 },
    { 50, 180, 'input /ja フェイント <me>', 0 },
    { 50, 300, 'input /ja コンスピレーター <me>', 0 },
    { 10, 180, 'input /ja まどわす <t>', 0 },
    { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja だまし討ち <me>; wait 1; input /ws マンダリクスタッブ <t>', 0 },
}

M.subJobProbTable = {
    { 10, 300, 'input /ja ぬすむ <t>', 0 },
    { 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja 不意打ち <me>;', 0 },
    { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja だまし討ち <me>;', 0 },
    { 10, 300, 'input /ja かすめとる <t>', 0 },
}

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

return M
