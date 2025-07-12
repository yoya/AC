-- からくり士

local M = {}

M.mainJobProbTable = {
    { 100, 1200, 'input /ja アクティベート <me>', 0 },
    { 100, 60, 'input /ja 応急処置 <me>', 0 },
    { 500, 60, 'input /pet ディプロイ <t>', 0, true },
    { 200, 300, 'input /ja クールダウン <me>', 0 },
    { 200, 90, 'input /pet ファイアマニューバ <me>', 0 },
    { 100, 90, 'input /pet ライトマニューバ <me>', 0 },
}

M.subJobProbTable = { }

return M
