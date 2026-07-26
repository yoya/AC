-- からくり士

local M = {}

local role_Melee = require 'role/Melee'

M.main_job_prob_table = {
    { 200, 1200, 'input /ja アクティベート <me>', 3, true},
    { 100, 60, 'input /ja 応急処置 <me>', 3 },
    { 1000, 20, 'input /pet ディプロイ <t>', 3, true },
    { 500, 300, 'input /ja クールダウン <me>', 3 },
    { 200, 90, 'input /pet ファイアマニューバ <me>', 3 },
    { 100, 90, 'input /pet ライトマニューバ <me>', 3 },
}

M.sub_job_prob_table = { }

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

return M
