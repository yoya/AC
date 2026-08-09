-- 吟遊詩人

local M = {}

local control = require 'control'
local contents = require 'contents'
local task = require 'task'
local role_Melee = require 'role/Melee'
local pstatus = require 'player_status'

local piani_prefix = "input /ja ピアニッシモ <me>; wait 2; "

M.main_job_prob_table = {
    -- { 100, 60, 'input /ma 魔法のフィナーレ <t>', 8, true },
    -- { 200, 120, 'input /ma 修羅のエレジー <t>', 8, true },
    --    { 1000, 120, piani_prefix..'input /ma 魔物のレクイエムVII <t>', 8, true },
    { 1000, 120, 'input /ma 魔物のレクイエムVII <t>', 8, true },
    -- { 200, 120, 'input /ma 光のスレノディII <t>', 8, true },
}

M.sub_job_prob_table = {
    { 300, 180/2, 'input /ma 無敵の進撃マーチ <me>', 8 },
    { 200, 180/2, 'input /ma 猛者のメヌエットIII <me>', 8 },
    -- { 200, 120, 'input /ma 戦場のエレジー <t>', 8, true },
}

function song(song_name, onoff, period, delay, target)
    local c = "input /song "..song_name.." <"..target..">"
    local level = task.PRIORITY_MIDDLE
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, delay, 10, period, true)
    if onoff then
	task.set_task(level, t)
    else
	task.remove_task(level, t)
    end
end

function song_tick(player)
    local onoff = player.status > 0
    local me = windower.ffxi.get_mob_by_target("me")
    if M.parent.need_safety() then
	song("重装騎兵のミンネV", onoff, 15*60 / 3, 2, "me")
	song("闘龍士のマンボ", onoff, 15*60 / 2, 12, "me")
	-- song("活力のエチュード", onoff, 15*60 / 3, 12*2, "me")
	song("戦士達のピーアンVI", onoff, 15*60 / 3, 12*3, "me")
	song("栄光の凱旋マーチ", onoff, 15*60 / 3, 12, "me")
    elseif false then  -- 魔法強化
	-- song("無敵の進撃マーチ", onoff, 15*60 / 3, 12, "me")
	song("栄光の凱旋マーチ", onoff, 15*60 / 3, 12*2, "me")
	song("魔道士のバラードII", onoff, 15*60 / 2, 12*3, "me")
	song("魔道士のバラードIII", onoff, 15*60 / 2, 12*3, "me")
	song("英知のエチュード", onoff, 15*60 / 3, 12*4, "me")
	song("知恵のエチュード", onoff, 15*60 / 2, 12*4, "me")
    else
	-- TODO auto かつ街中以外で以下を実行。status 1 で弱体系実行
	-- song("無敵の進撃マーチ",   onoff, 15*60 / 2, 12*1, "me")
	song("栄光の凱旋マーチ",   onoff, 15*60 / 3, 12*1, "me")
	song("猛者のメヌエットV",  onoff, 15*60 / 3, 12*2, "me")
	song("猛者のメヌエットIV", onoff, 15*60 / 2, 12*3, "me")
	song("猛者のメヌエットIII", onoff, 15*60 , 12*4, "me")
	-- song("剣豪のマドリガル",   onoff, 15*60 / 4, 12*5, "me")
	song("怪力のエチュード",   onoff, 15*60 / 3, 12*5, "me")
	song("妙技のエチュード",   onoff, 15*60 / 2, 12*6, "me")
    end
    local condition = {
        linked_only = true,
	range = control.enemy_range,
    }
    local lullaby = false
    if contents.match_contents_name("sortie") and player.status == pstatus.ENGAGED then
--    local linkedMobs = acmob.search_mobs(me, condition)
	--  io_chat.print(linkedMobs)
	lullaby = true
    end
    song("魔物達のララバイ", lullaby, 24, 0, "t")
    song("魔物達のララバイII", lullaby, 24, 20, "t")
end

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
    song_tick(player)
end

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local ja_list = { "クラリオンコール", "ナイチンゲール", "ソウルボイス"}
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	task.set_task(level, task.new_task(c, (i-1)*2, 2, 10, false))
    end
    windower.ffxi.run(false)
    level = task.PRIORITY_HIGH
    local song_list = { "栄光の凱旋マーチ", "猛者のメヌエットV",
		       "怪力のエチュード", "妙技のエチュード",
		       "剣豪のマドリガル", "猛者のメヌエットV",
		       "栄光の凱旋マーチ" }
    for i, song_name in ipairs(song_list) do
	local c = "input /song "..song_name.." <me>"
	-- command, delay, duration, period, eachfight
	local task_obj = task.new_task(c, 6+(i-1)*2, 5, 180/2, false)
	task.set_task(level, task_obj)
    end

end

M.battle_equip = {
    main = {
	21565, -- トーレット
    },
    sub = {
	21565, -- トーレット
	21585, -- クレパスクラナイフ
    },
    body = {
	25786, -- アシェーラハーネス
    },
    left_ring = {
        26229,  -- レコリング
        26190,  -- 月光の指輪
	26189,  -- 月明の指輪
        26182,  -- シーリチリング+1
        26212,  -- ムンムリング
    },
    right_ring = {
        26173,  -- アペートリング
        15543,  -- ラジャスリング
        26182,  -- シーリチリング+1
	26189,  -- 月明の指輪
        26181,  -- シーリチリング
    },
}

return M
