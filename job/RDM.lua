-- 赤魔導士

local utils = require 'utils'
local task = require 'task'
local role_Healer = require 'role/Healer'
local role_Melee = require 'role/Melee'
local role_Sorcerer = require 'role/Sorcerer'
local ac_party = require 'ac/party'

local pstatus = require 'player_status'

local M = {}

-- コンバート。res/job_abilities.lua [83] コンバート (recast_id=49)
local CONVERT_ABILITY_ID = 83
local CONVERT_RECAST_ID = 49
local CONVERT_MP_RATE = 0.5   -- MP がこの割合以下で撃つ
local CONVERT_HP_RATE = 0.8   -- HP↔MP が入れ替わるので、HP に余裕がある時だけ撃つ

M.main_job_prob_table = {
    { 500, 300*2, 'input /ja コンポージャー <me>', 2 },
    -- { 100, 30, 'input /ma ディスペル <t>', 3 },
    --{ 500, 180, 'input /ma ディアIII <t>', 3, true },
    --{ 500, 300, 'input /ma ディストラII <t>', 4, true },
    --{ 500, 120, 'input /ma フラズルII <t>', 4, true },
    { 100, 180*3, 'input /ma ストライII <me>', 4 },
    { 100, 300*3, 'input /ma ゲインデック <me>', 4 },
    { 100, 150*3, 'input /ma リフレシュIII <me>', 4 },
    --{ 100, 150, 'input /ma リフレシュIII <p2>', 4 },
    --{ 100, 150, 'input /ma リフレシュIII <p3>', 4 },
    { 100, 180, 'input /ma エンサンダーII <me>', 4 },
    -- { 100, 180, 'input /ma エンストーンII <me>', 4 },
    { 100, 180*3, 'input /ma ヘイストII <me>', 3 },
    { 100, 180, 'input /ma ヘイストII <p1>', 3 },
    { 100, 180, 'input /ma ヘイストII <p2>', 3 },
    { 100, 180, 'input /ma ヘイストII <p3>', 3 },
    { 100, 60*4-20, 'input /ma ファランクスII <p1>', 3 },
    { 5, 600, 'input /ma アクアベール <me>', 5},
    { 5, 300, 'input /ma ブリンク <me>', 5},
    { 5, 300, 'input /ma ストンスキン <me>', 5},
}

M.sub_job_prob_table = {
--[[
    { 10, 60, 'input /ma ケアル <p1>', 3},
    -- { 5, 600-60, 'input /ma アクアベール <me>', 5},
    { 100, 300, 'input /ma ブリンク <me>', 5},
    { 100, 300, 'input /ma ストンスキン <me>', 5},
    { 100, 300-10, 'input /ma リフレシュ <me>', 5},
    { 100, 300-10, 'input /ma リフレシュ <p2>', 5},
    -- { 500, 120, 'input /ma ディアII <t>', 4, true },
    -- { 500, 120, 'input /ma ディストラ <t>', 5, true },
    -- { 500, 120, 'input /ma フラズル <t>', 5, true },
    { 100, 120-10, 'input /ma ヘイスト <p1>', 4 },
    { 100, 120-10, 'input /ma ヘイスト <p2>', 4 },
--]]
    { 10, 120-30, 'input /ma ヘイスト <p1>', 7 },
    { 10, 120-30, 'input /ma ヘイスト <p3>', 7 },
}

-- アビリティの残りリキャスト秒。取れない時は nil。
-- nil の時はどの分岐も「使えない」側に倒れる
local function ability_recast(recast_id)
    local recasts = windower.ffxi.get_ability_recasts()
    return recasts ~= nil and recasts[recast_id] or nil
end

-- コンバートを覚えているか。サポ RDM が40未満の時、
-- get_ability_recasts は 0 (使える) を返し得るので、こちらでも確かめる
local function has_convert()
    local abilities = windower.ffxi.get_abilities()
    if abilities == nil or abilities.job_abilities == nil then
	return false
    end
    for _, id in ipairs(abilities.job_abilities) do
	if id == CONVERT_ABILITY_ID then
	    return true
	end
    end
    return false
end

