-- 戦士

local M = {}

local role_Melee = require 'role/Melee'
local task = require 'task'
local ac_party = require 'ac/party'

M.mainJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 0 },
    -- { 60, 10, 'input /ja バーサク <me>', 0 },
    -- { 60, 300, 'input /ja アグレッサー <me>', 0 },
    { 100, 300, 'input /ja ブラッドレイジ <me>', 0 },
    -- { 100, 60, 'input /ja 挑発 <t>', 0 },
    { 100, 600, 'input /ja リストレント <me>', 0 },
    { 100, 180, 'input /ja リタリエーション <me>', 0},
}

M.subJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 1 },
    -- { 100, 60, 'input /ja 挑発 <t>', 1 },
    -- { 100, 300, 'input /ja バーサク <me>', 0 },
    { 100, 300, 'input /ja アグレッサー <me>', 0 },
}

function provoke(player) -- 挑発
    local level = task.PRIORITY_HIGH
    local c = "input /ja 挑発 <t>"
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 0, 1, 30, false)
    if player.status == 1 then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function attacker(player)  -- アタッカー
    local level = task.PRIORITY_HIGH
    local c1 = "input /ja バーサク <me>"
    local c2 = "input /ja アグレッサー <me>"
    -- command, delay, duration, period, eachfight
    local t1 = task.newTask(c1, 0, 1, 30, false)
    local t2 = task.newTask(c2, 0, 1, 30, false)
    if player.status == 1 then
	task.setTask(level, t1)
	task.setTask(level, t2)
    else
	task.removeTask(level, t1)
	task.removeTask(level, t2)
    end
end

function defender(player) -- ディフェンダー
    local level = task.PRIORITY_HIGH
    local c = "input /ja ディフェンダー <me>"
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 0, 1, 30, false)
    if player.status == 1 then
	task.setTask(level, t)
    else
	task.removeTask(level, t)
    end
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    if 119 <= player.item_level then
	provoke(player)  -- 挑発
    end
end

function M.sub_tick(player)
    if 119 <= player.item_level then
	if ac_party.hasTankJobMemberInParty() then
	    -- パーティに盾ジョブがいる場合は、安心してアタッカーアビを使う
	    attacker(player)
	else
	    provoke(player)  -- 盾ジョブがいない時は、挑発を使う
	end
	local hp = player.vitals.hp
	if hp < 1000 then -- 危ない時は防御
	    io_chat.setNextColor(3)
	    io_chat.printf("HP: %d < 1000 => ディフェンダー", hp)
	    defender(player) -- ディフェンダー
	end
    end
end

return M
