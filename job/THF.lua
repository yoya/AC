-- シーフ

local M = {}

local role_Melee = require 'role/Melee'
local command = require 'command'
local task = require 'task'

local sneak_attack_ws = 'エヴィサレーション'

M.mainJobProbTable = {
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

M.subJobProbTable = {
    { 10, 300, 'input /ja ぬすむ <t>', 0 },
    -- { 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja 不意打ち <me>;', 0 },
    -- { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja だまし討ち <me>;', 0 },
    { 50, 60, 'input /ja 不意打ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    { 50, 60, 'input /ja 不意打ち <me>; wait 1; input /ws '..sneak_attack_ws..' <t>', 0 },
    { 10, 300, 'input /ja かすめとる <t>', 0 },
}

function M.main_tick(player)
    if player.status == 1 then
	if 1 < player.vitals.hp and player.vitals.hp < 300 then
	    local c = "input /ja 絶対回避 <me>"
	    task.setTaskSimple(c, 0, 2)
	end
    end
    if role_Melee.main_tick ~= nil then
	role_Melee.main_tick(player)
    end
end

M.battle_equip = {
    left_ring = {
	26229,  -- レコリング
	10772,  -- ペトロフリング
	26190,  -- 月光の指輪
	26189,  -- 月明の指輪
	26182,  -- シーリチリング+1
	26212,  -- ムンムリング
    },
    right_ring = {
	26186,  -- イラブラットリング
	26212,  -- ムンムリング
	26173,  -- アペートリング
	15543,  -- ラジャスリング
	26182,  -- シーリチリング+1
	26181,  -- シーリチリング
    },
}

return M
