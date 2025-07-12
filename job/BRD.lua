-- 吟遊詩人

local M = {}

M.mainJobProbTable = {
    --[[
	{ 100, 120, 'input /ma 重装騎兵のミンネIV <me>', 7 },
        { 200, 120, 'input /ma 重装騎兵のミンネV <me>', 7 },
        { 200, 120, 'input /ma 闘龍士のマンボ <me>', 7 },
        { 200, 120, 'input /ma 活力のエチュード <me>', 7 },
        { 200, 120, 'input /ma 戦士達のピーアンVI <me>', 7 },
    ]]
    { 150, 900-100, 'input /ma 無敵の進撃マーチ <me>', 7 },
    { 200, 900-100, 'input /ma 栄光の凱旋マーチ <me>', 7 },
    { 200, 900-100, 'input /ma 猛者のメヌエットV <me>', 7 },
    { 50, 900, 'input /ma 猛者のメヌエットIV <me>', 7 },
    { 100, 900-100, 'input /ma 剣豪のマドリガル <me>', 7 },
    { 50, 900, 'input /ma 怪力のエチュード <me>', 7 },
    { 100, 900, 'input /ma 妙技のエチュード <me>', 7 },
    -- { 100, 60, 'input /ma 魔法のフィナーレ <t>', 7, true, true },
    -- { 200, 120, 'input /ma 修羅のエレジー <t>', 7, true },
    { 200, 120, 'input /ma 魔物のレクイエムVII <t>', 7, true },
    -- { 200, 120, 'input /ma 光のスレノディII <t>', 7, true },
}

M.subJobProbTable = {
    { 300, 180/2, 'input /ma 無敵の進撃マーチ <me>', 7 },
    { 200, 180/2, 'input /ma 猛者のメヌエットIII <me>', 7 },
    -- { 200, 120, 'input /ma 戦場のエレジー <t>', 7, true },
}

return M
