-- 戦士

local M = {}

local role_Melee = require 'role/Melee'
local task = require 'task'
local ac_party = require 'ac/party'
local io_chat = require('io/chat')

M.mainJobProbTable = {
    { 100, 300/2, 'input /ja ウォークライ <me>', 0 },
    -- { 60, 10, 'input /ja バーサク <me>', 0 },
    -- { 60, 300, 'input /ja アグレッサー <me>', 0 },
    { 100, 300/2, 'input /ja ブラッドレイジ <me>', 0 },
    -- { 100, 60, 'input /ja 挑発 <t>', 0 },
    { 100, 600/2, 'input /ja リストレント <me>', 0 },
    { 100, 180/2, 'input /ja リタリエーション <me>', 0},
}

M.subJobProbTable = {
    { 100, 300, 'input /ja ウォークライ <me>', 1 },
    -- { 100, 60, 'input /ja 挑発 <t>', 1 },
    -- { 100, 300, 'input /ja バーサク <me>', 0 },
    { 100, 300/2, 'input /ja アグレッサー <me>', 0 },
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
    if player.status ~= 1 then
	return  -- 戦闘中でなければ、何もしない
    end
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    if 119 <= player.item_level then
	provoke(player)  -- 挑発
    end
end

function M.sub_tick(player)
    if player.status ~= 1 then
	return  -- 戦闘中でなければ、何もしない
    end
    if 119 <= player.item_level then
	local main_job = player.main_job
	-- if main_job == "PLD" or main_job == "MNK" or main_job == "SAM" then
	if main_job == "PLD" or main_job == "SAM" then
	    -- 頑丈なジョブは挑発もアタッカーアビも使う
	    attacker(player)
	    provoke(player)
	elseif ac_party.hasTankJobMemberInParty() then
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

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local jaList = { "アグレッサー", "バーサク", "ウォークライ",
		     "ブラーゼンラッシュ", "マイティストライク"}
    for i, ja_name in ipairs(jaList) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.newTask(c, (i-1)*2, 2, 10, false)
	task.setTask(level, t)
    end
end

function M.dothebest_sub(player)
    local level = task.PRIORITY_HIGH
    local jaList = { "アグレッサー", "バーサク", "ウォークライ"}
    for i, ja_name in ipairs(jaList) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.newTask(c, (i-1)*2, 2, 10, false)
	task.setTask(level, t)
    end
end

return M
