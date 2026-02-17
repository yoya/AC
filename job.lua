--- Job 毎の情報

local M = {}
local task = require 'task'
local utils = require 'utils'
local aczone = require 'zone'
local contents_wkr = require 'contents/wkr'

M.jobTable = {
    -- スタンダードジョブ
    WAR = require('job/WAR'), -- 戦士
    MNK = require('job/MNK'), -- モンク
    WHM = require('job/WHM'), -- 白魔導士
    BLM = require('job/BLM'), -- 黒魔道士
    RDM = require('job/RDM'), -- 赤魔道士
    THF = require('job/THF'), -- シーフ
    -- エキストラジョブ
    PLD = require('job/PLD'), -- ナイト
    DRK = require('job/DRK'), -- 暗黒騎士
    BST = require('job/BST'), -- 獣使い
    BRD = require('job/BRD'), -- 吟遊詩人
    RNG = require('job/RNG'), -- 狩人
    -- エクストラジョブ(ジラート)
    SAM = require('job/SAM'), -- 侍
    NIN = require('job/NIN'), -- 忍者
    DRG = require('job/DRG'), -- 竜騎士
    SMN = require('job/SMN'), -- 召喚士
    -- エクストラジョブ(アトルガン)
    BLU = require('job/BLU'), -- 青魔導士
    COR = require('job/COR'), -- コルセア
    PUP = require('job/PUP'), -- からくり士
    -- エクストラジョブ(アルタナ)
    DNC = require('job/DNC'), -- 踊り子
    SCH = require('job/SCH'), -- 学者
    -- エクストラジョブ(アドゥリン)
    GEO = require('job/GEO'), -- 風水士
    RUN = require('job/RUN'), -- 魔導剣士
}

for name, job in pairs(M.jobTable) do
    job.parent = M
end

M.tankJobs = {
    "WAR", "MNK", "PLD", "SAM",
    "RUN"
}

M.meleeJobs = {
    "WAR", "MNK", "THF", "RDM",
    "DRK", "DRG", "SAM",
    "BLU", "COR",
    "PUP", "RUN"
}

local foods_melee = {'カルボナーラ', 'アラビアータ', '特上スシ', 'ソーススシ'}
local foods_magic = {'フルーツパフェ', 'ペアクレープ'}

local foodTable = {
    WAR = foods_melee,
    MNK = foods_melee,
    BLM = foods_magic,
    RDM = foods_melee,
    PLD = foods_melee,  -- レベル上げ用
    BST = foods_melee,  -- レベル上げ用
    RNG = foods_melee,  -- レベル上げ用
    NIN = foods_melee,
    COR = foods_melee,  -- レベル上げ用
    SCH = foods_magic,
    RUN = foods_melee,  -- レベル上げ用
    GEO = foods_magic,
}

-- https://wiki.ffo.jp/html/33806.html
local needCapacityPoints = {
    --{ 200, 15*60/3, 'input /item キャパシティリング <me>', 1 },
    { 200, 2*60*60/4, 'input /item トリゼックリング <me>', 1 },
    --{ 200, 15*60/3, 'input /item ファシリティリング <me>', 1 },
    --{ 200, 2*60*60/4, 'input /item エンドースリング <me>', 1 },
}

-- https://wiki.ffo.jp/html/487.html 専心
local needExperiencePoints = {
    --{ 200, 15*60/3, 'input /item 皇帝の指輪 <me>', 1 },
    --{ 200, 15*60/3, 'input /item クポフリートリング <me>', 1 },
    --{ 200, 60*60/4, 'input /item アニバーサリリング <me>', 1 },
    { 200, 2*60*60/4, 'input /item エチャドリング <me>', 1 },
    --{ 200, 15*60/3, 'input /item カリバーリング <me>', 1 },
}

function M.tick(player)
    local zone_id = windower.ffxi.get_info().zone
    if aczone.is_city_zone(zone_id) then
	return  -- 街中ではジョブ毎の処理はする事がない。ないよね？
    end
    local main_tick = M.jobTable[player.main_job].main_tick
    local sub_tick = M.jobTable[player.sub_job].sub_tick
    if main_tick ~= nil then
	main_tick(player)
    end
    if sub_tick ~= nil then
	sub_tick(player)
    end
    if player.status == 1 then
	local food = foodTable[player.main_job]
	local foodList = {food}
	if type(food) == "table" then
	    foodList = food
	end
	if food ~= nil then
	    for i, f in ipairs(foodList) do
		local c = "input /item "..f.." <me>"
		local level = task.PRIORITY_LOW
		-- command, delay, duration, period, eachfight
		local t = task.newTask(c, i*3, 3, 30*60/10, false)
		task.setTask(level, t)
	    end
	end
    end
end

-- 本気出す
function M.dothebest(player)
        local zone_id = windower.ffxi.get_info().zone
    if aczone.is_city_zone(zone_id) then
	return  -- 街中ではジョブ毎の処理はする事がない。ないよね？
    end
    local dothebest_sub = M.jobTable[player.sub_job].dothebest_sub
    if dothebest_sub ~= nil then
	dothebest_sub(player)
    end
    local dothebest_main = M.jobTable[player.main_job].dothebest_main
    if dothebest_main ~= nil then
	dothebest_main(player)
    end
end

-- 戦闘を安全側に倒す状況
function M.needSafety()
    -- print("needSafety")
    -- 醴泉島のかえる
    if aczone.isNear(291, "toad_pond", 120) then
	return true
    end
    -- WKR ボス相手
    local WKR_Zones = contents_wkr.Zones
    local WKR_MobNames = contents_wkr.BossNames
    local zone = windower.ffxi.get_info().zone
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then
	return false -- XXX
    end
    if utils.table.contains(WKR_Zones, zone) then
	if utils.table.contains(WKR_MobNames, mob.name) then
	    return true
	end
    end
    return false
end

return M
