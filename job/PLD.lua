-- ナイト

local M = {}

local command = require 'command'
local io_chat = require 'io/chat'
local role_Healer = require 'role/Healer'
local pstatus = require 'player_status'

M.main_job_prob_table = {
    { 200, 45, 'input /ma フラッシュ <t>', 1 },
    -- { 100, 60, 'input /ma ホーリーII <t>', 2 },
    { 100, 180, 'input /ma リアクト <me>', 4 },
    { 100, 300-10, 'input /ma クルセード <me>', 4 },
    { 40, 60, 'input /ma ケアルIII <me>', 3 },
    { 100, 180, 'input /ja ランパート <me>; wait 1; input /ja マジェスティ <me>; wait 1; input /ma ケアルIII <me>', 7 },
    { 100, 180-10, 'input /ma エンライト <me>', 3 },
    { 100, 600, 'input /ja フィールティ <me>', 0 },
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 300, 'input /ja パリセード <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

M.sub_job_prob_table = {
    { 200, 45, 'input /ma フラッシュ <t>', 1 },
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

function M.main_tick(player)
    if player.status == pstatus.ENGAGED then -- 戦闘中
	local hp = player.vitals.hp
	if hp < 300 then
	    io_chat.set_next_color(3)
	    io_chat.printf("HP: %d < 300 => インビンシブル", hp)
	    command.send("input /ja インビンシブル <me>")
	end
	if role_Healer.main_tick ~= nil then
	    role_Healer.main_tick(player)
	end
    end
end

M.attack_equip = {
    body = {
	25766, -- フロプトブレスト (命中+47 攻+53)
	25785, -- デーゴンブレスト
	25767, -- サクロブレスト (命+25 攻+60)
	23798, -- クレパスクラメイル (命+20 攻+55)
	25730, -- ンジンガキュイラス (攻+55)
	25717, -- バロラスメイル
    },
    left_ring = {
	26229, -- レコリング
	26189, -- 月明の指輪
	26190, -- 月光の指輪
	26211, -- フラマリング
	26182, -- シーリチリング+1
    },
    right_ring = {
	26173, -- アペートリング
	15543, -- ラジャスリング
	26211, -- フラマリング
	26182, -- シーリチリング+1
	26190, -- 月光の指輪
    }
}

return M
