-- コルセア

local M = {}

M.mainJobProbTable = {
    -- { 200, 60, 'input /ja コルセアズロール <me>; wait 2; input /ja ダブルアップ <me>', 0 },
    { 50, 300, 'input /ja ブリッツァロール <me>', 3 },
    { 100, 60, 'input /ja サムライロール  <me>', 3 },
    { 100, 60, 'input /ja カオスロール  <me>', 3 },
    { 100, 60, 'input /ja ファイターズロール  <me>', 3 },
    -- { 100, 60, 'input /ja メガスズロール  <me>', 3 },
    -- { 100, 60, 'input /ja ウィザーズロール  <me>', 3 },
    --[[
	{ 100, 60, 'input /ja ガランツロール <me>', 3 },
	{ 100, 60, 'input /ja ダンサーロール <me>', 3 },
    ]]
}

M.subJobProbTable = {
    -- { 100, 60, 'input /ja コルセアズロール <me>;'' wait 2; /ja ダブルアップ <me>', 3 },
    { 100, 60, 'input /ja コルセアズロール <me>', 3 },
    -- { 100, 60, 'input /ja サムライロール  <me>', 3 },
    -- { 100, 60, 'input /ja カオスロール  <me>', 3 },
    -- { 100, 60, 'input /ja ファイターズロール  <me>', 3 },
}

return M