-- MP が減っていて、HP に余裕があり、リキャストが空いている時にコンバート
local function convert_tick(player)
    local v = player.vitals
    if v == nil or v.max_mp == nil or v.max_mp <= 0 then
	return
    end
    if v.mp > v.max_mp * CONVERT_MP_RATE then
	return
    end
    if v.max_hp == nil or v.max_hp <= 0 then
	return  -- max_hp が 0 だと HP 0 でも下の判定を素通りする
    end
    if v.hp < v.max_hp * CONVERT_HP_RATE then
	return
    end
    if not has_convert() then
	return
    end
    local recast = ability_recast(CONVERT_RECAST_ID)
    if recast == nil or recast > 0 then
	return
    end
    -- command, delay, duration, period, eachfight
    task.set_task(task.PRIORITY_MIDDLE,
		  task.new_task('input /ja コンバート <me>', 0, 2, 10, false))
end

function M.invoke_magick_buff(player, magic, onoff, duration, need_mp)
    -- 間隔90固定なのどうにしかする
    M.invoke_magick_debuff(player, magic, onoff, duration, need_mp)
end
function M.invoke_magick_debuff(player, magic, onoff, duration, need_mp)
    if player.vitals.mp < need_mp then
	return
    end
    local level = task.PRIORITY_LOW
    local c = 'input /ma '..magic..' <t>'
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 2, duration, 90, true)
    if onoff then
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end

function M.main_tick(player)
    convert_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    if role_Sorcerer.main_tick ~= nil then
	role_Sorcerer.main_tick(player)
    end
    if role_Healer.main_tick ~= nil then
	role_Healer.main_tick(player)
    end
    if player.status == pstatus.ENGAGED then -- 戦闘中
	M.invoke_magick_debuff(player, 'ディアIII', true, 5, 45)
	-- M.invoke_magick_debuff(player, 'ディストラII', true, 5, 58)
	-- M.invoke_magick_debuff(player, 'フラズルII', true, 5, 64)
	M.invoke_magick_debuff(player, 'ディストラIII', true, 5, 84)
	M.invoke_magick_debuff(player, 'フラズルIII', true, 5, 90)
    else
	M.invoke_magick_debuff(player, 'ディアIII', false, 5, 45)
	-- M.invoke_magick_debuff(player, 'ディストラII', false, 5, 58)
	-- M.invoke_magick_debuff(player, 'フラズルII', false, 5, 64)
	M.invoke_magick_debuff(player, 'ディストラIII', false, 5, 84)
	M.invoke_magick_debuff(player, 'フラズルIII', false, 5, 90)
    end
    for id, info in pairs(ac_party.member_table) do
	if utils.table.contains({"BLM", "WHM", "PLD", "RUN", "GEO"}, info.main_job) then
	    local level = task.PRIORITY_LOW
	    if type(info.target) == 'string' then
		local c = 'input /ma リフレシュIII <'..info.target..'>'
		-- command, delay, duration, period, eachfight
		local t = task.new_task(c, 1, 5, 120, false)
		task.set_task(level, t)
	    else
		-- io_chat.error("job/RDM: info.target", info.target)
	    end

	end
    end
end

function M.sub_tick(player)
    -- コンバートは自分の MP 回復なので、本職 RDM の有無に関係なく撃つ
    convert_tick(player)
    if role_Healer.sub_tick ~= nil then
	role_Healer.sub_tick(player)
    end
    if ac_party.count_member( { main_job="RDM" } ) >= 1 or
	ac_party.count_member() == 1 then -- ソロの時も無し
	return  -- 本職に任せる
    end
    if player.status == pstatus.ENGAGED then -- 戦闘中
	M.invoke_magick_debuff(player, 'ディアII', true, 5, 30)
	M.invoke_magick_debuff(player, 'ディストラ', true, 7, 32)
	M.invoke_magick_debuff(player, 'フラズル', true, 7, 38)
    else
	M.invoke_magick_debuff(player, 'ディアII', false, 5, 30)
	M.invoke_magick_debuff(player, 'ディストラ', false, 7, 32)
	M.invoke_magick_debuff(player, 'フラズル', false, 7, 38)
    end
end

M.attack_equip = {
    body = {
	23156, -- ＬＴサヨン+2 - 命54攻54魔命54魔攻49 被ダメ-13#
	23469, -- ＶＩタバード+3
    },
    left_ring = {
	26229,  -- レコリング
	26189,  -- 月明の指輪
	26182,  -- シーリチリング+1
	26212,  -- ムンムリング
    },
    right_ring = {
	15543,  -- ラジャスリング
	26173,  -- アペートリング
	26182,  -- シーリチリング+1
	26181,  -- シーリチリング
    },
}

return M
