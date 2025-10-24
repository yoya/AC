--- mob 関連

local utils = require('utils')
local io_chat = require('io/chat')

local M = {}

-- 敵のヘイトが自分のパーティ/アライアンスに向いてるか
function isMobLinked(mob)
    local party = windower.ffxi.get_party()
    for x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
            if member ~= nil and member.mob ~= nil then
                if mob.claim_id == member.mob.id then
                    return true
                end
            end
        end
    end
    return false
end

local alwaysAttackableMobs = {
    -- ドメインベーション
    "Azi Dahaka", "Naga Raja", "Quetzalcoatl", "Mireu",
}
local nonAttackableMobs = {
    "fep2",
    "Resolute Leafkin", -- ミッション「門」
}

--- 多分、戦える敵 (レイド戦は上記の敵のみ対応)
function isMobAttackable(mob)
    if mob.valid_target and mob.is_npc and mob.spawn_type == 16 and
	(mob.status == 0 or mob.status == 1) and
	not utils.table.contains(nonAttackableMobs, mob.name) then
	-- 敵が平常、または味方にヘイトを向けている
	if mob.status == 0 or mob.claim_id == 0 or
	    isMobLinked(mob.claim_id) or
	    utils.table.contains(alwaysAttackableMobs, mob.name) then
	    return true
	end
    end
end

M.isMobAttackable = isMobAttackable

local ignoreMobs = {
    "fep2",
    "Resolute Leafkin", -- ミッション「門」
}

function M.distance(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local dz = b.z - a.z
    return  math.sqrt(dx*dx + dy*dy + dz*dz*5)
end

-- condition
-- { fightable: bool, range: number,
--   nameMatch:string, preferMobs: string[],
--   ignoreMobs: string[], linkedOnly: boolean }
function M.conditionMatch(pos, condition, mob)
    local d = M.distance(mob, pos)
    if condition.range ~= nil and condition.range <= d then
	return false
    end
    if condition.fightable == true and
	not isMobAttackableTargetIndex(mob.index) then
	return false
    end
    if condition.nameMatch ~= nil then
	local a, b = string.find(mob.name, condition.nameMatch)
	if a == nil then
	    return  false
	end
    end
    if condition.linkedOnly and not isMobLinked(mob) then
	return false
    end
    return true
end

function isPreferMob(mob)
    if condition.preferMobs == nil then
	return false
    end
    if utils.table.contains(condition.preferMobs, mob.name) then
	return  true
    end
    return false
end

function M.searchNearestMob(pos, condition)
    local mobArr = windower.ffxi.get_mob_array()
    local mob = nil
    local dist = 99999    
    local linked = false
    for i, m in pairs(mobArr) do
	if M.conditionMatch(pos, condition, m) and isMobAttackable(m) then
	    local d = M.distance(m, pos)
	    -- ヘイトが自分らに向いてる敵がいる場合、そっちを優先
	    if d < dist or (linked == false and m.claim_id > 0) then
		dist = d
		mob = m
		if m.claim_id > 0 then
		    linked = true
		end
	    end
	end
    end
    return mob
end

M.getNearestFightableMob__ = function(pos, dist, preferMobs, condition)
    if condition == nil then
	condition =  {}
    end
    condition.range = dist
    condition.preferMobs = preferMobs
    return M.searchNearestMob(pos, condition)
end

M.getNearestFightableMob__ = function(pos, dist, preferMobs)
--    print("M.getNearestFightableMob", preferMobs);
--    M.io_chat.print("getNearestFifhtableMob")
-- 距離(デフォルト20)以内だけ対象
    local mob = nil
    local mobArr = windower.ffxi.get_mob_array()
    for i, m in pairs(mobArr) do
        --- リンクすると status が 1になるので対象にする
        if ( preferMobs == nil or utils.table.contains(preferMobs, m.name)) and
            isMobAttackable(m) then
            local dx = m.x - pos.x
            local dy = m.y - pos.y
            local dz = m.z - pos.z
            d = math.sqrt(dx*dx + dy*dy + dz*dz*5)
            --- 高さが８違うのは無視
            if m.x ~= 0 and m.y ~= 0 and m.z ~= 0 and d < dist and dz*dz < 8*8 then
--             if m.name == "Water Elemental" then
--                    io_chat.print(i .. ": name:" .. m.name ..", dist:".. m.distance .. ", status:".. m.status ..", d:".. d)
--                io_chat.print(m)
--             end
                if utils.table.contains(ignoreMobs, m.name) == false then
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
