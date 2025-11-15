-- 忍者

local M = {}

local role_Melee = require 'role/Melee'

M.mainJobProbTable = {
    { 100, 60*10, 'input /ja 陰忍 <me>', 2 },
}

M.subJobProbTable = { }

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

return M
