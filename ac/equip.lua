-- 装備関連

local M = {}

local res_name = require 'res_name'

local utils = require 'utils'
local control = require 'control'
local acitem_data = require 'item/data'
local io_chat = require 'io/chat'
local pstatus = require 'player_status'

-- 装束を装着する部位 (slot)
local equip_slots = {
    main = 0, sub = 1, range = 2, ammo = 3,
    head = 4, body = 5, hands = 6, legs = 7, feet = 8,
    neck = 9, waist = 10, left_ear = 11, right_ear = 12,
    left_ring = 13, right_ring = 14, back = 15
}
local equip_slots_keys = utils.table.swap_key_value_table(equip_slots)

-- 装束の装着を指定できる bag の種類
local equip_bags = {
    inventory = 0,
    wardrobe = 8,
    wardrobe2 = 10,
    wardrobe3 = 11,
    wardrobe4 = 12,
    wardrobe5 = 13,
    wardrobe6 = 14,
    wardrobe7 = 15,
    wardrobe8 = 16,
}
local equip_bags_keys = utils.table.swap_key_value_table(equip_bags)

-- Usage: equip_item("right_ring")
function M.equip_item_by_slot_name(slot_name)
    if type(slot_name) == "number" then  -- 番号でも指定できるように
	slot_name = equip_slots_keys[slot_name]
    end
    local items = windower.ffxi.get_items()
    local id = items.equipment[slot_name]  -- bag 内 id
    local bag = items.equipment[slot_name.."_bag"]  -- どの bag か
    local bag_items = windower.ffxi.get_items(bag)
    if bag_items[id] == nil then
	print("Error: id:"..id.." bag:"..bag)
	return nil
    end
    local item_id = bag_items[id].id  --(items[id] が nilのエラーが出た事がある)
    return item_id
end

-- 記録しているのは item id ではなくバッグ内の位置 (inv_id, bag) なので、
-- キャラやジョブが変われば同じ位置は別の物を指す。持ち越さず捨てる
local equip_set = {}
local equip_set_bank = {}

function M.init()
    equip_set = {}
    equip_set_bank = {}
end

-- 装備中の装束を記録する
function M.equip_save(arg)
    --    if control.debug then
    if control.debug then
	if arg == nil then
	    -- 表示が多すぎるので arg 指定なしは表示一旦なし
	    -- io_chat.noticef("equip_save:nil", arg)
	else
	    io_chat.noticef("equip_save:%s", arg)
	end
    end
    if arg ~= nil and equip_set_bank[arg] == nil then
	equip_set_bank[arg] = {}
    end
    local items = windower.ffxi.get_items()
    for name, slot  in pairs(equip_slots) do
	local inv_id = items.equipment[name]  -- bag 内 id
	local bag = items.equipment[name.."_bag"]  -- どの bag か
	if inv_id > 0 then  -- 装備している場合
	    local equip_item = { inv_id=inv_id, slot=slot, bag=bag }
	    if arg == nil then
		equip_set[name] = equip_item
	    else
		equip_set_bank[arg][name] = equip_item
	    end
	end
    end
    if control.debug then
	if arg ~= nil then
	    M.equip_show(arg)
	end
    end
end

-- 記録してある装束を装着する
function M.equip_restore(arg)
    if control.debug then
	io_chat.noticef("equip_restore:%s", arg)
    end
    local main_weapon_item_id = M.equip_item_by_slot_name("main")
    if acitem_data.trial_weapon_id_set[main_weapon_item_id] == true then
	return -- トライアル武器はそのまま維持
    end
    if control.debug then
	if arg ~= nil then
	    M.equip_show(arg)
	end
    end
    local _equip_set = equip_set
    if arg ~= nil then
	if equip_set_bank[arg] == nil then
	    io_chat.errorf("equip_restore: no bank: %s", arg)
	    return
	end
	_equip_set = equip_set_bank[arg]
    end
    for name, e in pairs(_equip_set) do
	windower.ffxi.set_equip(e.inv_id, e.slot, e.bag)
    end
end

