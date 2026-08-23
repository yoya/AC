-- 戦士

local M = {}

local control = require 'control'
local role_Melee = require 'role/Melee'
local task = require 'task'
local ac_party = require 'ac/party'
local io_chat = require('io/chat')
local pstatus = require 'player_status'

M.main_job_prob_table = {
    { 100, 300/2, 'input /ja ウォークライ <me>', 0 },
    -- { 60, 10, 'input /ja バーサク <me>', 0 },
    -- { 60, 300, 'input /ja アグレッサー <me>', 0 },
    { 100, 300/2, 'input /ja ブラッドレイジ <me>', 0 },
    -- { 100, 60, 'input /ja 挑発 <t>', 0 },
    { 100, 600/2, 'input /ja リストレント <me>', 0 },
    { 100, 180/2, 'input /ja リタリエーション <me>', 0},
}

M.sub_job_prob_table = {
    { 100, 300, 'input /ja ウォークライ <me>', 1 },
    -- { 100, 60, 'input /ja 挑発 <t>', 1 },
    -- { 100, 300, 'input /ja バーサク <me>', 0 },
    { 100, 300/2, 'input /ja アグレッサー <me>', 0 },
}

function provoke(player) -- 挑発
    if player.vitals.hp < control.provoke then
	return  -- HP が少ないと挑発しない
    end
    local level = task.PRIORITY_HIGH
    local c = "input /ja 挑発 <t>"
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 0, 1, 30, false)
    if player.status == pstatus.ENGAGED then
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end

function attacker(player)  -- アタッカー
    local level = task.PRIORITY_HIGH
    local c1 = "input /ja バーサク <me>"
    local c2 = "input /ja アグレッサー <me>"
    -- command, delay, duration, period, eachfight
    local t1 = task.new_task(c1, 0, 1, 30, false)
    local t2 = task.new_task(c2, 0, 1, 30, false)
    if player.status == pstatus.ENGAGED then
	task.set_task(level, t1)
	task.set_task(level, t2)
    else
	task.remove_task(level, t1)
	task.remove_task(level, t2)
    end
end

function defender(player) -- ディフェンダー
    local level = task.PRIORITY_HIGH
    local c = "input /ja ディフェンダー <me>"
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 0, 1, 30, false)
    if player.status == pstatus.ENGAGED then
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end

function M.main_tick(player)
    if player.status ~= pstatus.ENGAGED then
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
    if player.status ~= pstatus.ENGAGED then
	return  -- 戦闘中でなければ、何もしない
    end
    if 119 <= player.item_level then
	local main_job = player.main_job
	-- if main_job == "PLD" or main_job == "MNK" or main_job == "SAM" then
	if main_job == "PLD" or main_job == "RUN" or main_job == "WAR" or main_job == "SAM" then
	    -- 頑丈なジョブは挑発もアタッカーアビも使う
	    attacker(player)
	    provoke(player)
	elseif ac_party.has_tank_job_member_in_party() then
	    -- パーティに盾ジョブがいる場合は、安心してアタッカーアビを使う
	    attacker(player)
	else
	    provoke(player)  -- 盾ジョブがいない時は、挑発を使う
	end
	local hp = player.vitals.hp
	if hp < 1200 then -- 危ない時は防御
	    io_chat.set_next_color(3)
	    io_chat.printf("HP:%d < 1200 => ディフェンダー", hp)
	    defender(player) -- ディフェンダー
	end
    end
end

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local ja_list = { "アグレッサー", "バーサク", "ウォークライ",
		     "マイティストライク", "ブラーゼンラッシュ"}
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.new_task(c, (i-1)*2, 2, 10, false)
	task.set_task(level, t)
    end
end

function M.dothebest_sub(player)
    local level = task.PRIORITY_HIGH
    local ja_list = { "アグレッサー", "バーサク", "ウォークライ"}
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.new_task(c, (i-1)*2, 2, 10, false)
	task.set_task(level, t)
    end
end

M.attack_equip = {
    main = {
	21779, -- ライカーゴス
	21754, -- アガノーシェ
    },
    head = {
	23797, -- クレパスクラヘルム 命中+20 攻撃+60
	25569, -- フラマツッケット+2
	25641, -- バロラスマスク
    },
    body = {
	25766, -- フロプトブレスト (命中+47 攻+53)
	25785, -- デーゴンブレスト (命中+45 攻+45)
	25767, -- サクロブレスト (命+25 攻+60)
	23798, -- クレパスクラメイル (命+20 攻+55)
	25730, -- ンジンガキュイラス (攻+55)
	25797, -- フラマコラジン+2
	25717, -- バロラスメイル
    },
    hands = {
	25835, -- フラママノポラ+2
	27139, -- バロラスミトン
    },
    legs = {
	25886, -- フラマディル+2
	25841, -- バロラスホーズ
    },
    feet = {
	25953, -- フラマガンビエラ+2
	27495, -- バロラスグリーヴ
    },
    left_ring = {
	26229, -- レコリング
	26190, -- 月光の指輪
	26189, -- 月明の指輪
	26185, -- ニックマドゥリング
	26182, -- シーリチリング
	26211, -- フラマリング
    },
    right_ring = {
	26185, -- ニックマドゥリング
	26173, -- アペートリング
	15543, -- ラジャスリング
	26182, -- シーリチリング+1
	26211, -- フラマリング
	28579, -- カッヤレスリング
	28575, -- チョージバンド -- 攻+14
	26181, -- シーリチリング
    },
}

return M
