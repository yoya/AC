-- 竜騎士

local M = {}

local actask = require 'task'
local ac_equip = require 'ac/equip'
local pstatus = require 'player_status'

M.main_job_prob_table = {
    { 10, 60*20, 'input /ja コールワイバーン <me>', 2 },
    { 10, 60*1, 'input /ja ジャンプ <t>', 2 },
    { 10, 60*1.5, 'input /ja スピリットリンク <me>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <t>', 2 },
    { 10, 60*3, 'input /ja スーパージャンプ <t>', 2 },
    { 10, 60*3, 'input /ja スピリットボンド <me>', 2 },
    { 10, 60*5, 'input /ja ディープブリージング <t>', 2 },
    { 10, 60, 'input /ja スピリットジャンプ <t>', 2 },
    { 10, 60*2, 'input /ja ソウルジャンプ <t>', 2 },
}

M.sub_job_prob_table = {
    { 10, 60*1, 'input /ja ジャンプ <t>', 2 },
    { 10, 60*2, 'input /ja ハイジャンプ <t>', 2 },
}

function M.main_tick(player)
    local c_angon = 'input /ja アンゴン <t>'
    if player.status == pstatus.ENGAGED then
	-- アンゴンを装備している時に使用する
	local item_id = ac_equip.equip_item_by_slot_name("ammo")
	if item_id == 18259 then  -- アンゴン
	    actask.set_task_simple(c_angon, 1, 60*3)
	end
    else
	actask.remove_task_simple(c_angon)
    end
end
M.attack_equip = {
    left_ring = {
	26229, -- レコリング
	26190, -- 月光の指輪
	26189, -- 月明の指輪
	26185, -- ニックマドゥリング
	26182, -- シーリチリング
	26211, -- フラマリング
    },
    head = {
	23797, -- クレパスクラヘルム 命中+20 攻撃+60
	25569, -- フラマツッケット+2
	25641, -- バロラスマスク
    },
    body = {
	25766, -- フロプトブレスト (命中+47 攻+53)
	25785, -- デーゴンブレスト (命中+45 攻+45)a
	25767, -- サクロブレスト (命+25 攻+60)
	23798, -- クレパスクラメイル (命+20 攻+55)
	25730, -- ンジンガキュイラス (攻+55)
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
    }
}

return M
