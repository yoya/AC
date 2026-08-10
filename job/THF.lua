-- シーフ

local M = {}

local role_Melee = require 'role/Melee'
local task = require 'task'
local pstatus = require 'player_status'

local sneak_attack_ws = 'エヴィサレーション'

M.main_job_prob_table = {
    { 10, 300, 'input /ja ぬすむ <t>', 0 },
    { 10, 300, 'input /ja かすめとる <t>', 0 },
    { 50, 180, 'input /ja フェイント <me>', 0 },
    { 50, 300, 'input /ja コンスピレーター <me>', 0 },
    { 10, 180, 'input /ja まどわす <t>', 0 },
    --{ 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja 不意打ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    -- { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja だまし討ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    { 50, 60, 'input /ja 不意打ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    { 50, 60, 'input /ja だまし討ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
}

M.sub_job_prob_table = {
    { 10, 300, 'input /ja ぬすむ <t>', 0 },
    -- { 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja 不意打ち <me>;', 0 },
    -- { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja だまし討ち <me>;', 0 },
    { 50, 60, 'input /ja 不意打ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    { 50, 60, 'input /ja 不意打ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    { 10, 300, 'input /ja かすめとる <t>', 0 },
}

function M.main_tick(player)
    if player.status == pstatus.ENGAGED then
	if 1 < player.vitals.hp and player.vitals.hp < 300 then
	    local c = "input /ja 絶対回避 <me>"
	    task.set_task_simple(c, 0, 2)
	end
    end
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

M.battle_equip = {
    main = {
	21575, -- ガンドリング
	21565, -- トーレット
    },
    sub = {
	21565, -- トーレット
	21585, -- クレパスクラナイフ
    },
    head = {
	23425, -- ＳＫボンネット+3
	23090, -- ＳＫボンネット+2
	25614, -- アデマボンネット+1
	23732, -- マリグナスシャポー
	24270, -- 無の面
	25642, -- ヘルクリアヘルム
    },
    body = {
	25786, -- アシェーラハーネス
	23733, -- マリグナスタバード
	25718, -- ヘルクリアベスト
	23768, -- ニャメメイル
    },
    legs = {
	25975, -- トゥルムレギンス+1
    },
    left_ring = {
	26229, -- レコリング
	10772, -- ペトロフリング
	26190, -- 月光の指輪
	26189, -- 月明の指輪
	26212, -- ムンムリング
	26182, -- シーリチリング+1
    },
    right_ring = {
	26186, -- イラブラットリング
	26173, -- アペートリング
	15543, -- ラジャスリング
	26212, -- ムンムリング
	26182, -- シーリチリング+1
	26181, -- シーリチリング
	28566, -- ングルベリング --  攻+10
    },
}

function M.incoming_text_handler(text)
    --if string.contains(text, "インビンシブル") ~= false then
    --end
end

return M
