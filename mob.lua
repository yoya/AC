--- mob 関連

local utils = require('utils')
local io_chat = require('io/chat')

local M = {}

-- 他との戦闘を中断してでも先に倒すべき敵
M.moreAttractiveEnemyList = {
    -- カオス戦
    "Profane Circle",
    -- アンバス
    "Tyny Lycopodium",
    "Skullcap", "Bozzetto Elemental",
    -- 醴泉島
    "Wretched Poroggo", "Water Elemental",
    -- Void Watch
    "Gloam Servitor", -- ルフェーゼ
    "Bloodswiller Fly", -- "Tsui-Goab", -- ミザレオ
    "Little Wingman", -- ウルガラン
    "Bloody Skull", -- アットワ
    "Primordial Pugil", -- ビビキー
    -- プロマシア
    "Gargoyle",
    -- アルタナM
    "Atomos", "Aquila", "Haudrale",
}

-- ドメインベーションの敵一覧
M.domain_enemy_list = { "Azi Dahaka","Azi Dahaka's Dragon",
			"Naga Raja", "Naga Raja's Lamia",
			"Quetzalcoatl", "Quetzalcoatl's Sibilus",
			"Mireu" }

-- 敵のヘイトが自分のパーティ/アライアンスに向いてるか
function isMobLinked(mob)
    local party = windower.ffxi.get_party()
    for _, x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
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
    "Exenmille", -- 過去サンドクエスト「影」
    "Naja Salaheem", -- 巨人の懐へ
    "Mnejing", -- 憂鬱なるガッサド
}

function isMobTouchable(mob)  -- 宝箱とか
    if mob.valid_target and mob.is_npc and
	(mob.status == 0 or mob.status == 1) and
	not utils.table.contains(nonAttackableMobs, mob.name) then
	-- 敵が平常、または味方にヘイトを向けている
	if mob.status == 0 or mob.claim_id == 0 or
	    isMobLinked(mob) or
	    utils.table.contains(alwaysAttackableMobs, mob.name) then
	    return true
	end
    end
end
--- 多分、戦える敵 (レイド戦は上記の敵のみ対応)
function isMobAttackable(mob)
    if mob.valid_target and mob.is_npc and mob.spawn_type == 16 and
	(mob.status == 0 or mob.status == 1) and
	not utils.table.contains(nonAttackableMobs, mob.name) then
	-- 敵が平常、または味方にヘイトを向けている
	if mob.status == 0 or mob.claim_id == 0 or
	    isMobLinked(mob) or
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
    if a == nil or b == nil then
	print(debug.traceback())
	return 99999
    end
    local dx = b.x - a.x
    local dy = b.y - a.y
    local dz = b.z - a.z
    return  math.sqrt(dx*dx + dy*dy + dz*dz*5)
end

-- condition
-- { fightable: bool, range: number,
--   nameMatch:string, preferMobs: string[],
--  linkedOnly: boolean }
function M.conditionMatch(pos, condition, mob)
    local d = M.distance(mob, pos)
    if condition.range ~= nil and condition.range <= d then
	return false
    end
    if condition.preferMobs ~= nil then
	if not utils.table.contains(condition.preferMobs, mob.name) then
	    return false
	end
    end
    if condition.fightable == true and
	not isMobAttackable(mob) then
	return false
    end
    if condition.nameMatch ~= nil then
	local nameMatchList = condition.nameMatch
	if type(nameMatchList) ~= "table" then
	    nameMatchList = { nameMatchList }
	end
	local nameMatch = false
	for _, name in ipairs(nameMatchList) do
	    local a, b = string.find(mob.name, name)
	    if a ~= nil then
		nameMatch = true
		break
	    end
	end
	if not nameMatch then
	    return  false
	end
    end
    if condition.linkedOnly and not isMobLinked(mob) then
	return false
    end
    return true
end

function M.searchMobs(pos, condition)
    local mobArr = windower.ffxi.get_mob_array()
    local mobs = {}
    for i, m in pairs(mobArr) do
	if M.conditionMatch(pos, condition, m) and isMobAttackable(m) then
	    table.insert(mobs, m)
	end
    end
    return mobs
end

function M.searchNearestMob(pos, condition)
    local mobArr = windower.ffxi.get_mob_array()
    local mob = nil
    local dist = 99999    
    local linked = false
    if pos == nil then
	pos = {x=0,y=0,z=0}
	M.getMobPosition(pos, "me")
	-- print(pos.x ,pos.y, pos.z)
    end
    for i, m in pairs(mobArr) do
	if M.conditionMatch(pos, condition, m) and isMobAttackable(m) then
	    local d = M.distance(m, pos)
	    -- ヘイトが自分らに向いてる敵がいる場合、そっちを優先
	    if d < dist or (linked == false and m.claim_id > 0) and
		not utils.table.contains(ignoreMobs, m.name) then
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
    if pos == nil then
	print(debug.traceback())
	return false
    end
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
