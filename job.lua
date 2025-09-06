--- Job 毎の情報

local M = {}
local task = require 'task'

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

local foodTable = {
    BLM = 'ペアクレープ',
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
	if food ~= nil then
	    local c = "input /item "..food.." <me>"
	    local level = task.PRIORITY_LOW
	    -- command, delay, duration, period, eachfight
	    local t = task.newTask(c, 1, 3, 30*60/10, false)
	    task.setTask(level, t)
	end
    end
end

return M
