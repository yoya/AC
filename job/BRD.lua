-- 吟遊詩人

local M = {}

M.mainJobProbTable = {
    --[[
	{ 100, 120, 'input /ma 重装騎兵のミンネIV <me>', 8 },
        { 200, 120, 'input /ma 重装騎兵のミンネV <me>', 8 },
        { 200, 120, 'input /ma 闘龍士のマンボ <me>', 8 },
        { 200, 120, 'input /ma 活力のエチュード <me>', 8 },
        { 200, 120, 'input /ma 戦士達のピーアンVI <me>', 8 },
    ]]
    { 150, 900/2, 'input /ma 無敵の進撃マーチ <me>', 8 },
    { 300, 900/3, 'input /ma 栄光の凱旋マーチ <me>', 8 },
    { 250, 900/2, 'input /ma 猛者のメヌエットV <me>', 8 },
    { 50, 900, 'input /ma 猛者のメヌエットIV <me>', 8 },
    { 100, 900, 'input /ma 剣豪のマドリガル <me>', 8 },
    { 10, 900, 'input /ma 怪力のエチュード <me>', 8 },
    { 100, 900/2, 'input /ma 妙技のエチュード <me>', 8 },
    -- { 100, 60, 'input /ma 魔法のフィナーレ <t>', 8, true },
    -- { 200, 120, 'input /ma 修羅のエレジー <t>', 8, true },
    { 1000, 120, 'input /ma 魔物のレクイエムVII <t>', 8, true },
    -- { 200, 120, 'input /ma 光のスレノディII <t>', 8, true },
}

M.subJobProbTable = {
    { 300, 180/2, 'input /ma 無敵の進撃マーチ <me>', 8 },
    { 200, 180/2, 'input /ma 猛者のメヌエットIII <me>', 8 },
    -- { 200, 120, 'input /ma 戦場のエレジー <t>', 8, true },
}

function M.main_tick(player)
    do end
end

return M
