--- Position
--- 位置関係の関数郡

local M = {}

function target_pos(t)
    local mob = windower.ffxi.get_mob_by_target(t)
    if mob == nil then
        return nil
    end
    return {x=mob.x, y=mob.y, z=mob.z}
end
M.target_pos = target_pos

function target_distance(t)
    local mob = windower.ffxi.get_mob_by_target(t)
    if mob == nil then
        return nil
    end
    return mob.distance
end
M.target_distance = target_distance

function current_pos()
    return target_pos("me")
end
M.current_pos = current_pos

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

function distance_x(pos1, pos2)
    if pos1 == nil or pos2 == nil then
        return 99999
    end
    return math.abs(pos1.x - pos2.x)
end

function distance_y(pos1, pos2)
    if pos1 == nil or pos2 == nil then
        return 99999
    end
    return math.abs(pos1.y - pos2.y)
end

function is_near(pos, dist, distX, distY)
    local me_pos = current_pos()
    if me_pos == nil then
	return false
    end
    local d = distance(me_pos, pos)
    local dx = distance_x(me_pos, pos)
    local dy = distance_y(me_pos, pos)
    if dist == nil and distX == nil and distY == nil then
	dist = 1.0
    end
    if dist ~= nil and dist < d then
        return false
    end
    if distX ~= nil and distX < dx then
        return false
    end
    if distY ~= nil and distY < dy then
        return false
    end
    return true
end
M.is_near = is_near

return M
