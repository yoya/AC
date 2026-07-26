-- 戦闘関連。特に釣り

local M = {}

local command = require 'command'
local ac_equip = require 'ac/equip'
local acjob = require 'job'
-- 戦闘スタイル

M.BATTLE_MELEE = 1 -- 物理攻撃
M.BATTLE_MAGIC = 2 -- 物理攻撃
M.BATTLE_RANGE = 3 -- 矢弾攻撃

M.battle_type = M.BATTLE_MELEE

function M.set_battle_type(battle_type)
    M.battle_type = battle_type
end

M.battle_table = {
    [M.BATTLE_MELEE]   = require 'battle/melee',   -- 近接
}
for _, obj in pairs(M.battle_table) do obj.parent = M end

M.orig_equip_right_ring_item_id = nil

function M.start()
    -- print("battle start")
    -- 戦闘用装備に着替える
    -- right_ring = 14
    local slot_name = "right_ring"
    local slot = 14
    local item_id = M.orig_equip_right_ring_item_id
    if item_id ~= nil then
	ac_equip.equip_item(slot, item_id)
    end
    acjob.battle_start()
end

function M.finish()
    -- print("battle finish")
    -- 次に戦う予定がない(attack off でリンクする敵もいない)場合、
    -- 移動装備に着替える
    -- right_ring = 14
    local slot_name = "right_ring"
    local orig_item_id = ac_equip.equip_item_by_slot_name(slot_name)
    if orig_item_id ~= nil then
	M.orig_equip_right_ring_item_id = orig_item_id
    end
    local item_id = 27590  -- シュネデックリング
    local slot = 14
    ac_equip.equip_item(slot, item_id)
end

function M.tick(player, me)
    -- print("battle.tick")
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil then return end
    if mob.name == player.name or mob.distance > 100 then
	-- 稀に自分をタゲる事があるので、その時は一旦戦闘終了
	-- 敵と距離がありすぎる時も何かおかしいので戦闘終了
	command.send('input /attack off')
    end
    local battle_object = M.battle_table[M.battle_type]
    if battle_object ~= nil then
        if battle_object.tick ~= nil then
            battle_object.tick(player, me, mob)
        end
    end
end

return M

