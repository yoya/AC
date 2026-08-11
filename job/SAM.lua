-- 侍

local M = {}

local role_Melee = require 'role/Melee'

M.main_job_prob_table = {
    { 100, 180, 'input /ja 黙想 <me>', 3 },
    { 200, 60, 'input /ja 八双 <me>', 3 }, -- 攻撃
    -- { 100, 60, 'input /ja 星眼 <me>', 3 }, -- 防御
    { 100, 180, 'input /ja 先義後利 <me>', 3 },
    { 100, 180, 'input /ja 渾然一体 <t>', 3 },
    { 100, 180, 'input /ja 石火之機 <me>', 3 },
}

M.sub_job_prob_table = {
    { 60, 180, 'input /ja 黙想 <me>', 3 },
    { 200, 60, 'input /ja 八双 <me>', 3 }, -- 攻撃
    -- { 60, 60, 'input /ja 星眼 <me>', 1 }, -- 防御
    { 100, 180, 'input /ja 石火之機 <me>', 1 },
}

function M.main_tick(player)
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

M.attack_equip = {
    main = {
	21952, -- 真斬魔刀
	21980, -- 真斬魔刀
    },
    head = {
	25552, -- 乾闥婆陣鉢改
    },
    body = {
	23798, -- クレパスクラメイル
    },
    hands = {
	25979, -- 乾闥婆手甲改
    },
    legs = {
	25892, -- 乾闥婆筒袴改
    },
    feet = {
	25959, -- 乾闥婆脛当改
    },
    left_ring = {
	26229,  -- レコリング
	26189,  -- 月明の指輪
	26182,  -- シーリチリング+1
	26211,  -- フラマリング
    },
    right_ring = {
	26211,  -- フラマリング
	26173,  -- アペートリング
	15543,  -- ラジャスリング
	26182,  -- シーリチリング+1
	26181,  -- シーリチリング
    },
    back = {
	26257, -- スメルトリオマント
    },
}

return M
