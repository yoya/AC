-- Prob
-- 確率的なコマンド実行

local utils = require 'utils'
local acjob = require 'job'
local merge_lists = utils.table.merge_lists
local task = require 'task'
local io_chat = require 'io/chat'
local M = {}

M.prob_recast_time = {}

-- job = { probPermil(1/1000), recast, command, wait }

local send_command_prob_table = {
    ALL = {
	-- { 200, 900, 'input /item キャパシティリング <me>', 1 },
    },
}

-- サブジョブ用
local send_command_prob_table_sub = { }

-- job_table から取り込む
for k,v in pairs(acjob.job_table) do
    if v.main_job_prob_table ~= nil then
	send_command_prob_table[k] = v.main_job_prob_table
    end
    for i = 1, 6 do
	if (v["mainJobProbTable_" .. i]) ~= nil then
	    send_command_prob_table[k.."_" .. i] = v["mainJobProbTable_" .. i]
	end
    end
    if v.sub_job_prob_table ~= nil then
	send_command_prob_table_sub[k] = v.sub_job_prob_table
    end
end

local is_backline_job = function(job)
    if job == 'WHM' or job == 'RDM' or
    job == 'BLM' or job == 'SCH' or job == 'SMN' then
        return true
    end
    return false
end

M.get_send_command_prob_table = function(main_job, sub_job, rank_in_job)
    local merged = {}
    -- print("rank_in_job", rank_in_job)
    for job, commprob in pairs(send_command_prob_table) do
        if job == main_job or job == main_job..'_'..rank_in_job or job == "ALL" then
            merged = merge_lists(merged, commprob)
        end
    end
    if is_backline_job(main_job) == false and
       is_backline_job(sub_job) == true then
        sub_job = nil
    end
    for job, commprob in pairs(send_command_prob_table_sub) do
        if job == sub_job or job == "ALL" then
            merged = merge_lists(merged, commprob)
        end
    end
    return merged
end 

M.send_command_prob = function(table, period)
    -- print("send_command_prob")
    local rnd = math.random(1, 1000)
    local pp = 0
    local pn
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
        if M.prob_recast_time[c] == nil then
            if pp < rnd and rnd <= pn then
--                windower.ffxi.run(false)
--                coroutine.sleep(0.5)
                -- command.send(c)
		local level
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
                M.prob_recast_time[c] = { }
		M.prob_recast_time[c][1] = os.time() + r
		M.prob_recast_time[c][2] = f  -- 戦闘毎にリセットするかフラグ
                if t > 0 then
                    coroutine.sleep(t)
                end
                return true
            end
            pp = pn
	else
	    if M.prob_recast_time[c][1] < os.time() then
		M.prob_recast_time[c] = nil
	    end
        end
    end
    return false
end

M.clear_prob_recast_time = function()
    for i, v in pairs(M.prob_recast_time) do
	local f = v[2]  -- 戦闘毎にリセットするかフラグ
	if f == true then
	    M.prob_recast_time[i] = nil
	end
    end
end

return M
