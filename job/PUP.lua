-- からくり士

local M = {}

M.mainJobProbTable = {
    { 200, 1200, 'input /ja アクティベート <me>', 3, true},
    { 100, 60, 'input /ja 応急処置 <me>', 3 },
    { 1000, 20, 'input /pet ディプロイ <t>', 3, true },
    { 500, 300, 'input /ja クールダウン <me>', 3 },
    { 200, 90, 'input /pet ファイアマニューバ <me>', 3 },
    { 100, 90, 'input /pet ライトマニューバ <me>', 3 },
}

M.subJobProbTable = { }

return M
