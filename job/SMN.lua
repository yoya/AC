-- 召喚士

local M = {}

--- local SMN_summon_head = "input /pet 神獣の帰還 <me>; wait 3; "
--- local SMN_summon_tail = "; wait 3; input /pet 神獣の帰還 <me>"
local SMN_summon_head = ""
local SMN_summon_tail = "; wait 3; input /pet 神獣の攻撃 <t>"

M.mainJobProbTable = {
    { 200, 180, 'input /pet 神獣の加護 <me>;', 0 },
    { 200, 30, 'input /pet 神獣の攻撃 <t>;', 0 },
    { 500, 15, 'input /pet 神獣の帰還 <me>;', 0 },
    -- { 50, 1200 / 50, 'input /ma タイタン召喚 <me>; wait 7; input /pet 大地の守り <me>; wait 3; input /pet 神獣の攻撃 <t>;', 15 },
    { 50, 1200 / 50, SMN_summon_head .. 'input /ma イフリート召喚 <me>; wait 7; input /pet 紅蓮の咆哮 <me>; wait 3; input /pet メテオストライク <t>' .. SMN_summon_tail, 15 },
    { 50, 1200 / 10,  SMN_summon_head .. 'input /ma ガルーダ召喚 <me>; wait 7; input /pet ヘイスガII <me>; wait 3; input /pet ウインドブレード <t>' .. SMN_summon_tail, 15 },
    { 50, 1200 / 20,  SMN_summon_head .. 'input /ma シヴァ召喚 <me>; wait 7; input /pet クリスタルブレシング <me>; wait 3; input /pet ヘヴンリーストライク <t>' .. SMN_summon_tail, 15 },
    { 50, 1200 / 20,  SMN_summon_head .. 'input /ma フェンリル召喚 <me>; wait 7; input /pet 上弦の唸り <me>; wait 3; input /pet インパクト <t>' .. SMN_summon_tail, 15 },
    { 5, 1200 / 10,  SMN_summon_head .. 'input /ma ケット・シー召喚 <me>; wait 7; input /pet リレイズII <me>' .. SMN_summon_tail, 15 },
    { 1, 1200 / 10,  SMN_summon_head .. 'input /ma ケット・シー召喚 <me>; wait 7; input /pet リレイズII <p1>' .. SMN_summon_tail, 15 },
    { 1, 1200 / 10,  SMN_summon_head .. 'input /ma ケット・シー召喚 <me>; wait 7; input /pet リレイズII <p2>' .. SMN_summon_tail, 15 },
    { 10, 300 / 2,  SMN_summon_head .. 'input /ma 光精霊召喚 <me>; wait 7; input /ja エレメントサイフォン <me>' .. SMN_summon_tail, 15 },
}

-- M.subJobProbTable = { }

return M