function M.equip_show(arg)
    local _equip_set = equip_set
    if arg ~= nil then
	if equip_set_bank[arg] == nil then
	    io_chat.errorf("equip_restore: no bank: %s", arg)
	    return
	end
	_equip_set = equip_set_bank[arg]
    end
    local items = windower.ffxi.get_items()  -- 表示するだけなのでループ外で 1 回
    for name, e in pairs(_equip_set) do
	local slot_name = equip_slots_keys[e.slot]
	local bag_name = equip_bags_keys[e.bag]
	local bag_items = items[bag_name]
	local item = bag_items[e.inv_id]
	local item_ja = res_name.item_ja(item.id)
	io_chat.printf("%s %s %s", slot_name, bag_name, item_ja)
    end
end

function M.equip_item(slot, item_id)
    if type(slot) == "string" then  -- 文字列でも指定できるように
	slot = equip_slots[slot]
    end
    local bag, inv_id = M.search_equip_item(item_id)
    -- print("ac/equip", slot, item_id, bag, inv_id)
    if bag ~= nil then
	windower.ffxi.set_equip(inv_id, slot, bag)
    end
end

-- skip_equipped が true の時は、装備中のものを候補から外す。
-- 装備中の 1 個を別の部位に付け替えると、元の部位が空になるため。
function M.search_equip_item(item_id, skip_equipped)
    local items = windower.ffxi.get_items()
    for name, bag_id in pairs(equip_bags) do
	local bag = items[name]
	if bag ~= nil then
	    for i, e in ipairs(bag) do
		if e.id == item_id and not (skip_equipped and e.status ~= 0) then
		    return equip_bags[name], e.slot
		end
	    end
	end
    end
end

-- 左右の指/耳や main/sub のように、同じアイテムが複数の部位の候補に
-- 入っている事がある。1 個しか持っていないものを取り合うと、後から
-- 付けた部位に移動して先の部位が空になる (装備が脱げる) ので、この
-- 呼び出しで使った id を覚えておき、装備中のものは候補から外す。
function M.equip_item_by_priority_tree(item_tree)
    local items = windower.ffxi.get_items()
    local equiped_item_ids = {}  -- 部位 -> 今その部位に付いているアイテムの id
    for name in pairs(equip_slots) do
	local inv_id = items.equipment[name]
	local bag = items[equip_bags_keys[items.equipment[name.."_bag"]]]
	if inv_id > 0 and bag ~= nil and bag[inv_id] ~= nil then
	    equiped_item_ids[name] = bag[inv_id].id
	end
    end
    local used_item_ids = {}
    for slot_name, ids in pairs(item_tree) do
	local slot = equip_slots[slot_name]
	for _, id in ipairs(ids) do
	    if id == equiped_item_ids[slot_name] then
		used_item_ids[id] = true  -- 既にこの部位に付いている
		break
	    elseif used_item_ids[id] ~= true then
		-- 他の部位が使ったものは、奪うと向こうが空になるので飛ばす
		local bag, inv_id = M.search_equip_item(id, true)
		-- print("slot, id, bag, inv_id", slot, id, bag, inv_id)
		if bag ~= nil then
		    windower.ffxi.set_equip(inv_id, slot, bag)
		    used_item_ids[id] = true
		    break
		end
	    end
	end
    end
    -- 装備を送った後の 1 秒。job/COR.lua がこの sleep を当てにしている
    coroutine.sleep(1)
    -- ここでロックを掛けない。元は「着替えるとロックが外れるので」入れたが、
    -- この関数は戦闘開始 (job.battle_start) から毎回呼ばれるようになった。
    -- 掛けたロックを外す者がいないので、戦闘後にタゲが隣の味方へ移ると
    -- そこで固定され、io/net の 0x058 注入が通らなくなる。以降ずっと
    -- 「攻撃対象ではありません」を撃ち続ける。
    -- ロックが要る所 (モグガーデン、シナジー、works) は自分で掛けている
end
    
function M.tick(player)
    if player == nil then return end
    if player.status == pstatus.ENGAGED then
	-- 118 は 妖蟲の髪飾り+1 用に許容する
	if player.item_level == nil or player.item_level <= 109 then
	    M.equip_restore() -- 裸にされたら装備を戻す。
	elseif 118 <= player.item_level then
	    M.equip_save()
	end
    end
end

M.city_equip = {
    -- body = { 27923 }, -- カウンセラーガーブ
    right_ring = { 27590 }, -- シュネデックリング
}

M.walk_equip = { -- status 0 の時
    left_ring = {
	26184 -- スティキニリング+1
    },
    right_ring = { 27590 }, -- シュネデックリング
}

return M
