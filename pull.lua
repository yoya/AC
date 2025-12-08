local M = {}

M.MELEE   = 1  -- 漢釣り
M.DISTANT = 2  -- 遠隔釣り。挑発/気功弾、フラッシュ/ディア、矢弾など

M.pull_type = M.MELEE  -- デフォルト、漢釣り

function M.set_pull_type(pull_type)
    M.pull_type = pull_type
end

M.pullTable = {
    [M.MELEE]   = require 'pull/melee',   -- 漢釣り
    [M.DISTANT] = require 'pull/distant',   -- 遠隔釣り
}
for _, obj in pairs(M.pullTable) do obj.parent = M end

function M.tick(player)
    local pull_object = M.pullTable[M.pull_type]
    if pull_object ~= nil then
	if pull_object.tick ~= nil then
	    pull_object.tick(player)
	end
    end
end

return M
