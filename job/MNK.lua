-- モンク

local M = {}

local role_Melee = require 'role/Melee'
local task = require 'task'
local pstatus = require 'player_status'

M.main_job_prob_table = {
    { 100, 120, 'input /ja 集中 <me>', 0 },
    { 100, 120, 'input /ja 回避 <me>', 0 },
    { 60, 600, 'input /ja マントラ <me>', 0 },
    { 60, 300, 'input /ja 猫足立ち <me>', 0 },
    { 60, 300, 'input /ja かまえる <me>', 0 },
    { 60, 300, 'input /ja インピタス <me>', 0 },
    { 60, 60, 'input /ja 絶対カウンター <me>', 0 },
    -- { 60, 600, 'input /ja 無想無念 <me>', 0 },
}

M.sub_job_prob_table = {
    { 100, 120, 'input /ja 集中 <me>', 0 },
    { 100, 120, 'input /ja 回避 <me>', 0 },
}


local inner_strength_command =  "input /ja インナーストレングス <me>"
local chakra_command = "input /ja チャクラ <me>"
function M.main_tick(player)
    if player.status == pstatus.ENGAGED then
	if player.vitals.hp < 300 then  -- 緊急回復
	    local params = { level = task.PRIORITY_TOP, period = 1*60*60 }
	    task.set_task_ex(inner_strength_command, params)
	elseif 200 < (player.vitals.max_hp - player.vitals.hp) then
	    local params = { level = task.PRIORITY_TOP, period = 3*60 }
	    task.set_task_ex(chakra_command, params)
	else
	    task.remove_task_ex(inner_strength_command)
	    task.remove_task_ex(chakra_command)
	end
    end
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

function M.sub_tick(player)
    if player.status == pstatus.ENGAGED then
	if 200 < (player.vitals.max_hp - player.vitals.hp) then
	    local params = { level = task.PRIORITY_TOP, period = 3*60 }
	    task.set_task_ex(chakra_command, params)
	else
	    task.remove_task_ex(chakra_command)
	end
    end
end

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local ja_list = { "猫足立ち", "回避", "かまえる", "集中",
		     "インナーストレングス", "百烈拳"}
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.new_task(c, (i-1)*2, 2, 10, false)
	task.set_task(level, t)
    end
end

function M.dothebest_sub(player)
    local level = task.PRIORITY_HIGH
    local ja_list = { "回避", "かまえる", "集中"}
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.new_task(c, (i-1)*2, 2, 10, false)
	task.set_task(level, t)
    end
end

M.battle_equip = {
    body = {
	25786, -- アシェーラハーネス
	23733, -- マリグナスタバード
	25718, -- ヘルクリアベスト
    },
    left_ring = {
	26229, -- レコリング
	26190, -- 月光の指輪
	26189, -- 月明の指輪
	26212, -- ムンムリング
	26182, -- シーリチリング+1
    },
    right_ring = {
	26186, -- イラブラットリング
	26212, -- ムンムリング
	26173, -- アペートリング
	15543, -- ラジャスリング
	26182, -- シーリチリング+1
	26181, -- シーリチリング
	28566, -- ングルベリング --  攻+10
    },
}

return M
