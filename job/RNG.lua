-- 狩人

local M = {}

M.mainJobProbTable = {
    --[[
	{ 200, 300, 'input /ja 狙い撃ち <me>', 0 },
	{ 100, 60, 'input /ja スカベンジ <me>', 0 },
	{ 100, 300, 'input /ja 乱れ撃ち <me>', 0 },
	-- { 100, 180, 'input /ja エンドレスショット <me>', 0 },
	-- エンドレスとリキャスト共有
	{ 100, 180, 'input /ja ダブルショット <me>', 0 },
	{ 100, 180, 'input /ja カモフラージュ <me>; wait 1; input /ja デコイショット <me>', 0 },
	-- { 100, 180, 'input /ja ホバーショット <me>', 0 }, -- デコイと両立不可
    ]]
}

M.subJobProbTable = {
    --[[
	{ 200, 300, 'input /ja 狙い撃ち <me>', 0 },
	{ 100, 60, 'input /ja スカベンジ <me>', 0 },
	{ 100, 300, 'input /ja 乱れ撃ち <me>', 0 },
    ]]
}

return M
