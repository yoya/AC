-- 戦闘関連。特に釣り

local M = {}

local command = require 'command'
local control = require 'control'
local keyboard = require 'keyboard'
local push_keys = keyboard.push_keys

local ac_equip = require 'ac/equip'
local incoming_text = require 'incoming/text'
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
M.incoming_text_listener_id = nil

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
    if M.incoming_text_listener_id ~= nil then
	incoming_text.remove_listener(M.incoming_text_listener_id)
	M.incoming_text_listener_id = nil
    end
    M.incoming_text_listener_id = incoming_text.add_listener("", M.incoming_text_handler)
end

function M.finish()
    if M.incoming_text_listener_id ~= nil then
	incoming_text.remove_listener(M.incoming_text_listener_id)
	M.incoming_text_listener_id = nil
    end
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
    -- mob.distance は距離の2乗。素で比べると 10 より遠い敵で戦闘終了になり、
    -- 遠くの敵に向かう間ずっと attack off と on を繰り返す
    if mob.name == player.name or math.sqrt(mob.distance) > 100 or
	mob.in_party or mob.in_alliance then
	-- 稀に自分をタゲる事があるので、その時は一旦戦闘終了
	-- 敵と距離がありすぎる時も何かおかしいので戦闘終了
	-- パーティメンバーも戦ってたらやめる
	command.send('input /attack off')
	return  -- やめた直後に melee.tick が /attack <t> を打ち直さないように
    end
    local battle_object = M.battle_table[M.battle_type]
    if battle_object ~= nil then
        if battle_object.tick ~= nil then
            battle_object.tick(player, me, mob)
        end
    end
end

function M.incoming_text_handler(text)
    if not control.auto then
	return
    end
    if string.contains(text, "コマンドが実行できない") and
	control.enemy_space == control.ENEMY_SPACE_NEAR then
	if string.contains(text, "近づかないとコマンドが") or
	    string.contains(text, "遠くにいるため、コマンドが")then
	    if control.debug then
		io_chat.info("前に詰める")
	    end
	    keyboard.longpush_key("w", 3.0)  -- 前に詰める
	    push_keys({"a"})  -- 少し左にずらす
	elseif string.contains(text, "姿が見えないためコマンドが") then
	    if control.debug then
		io_chat.info("左>後>前に移動")
	    end
	    push_keys({"a", "s", "w"})  -- 左>後>前に移動
	end
    elseif string.contains(text, "の詠唱は中断された") then
	if control.debug then
	    io_chat.warn("詠唱の中断を検知")
	end
    elseif string.contains(text, "魔法を唱えることができない") then
	if control.debug then
	    io_chat.warn("魔法 詠唱の失敗を検知")
	end
    elseif string.contains(text, "の命のカウントダウン") then
	command.send('input /item 聖水 <me> ; wait 1 ; input /item 聖水 <me>')
    elseif string.contains(text, "ターゲット選択中は使用できません。") then
	push_keys({"escape"})  -- ターゲットを外す
    end
end

return M

