-- コルセア

local M = {}

local incoming_text = require('incoming/text')

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

function incoming_text_handler(player, text)
    -- print("incoming_text_handler")
end


local listener_id = incoming_text.addListener("ロール", incoming_text_handler)

return M
