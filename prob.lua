---
--- Prob
--- 確率的なコマンド実行

local utils = require 'utils'
local acjob = require 'job'
local merge_lists = utils.merge_lists
local merge_tables = utils.merge_tables
local command = require 'command'
local io_chat = require 'io/chat'
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
        end
    end
    if isBacklineJob(mainJob) == false and
       isBacklineJob(subJob) == true then
        subJob = nil
    end
    for job, commprob in pairs(sendCommandProbTableSub) do
        if job == subJob or job == "ALL" then
            merged = merge_lists(merged, commprob)
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
	local f = p_c[4]  --- fight reset
	if t == nil then
	    io_chat.print(p_c)
	    return
	end
        pn = pp + p*period
        if ProbRecastTime[c] == nil then
            if pp < rnd and rnd <= pn then
                windower.ffxi.run(false)
                coroutine.sleep(0.5)
		-- io_chat.print(c)
                command.send(c)
		-- タイマーセット
                ProbRecastTime[c] = { }
		ProbRecastTime[c][1] = os.time() + r
		ProbRecastTime[c][2] = f  -- 戦闘毎にリセットするかフラグ
                if t > 0 then
                    coroutine.sleep(t)
                end
                return true
            end
            pp = pn
	else
	    if ProbRecastTime[c][1] < os.time() then
		ProbRecastTime[c] = nil
	    end
        end
    end
    return false
end

M.clearProbRecastTime = function(probRecastTime)
    for i, v in pairs(probRecastTime) do
	local f = v[2]  -- 戦闘毎にリセットするかフラグ
	if f == true then
	    probRecastTime[i] = nil
	end
    end
end

return M
