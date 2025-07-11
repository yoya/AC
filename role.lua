-- role(役割)関連の処理

local M = {}

local utils = require("utils")

function M.iamLeader()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    if party.party1_leader == player.id then
        return true
    end
    return false
end

local tankJobs = { "PLD", "RUN", "WAR", "SAM", "DNC" }
local skillChainJobs = { "WAR", "MNK", "DRK", "SAM", "DRG", "THF", "RNG", "NIN", "DNC" }
local magicBurstJobs = { "BLM", "SCH", "GEO" }
local healerJobs = { "WHM", "RDM", "SCH", "PLD" }
    
function M.iamTankJob()
    local player = windower.ffxi.get_player()
    return utils.contains(tankJobs, player.main_job)
end
function M.iamSkillChainJob()
    local player = windower.ffxi.get_player()
    return utils.contains(skillChainJobs, player.main_job)
end
function M.iamMagicBurstJob()
    local player = windower.ffxi.get_player()
    return utils.contains(magicBurstJobs, player.main_job) 
end
function M.iamHealerJob()
    local player = windower.ffxi.get_player()
    return utils.contains(healerJobs, player.main_job) or
	utils.contains(healerJobs, player.sub_job)
end

return M
