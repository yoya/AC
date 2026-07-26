local M = {}

M.PULL_MELEE   = 1  -- 漢釣り
M.PULL_DISTANT = 2  -- 遠隔釣り。挑発/気功弾、フラッシュ/ディア、矢弾など

M.pull_type = M.PULL_MELEE  -- デフォルト、漢釣り

M.base_pos = nil  -- {x,y,z}

function M.set_pull_type(pull_type)
    M.pull_type = pull_type
end

M.pull_table = {
    [M.PULL_MELEE]   = require 'pull/melee',   -- 漢釣り
    [M.PULL_DISTANT] = require 'pull/distant',   -- 遠隔釣り
}
for _, obj in pairs(M.pull_table) do obj.parent = M end

function M.tick(player)
    -- print("pull.tick")
    local pull_object = M.pull_table[M.pull_type]
    if pull_object ~= nil then
	if pull_object.tick ~= nil then
	    pull_object.tick(player)
	end
    end
end

return M
