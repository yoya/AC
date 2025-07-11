---
--- Prob
--- 確率的なコマンド実行

local utils = require 'utils'
local acjob = require 'job'
local merge_lists = utils.merge_lists
local merge_tables = utils.merge_tables
local command = require 'command'
local M = {}

--- job = { probPermil(1/1000), recast, command, wait }

local sendCommandProbTable = {
    ALL = {
---     { 200, 900, 'input /item キャパシティリング <me>', 1 },
    },
}

-- サブジョブ用
local sendCommandProbTableSub = { }

-- jobTable から取り込む
for k,v in pairs(acjob.jobTable) do
    if v.mainJobProbTable ~= nil then
	sendCommandProbTable[k] = v.mainJobProbTable
    end
    if v.mainJobProbTable_1 ~= nil then
	sendCommandProbTable[k.."_1"] = v.mainJobProbTable_1
    end
    if v.mainJobProbTable_2 ~= nil then
	sendCommandProbTable[k.."_2"] = v.mainJobProbTable_2
    end
    if v.subJobProbTable ~= nil then
	sendCommandProbTableSub[k] = v.subJobProbTable
    end
end

local isBacklineJob = function(job)
    if job == 'WHM' or job == 'RDM' or
    job == 'BLM' or job == 'SCH' or job == 'SMN' then
        return true
    end
    return false
end

M.getSendCommandProbTable = function(mainJob, subJob, rankInJob)
    local merged = {}
--    print("rankInJob", rankInJob)
    for job, commprob in pairs(sendCommandProbTable) do
        if job == mainJob or job == mainJob..'_'..rankInJob or job == "ALL" then
            merged = merge_lists(merged, commprob)
--            print(job, #merged)
        end
    end
    if isBacklineJob(mainJob) == false and
       isBacklineJob(subJob) == true then
        subJob = nil
    end
    for job, commprob in pairs(sendCommandProbTableSub) do
        if job == subJob or job == "ALL" then
            merged = merge_tables(merged, commprob)
        end
    end
    return merged
end 

M.sendCommandProb = function(table, period, ProbRecastTime)
    ---    print("sendCommandProb")
    local rnd = math.random(1, 1000)
    local pp = 0
    local pn = 0
    for i, p_c in ipairs(table) do
        local p = p_c[1]  --- probability
        local r = p_c[2]  --- recast time
        local c = p_c[3]  --- command
        local t = p_c[4]  --- time
---        print(p, r, c, t)
        pn = pp + p*period   
        if ProbRecastTime[c] == nil then
            if pp < rnd and rnd <= pn then
                ProbRecastTime[c] = r
                windower.ffxi.run(false)
                coroutine.sleep(0.25)
                command.send(c)
                if t > 0 then
                    coroutine.sleep(t)
                end
                return true
            end
            pp = pn
        else
            local remain =  ProbRecastTime[c] - period
            if remain > 0 then
                ProbRecastTime[c] = remain
            else
                ProbRecastTime[c] = nil
            end
        end
    end
    return false
end

return M

