-- role(役割)関連の処理

local M = {}

local utils = require("utils")

local tank_jobs = { "PLD", "RUN", "WAR", "SAM", "DNC" }
local skill_chain_jobs = { "WAR", "MNK", "DRK", "SAM", "DRG", "THF", "RNG", "NIN", "DNC", "COR" }
local magic_burst_jobs = { "BLM", "SCH", "GEO" }
local range_jobs = { "RNG", "COR" }
local healer_jobs = { "WHM", "RDM", "SCH", "PLD" }
    
function M.iam_tank_job()
    local player = windower.ffxi.get_player()
    return utils.table.contains(tank_jobs, player.main_job)
end
function M.iam_skill_chain_job()
    local player = windower.ffxi.get_player()
    return utils.table.contains(skill_chain_jobs, player.main_job)
end
function M.iam_magic_burst_job()
    local player = windower.ffxi.get_player()
    return utils.table.contains(magic_burst_jobs, player.main_job) 
end
function M.iam_healer_job()
    local player = windower.ffxi.get_player()
    return utils.table.contains(healer_jobs, player.main_job) or
	utils.table.contains(healer_jobs, player.sub_job)
end

function M.tick(player)
end

return M
