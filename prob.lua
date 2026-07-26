-- Prob
-- 確率的なコマンド実行

local utils = require 'utils'
local acjob = require 'job'
local merge_lists = utils.table.merge_lists
local merge_tables = utils.table.merge_tables
local command = require 'command'
local task = require 'task'
local io_chat = require 'io/chat'
local M = {}

M.probRecastTime = {}

-- job = { probPermil(1/1000), recast, command, wait }

local sendCommandProbTable = {
    ALL = {
	-- { 200, 900, 'input /item キャパシティリング <me>', 1 },
    },
}

-- サブジョブ用
local sendCommandProbTableSub = { }

-- jobTable から取り込む
for k,v in pairs(acjob.jobTable) do
    if v.mainJobProbTable ~= nil then
	sendCommandProbTable[k] = v.mainJobProbTable
    end
    for i = 1, 6 do
	if (v["mainJobProbTable_" .. i]) ~= nil then
	    sendCommandProbTable[k.."_" .. i] = v["mainJobProbTable_" .. i]
	end
    end
    if v.subJobProbTable ~= nil then
	sendCommandProbTableSub[k] = v.subJobProbTable
    end
end

local is_backline_job = function(job)
    if job == 'WHM' or job == 'RDM' or
    job == 'BLM' or job == 'SCH' or job == 'SMN' then
        return true
    end
    return false
end

M.get_send_command_prob_table = function(mainJob, subJob, rank_in_job)
    local merged = {}
    -- print("rank_in_job", rank_in_job)
    for job, commprob in pairs(sendCommandProbTable) do
        if job == mainJob or job == mainJob..'_'..rank_in_job or job == "ALL" then
            merged = merge_lists(merged, commprob)
        end
    end
    if is_backline_job(mainJob) == false and
       is_backline_job(subJob) == true then
        subJob = nil
    end
    for job, commprob in pairs(sendCommandProbTableSub) do
        if job == subJob or job == "ALL" then
            merged = merge_lists(merged, commprob)
        end
    end
    return merged
end 

M.send_command_prob = function(table, period)
    -- print("send_command_prob")
    local rnd = math.random(1, 1000)
    local pp = 0
    local pn = 0
    for i, p_c in ipairs(table) do
        local p = p_c[1]  -- probability
        local r = p_c[2]  -- recast time
        local c = p_c[3]  -- command
        local t = p_c[4]  -- time
	local f = p_c[5]  -- fight reset
	if f == nil then
	    f = false
	end
	if t == nil then
	    io_chat.print(p_c)
	    return
	end
        pn = pp + p*period
        if M.probRecastTime[c] == nil then
            if pp < rnd and rnd <= pn then
--                windower.ffxi.run(false)
--                coroutine.sleep(0.5)
                -- command.send(c)
		local level = task.PRIORITY_LOW
		if p >= 1000 then
		    level = task.PRIORITY_TOP
		elseif p >= 500 then
		    level = task.PRIORITY_HIGH
		elseif p >= 100 then
		    level = task.PRIORITY_MIDDLE
		else
		    level = task.PRIORITY_LOW
		end
		-- command, delay, duration, period, eachfight
		task.set_task(level,
			     task.new_task(c, 0, t, r, f))
		-- タイマーセット
                M.probRecastTime[c] = { }
		M.probRecastTime[c][1] = os.time() + r
		M.probRecastTime[c][2] = f  -- 戦闘毎にリセットするかフラグ
                if t > 0 then
                    coroutine.sleep(t)
                end
                return true
            end
            pp = pn
	else
	    if M.probRecastTime[c][1] < os.time() then
		M.probRecastTime[c] = nil
	    end
        end
    end
    return false
end

M.clear_prob_recast_time = function()
    for i, v in pairs(M.probRecastTime) do
	local f = v[2]  -- 戦闘毎にリセットするかフラグ
	if f == true then
	    M.probRecastTime[i] = nil
	end
    end
end

return M
