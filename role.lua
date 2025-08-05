-- role(役割)関連の処理

local M = {}

local utils = require("utils")

local tankJobs = { "PLD", "RUN", "WAR", "SAM", "DNC" }
local skillChainJobs = { "WAR", "MNK", "DRK", "SAM", "DRG", "THF", "RNG", "NIN", "DNC" }
local magicBurstJobs = { "BLM", "SCH", "GEO" }
local healerJobs = { "WHM", "RDM", "SCH", "PLD" }
    
function M.iamTankJob()
    local player = windower.ffxi.get_player()
    return utils.table.contains(tankJobs, player.main_job)
end
function M.iamSkillChainJob()
    local player = windower.ffxi.get_player()
    return utils.table.contains(skillChainJobs, player.main_job)
end
function M.iamMagicBurstJob()
    local player = windower.ffxi.get_player()
    return utils.table.contains(magicBurstJobs, player.main_job) 
end
function M.iamHealerJob()
    local player = windower.ffxi.get_player()
    return utils.table.contains(healerJobs, player.main_job) or
	utils.table.contains(healerJobs, player.sub_job)
end

return M
