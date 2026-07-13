-- 戦闘関連。特に釣り

local M = {}

-- 戦闘スタイル

M.BATTLE_MELEE = 1 -- 物理攻撃
M.BATTLE_MAGIC = 2 -- 物理攻撃
M.BATTLE_RANGE = 3 -- 矢弾攻撃

M.battle_type = M.BATTLE_MELEE

function M.set_battle_type(battle_type)
    M.battle_type = battle_type
end

M.battleTable = {
    [M.BATTLE_MELEE]   = require 'battle/melee',   -- 近接
}
for _, obj in pairs(M.battleTable) do obj.parent = M end

function M.tick(player, me)
    local battle_object = M.battleTable[M.battle_type]
    if battle_object ~= nil then
        if battle_object.tick ~= nil then
            battle_object.tick(player, me)
        end
    end
end

return M

