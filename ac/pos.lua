--- Position
--- 位置関係の関数郡

local M = {}

local utils = require 'utils'
local array_reverse = utils.table.array_reverse

function targetPos(t)
    local mob = windower.ffxi.get_mob_by_target(t)
    if mob == nil then
        return nil
    end
    return {x=mob.x, y=mob.y, z=mob.z}
end
M.targetPos = targetPos

function targetDistance(t)
    local mob = windower.ffxi.get_mob_by_target(t)
    if mob == nil then
        return nil
    end
    return mob.distance
end
M.targetDistance = targetDistance

function currentPos()
    return targetPos("me")
end
M.currentPos = currentPos

function distance2(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    return dx * dx + dy * dy
end

function distance(pos1, pos2)
    if pos1 == nil or pos2 == nil then
        return 99999
    end
    if pos1.z ~= nil and pos2.z ~= nil then
        local dz = pos2.z - pos1.z
        if math.abs(dz) > 10 then
            return 99999
        end
    end
    return math.sqrt(distance2(pos1, pos2))
end
M.distance = distance

function isNear(pos, dist)
    local me_pos = currentPos()
    d = distance(me_pos, pos)
    if dist == nil then
	dist = 1.0
    end
    if d < dist then
        return true
    end
    return false
end
M.isNear = isNear

return M
