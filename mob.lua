--- mob 関連

local utils = require('utils')
local io_chat = require('io/chat')

local M = {}

function isMobAttackableTargetIndex(index)
    if index == 0 then -- 占有されてない
        return true
    end
    local party = windower.ffxi.get_party()
    for x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
            if member.mob ~= nil then
                if index == member.mob.target_index then
                    return true
                end
            end
        end
    end
    return false
end

--- 多分、戦える敵 (レイド戦には未対応)+
function isMobAttackable(mob)
    if (mob.status == 0 or mob.status == 1) and
        mob.spawn_type == 16 and
        isMobAttackableTargetIndex(mob.target_index) then
        return true
    end
end

M.isMobAttackable = isMobAttackable

local ignoreMobs = {
    "fep2",
    "Resolute Leafkin", -- ミッション「門」
}
M.getNearestFightableMob = function(pos, dist, preferMobs)
--    print("M.getNearestFightableMob", preferMobs);
--    M.io_chat.print("getNearestFifhtableMob")
-- 距離(デフォルト20)以内だけ対象
    local mob = nil
    local mobArr = windower.ffxi.get_mob_array()
    for i, m in pairs(mobArr) do
        --- リンクすると status が 1になるので対象にする
--        print("preferMobs: " ..  m.name, "  c:", preferMobs:contains(m.name))
        if ( preferMobs == nil or utils.contains(preferMobs, m.name)) and
            isMobAttackable(m) then
            local dx = m.x - pos.x
            local dy = m.y - pos.y
            local dz = m.z - pos.z
            d = math.sqrt(dx*dx + dy*dy)
            --- 高さが８違うのは無視。
            if m.x ~= 0 and m.y ~= 0 and m.z ~= 0 and d < dist and math.abs(dz) < 1 then
--             if m.name == "Water Elemental" then
--                    io_chat.print(i .. ": name:" .. m.name ..", dist:".. m.distance .. ", status:".. m.status ..", d:".. d)
--                io_chat.print(m)
--             end
                if utils.contains(ignoreMobs, m.name) == false then
--                if m.name ~= "fep2" then 
                    mob = m
                    dist = d
                end
            end
        end
    end
---    print("mob", mob.name)
    return mob
end

-- パーティで戦闘中のモンスターがいれば、それを返す
M.PartyTargetMob = function()
--    io_chat.print("PartyTargetMob")
    local party = windower.ffxi.get_party()
    for i = 1, 5 do -- 自分以外
        local member = party["p"..i]
        if member.mob ~= nil and member.mob.status == 1 then
            local index = member.mob.target_index
            if index > 0 then
                local mob = windower.ffxi.get_mob_by_index(index)
                if isMobAttackable(mob) then
                    return mob
                end
            end
        end
    end
    return nil
end

function M.getMobPosition(pos, target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
---        print("not found mob by target:" ..target)
	return false
    end
    pos.x = mob.x
    pos.y = mob.y
    pos.z = mob.z
    return true
end

return M
