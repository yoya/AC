--- mob 関連

local utils = require('utils')
local pstatus = require 'player_status'

local M = {}

-- 他との戦闘を中断してでも先に倒すべき敵
M.more_attractive_enemy_list = {
    -- カオス戦
    "Profane Circle",
    -- アンバス
    "Tyny Lycopodium",
    "Skullcap", "Bozzetto Elemental",
    "Bozzetto Housemaker", "Bozzetto Urchin", -- ミーブル回
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

-- アライアンス全員の mob.id 集合のキャッシュ。
-- 構成は探索の間ずっと変わらないので、search の頭で nil にして
-- そのループ内では 1 度だけ再構築する (毎 mob の get_party を避ける)。
local alliance_keys = {"p", "a1", "a2"}
local ally_id_set = nil

local build_ally_id_set = function()
    local set = {}
    local party = windower.ffxi.get_party()
    for _, x in ipairs(alliance_keys) do
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
            if member ~= nil and member.mob ~= nil then
                set[member.mob.id] = true
            end
        end
    end
    return set
end

-- 敵のヘイトが自分のパーティ/アライアンスに向いてるか
function is_mob_linked(mob)
    if ally_id_set == nil then
        ally_id_set = build_ally_id_set()
    end
    return ally_id_set[mob.claim_id] == true
end

local always_attackable_mobs = {
    -- ドメインベーション
    "Azi Dahaka", "Naga Raja", "Quetzalcoatl", "Mireu",
}
local non_attackable_mobs = {
    "fep2",
    "Resolute Leafkin", -- ミッション「門」
    "Exenmille", -- 過去サンドクエスト「影」
    "Naja Salaheem", -- 巨人の懐へ
    "Mnejing", -- 憂鬱なるガッサド
    -- 信徒キップドリックス。他では戦うので区別がいる
    --"Dazbog",
    --"Magh Bihu",
}

function is_mob_touchable(mob)  -- 宝箱とか
    if mob.valid_target and mob.is_npc and
	(mob.status == pstatus.IDLE or mob.status == pstatus.ENGAGED) and
	not utils.table.contains(non_attackable_mobs, mob.name) then
	-- 敵が平常、または味方にヘイトを向けている
	if mob.status == pstatus.IDLE or mob.claim_id == 0 or
	    is_mob_linked(mob) or
	    utils.table.contains(always_attackable_mobs, mob.name) then
	    return true
	end
    end
end
--- 多分、戦える敵 (レイド戦は上記の敵のみ対応)
-- spawn_type は湧き方を表すビットマスク
--   1: PC / 2: NPC (攻撃対象外) / 4: パーティメンバー /
--   8: アライアンスメンバー / 16: 敵 / 32: 扉・環境オブジェクト
-- よく見る組み合わせ
--   1: 他人の PC       2: 街の NPC、競売カウンター、伐採ポイント
--   13 (1+4+8): 自分   14 (2+4+8): パーティに入っているフェイス
--   16: モンスター     34 (2+32): 一部の扉
function is_mob_attackable(mob)
    if mob.valid_target and mob.is_npc and mob.spawn_type == 16 and
	(mob.status == pstatus.IDLE or mob.status == pstatus.ENGAGED) and
	not utils.table.contains(non_attackable_mobs, mob.name) then
	-- 戦える敵は target_type == 2。1 は固定NPCで、戦おうとして失敗する。
	-- target_type は LuaCore のビルドによっては entity_type という名前
	-- なので、無い時は素通しする
	-- デュミナスの戦闘可能な Hydra が 6 の時があったので追加
	if (mob.target_type or 2) == 2 or (mob.target_type or 6) == 6 then
	    -- 敵が平常、または味方にヘイトを向けている
	    if mob.status == pstatus.IDLE or mob.claim_id == 0 or
		is_mob_linked(mob) or
		utils.table.contains(always_attackable_mobs, mob.name) then
		return true
	    end
	end
    end
    return false
end

M.is_mob_attackable = is_mob_attackable

local ignore_mobs = {
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
--   name_match:string, prefer_mobs: string[],
--  linked_only: boolean }
function M.condition_match(pos, condition, mob)
    local d = M.distance(mob, pos)
    if condition.range ~= nil and condition.range <= d then
	return false
    end
    if condition.prefer_mobs ~= nil then
	if not utils.table.contains(condition.prefer_mobs, mob.name) then
	    return false
	end
    end
    if condition.fightable == true and
	not is_mob_attackable(mob) then
	return false
    end
    if condition.name_match ~= nil then
	local name_match_list = condition.name_match
	if type(name_match_list) ~= "table" then
	    name_match_list = { name_match_list }
	end
	local name_match = false
	for _, name in ipairs(name_match_list) do
	    local a = string.find(mob.name, name)
	    if a ~= nil then
		name_match = true
		break
	    end
	end
	if not name_match then
	    return  false
	end
    end
    if condition.linked_only and not is_mob_linked(mob) then
	return false
    end
    return true
end

function M.search_mobs(pos, condition)
    ally_id_set = nil  -- この探索用に作り直す
    local mob_arr = windower.ffxi.get_mob_array()
    local mobs = {}
    for i, m in pairs(mob_arr) do
	if M.condition_match(pos, condition, m) and is_mob_attackable(m) then
	    table.insert(mobs, m)
	end
    end
    return mobs
end

function M.search_nearest_mob(pos, condition)
    ally_id_set = nil  -- この探索用に作り直す
    local mob_arr = windower.ffxi.get_mob_array()
    local mob = nil
    local dist = 99999    
    local linked = false
    if pos == nil then
	pos = {x=0,y=0,z=0}
	M.get_mob_position(pos, "me")
	-- print(pos.x ,pos.y, pos.z)
    end
    for i, m in pairs(mob_arr) do
	if M.condition_match(pos, condition, m) and is_mob_attackable(m) then
	    local d = M.distance(m, pos)
	    -- ヘイトが自分らに向いてる敵がいる場合、そっちを優先
	    if d < dist or (linked == false and m.claim_id > 0) and
		not utils.table.contains(ignore_mobs, m.name) then
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
        if member.mob ~= nil and member.mob.status == pstatus.ENGAGED then
            local index = member.mob.target_index
            if index > 0 then
                local mob = windower.ffxi.get_mob_by_index(index)
                if is_mob_attackable(mob) then
                    return mob
                end
            end
        end
    end
    return nil
end

function M.get_mob_position(pos, target)
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
