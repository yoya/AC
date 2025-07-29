--- Job 毎の情報

local M = {}

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

function M.tick(player)
    local mainTick = M.jobTable[player.main_job].mainTick
    local subTick = M.jobTable[player.sub_job].subTick
    if mainTick ~= nil then
	mainTick(player)
    end
    if subTick ~= nil then
	subTick(player)
    end
end

return M
