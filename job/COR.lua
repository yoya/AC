-- コルセア

local M = {}

M.mainJobProbTable = {
    -- { 200, 60, 'input /ja コルセアズロール <me>; wait 2; input /ja ダブルアップ <me>', 0 },
    { 50, 300-30, 'input /ja ブリッツァロール <me>', 1 },
    { 100, 60, 'input /ja サムライロール  <me>', 1 },
    { 100, 60, 'input /ja カオスロール  <me>', 1 },
    { 100, 60, 'input /ja ファイターズロール  <me>', 1 },
    -- { 100, 60, 'input /ja メガスズロール  <me>', 1 },
    -- { 100, 60, 'input /ja ウィザーズロール  <me>', 1 },
    --[[
	{ 100, 60, 'input /ja ガランツロール <me>', 1 },
	{ 100, 60, 'input /ja ダンサーロール <me>', 1 },
    ]]
}

M.subJobProbTable = {
    -- { 100, 60, 'input /ja コルセアズロール <me>;'' wait 2; /ja ダブルアップ <me>', 1 },
    { 100, 60, 'input /ja コルセアズロール <me>', 1 },
    -- { 100, 60, 'input /ja サムライロール  <me>', 1 },
    -- { 100, 60, 'input /ja カオスロール  <me>', 1 },
    -- { 100, 60, 'input /ja ファイターズロール  <me>', 1 },
}

return M
