-- 赤魔導士

local task = require 'task'
local role_Healer = require 'role/Healer'
local role_Sorcerer = require 'role/Sorcerer'
local io_chat = require 'io/chat'

local M = {}

M.mainJobProbTable = {
    { 500, 300*2, 'input /ja コンポージャー <me>', 2 },
    -- { 100, 30, 'input /ma ディスペル <t>', 3 },
    { 500, 180, 'input /ma ディアIII <t>', 3, true },
    { 500, 300, 'input /ma ディストラII <t>', 4, true },
    { 500, 120, 'input /ma フラズルII <t>', 4, true },
    { 100, 180*3, 'input /ma ストライII <me>', 4 },
    { 100, 300*3, 'input /ma ゲインデック <me>', 4 },
    { 100, 150*3, 'input /ma リフレシュIII <me>', 4 },
    { 100, 150, 'input /ma リフレシュIII <p2>', 4 },
    { 100, 150, 'input /ma リフレシュIII <p3>', 4 },
    { 100, 180, 'input /ma エンサンダーII <me>', 4 },
    -- { 100, 180, 'input /ma エンストーンII <me>', 4 },
    { 100, 180*3, 'input /ma ヘイストII <me>', 3 },
    { 100, 180, 'input /ma ヘイストII <p1>', 3 },
    { 100, 180, 'input /ma ヘイストII <p2>', 3 },
    { 100, 180, 'input /ma ヘイストII <p3>', 3 },
    { 5, 600, 'input /ma アクアベール <me>', 5},
    { 5, 300, 'input /ma ブリンク <me>', 5},
    { 5, 300, 'input /ma ストンスキン <me>', 5},
    { 600/2, 1000, 'input /ja コンバート <me>', 1 },
}

M.subJobProbTable = {
    -- { 5, 600-60, 'input /ma アクアベール <me>', 5},
    { 100, 300, 'input /ma ブリンク <me>', 5},
    { 100, 300, 'input /ma ストンスキン <me>', 5},
    { 500, 300-10, 'input /ma リフレシュ <me>', 5},
    { 500, 300-10, 'input /ma リフレシュ <p2>', 5},
    -- { 500, 120, 'input /ma ディアII <t>', 4, true },
    -- { 500, 120, 'input /ma ディストラ <t>', 5, true },
    -- { 500, 120, 'input /ma フラズル <t>', 5, true },
    { 600/3, 1000, 'input /ja コンバート <me>', 1 },
    { 500, 120-10, 'input /ma ヘイスト <p1>', 4 },
    { 500, 120-10, 'input /ma ヘイスト <p2>', 4 },
    -- { 100, 120-30, 'input /ma ヘイスト <p3>', 4 },
}

function invoke_magick_debuff(player, magic, need_mp)
    if player.vitals.mp < need_mp then
	return
    end
    local c = 'input /ma '..magic..' <t>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 2, 4, 90, true)
    task.setTask(task.PRIORITY_LOW, t)
end

function M.main_tick(player)
    if role_Healer.main_tick ~= nil then
	role_Healer.main_tick(player)
    end
    if role_Sorcerer.main_tick ~= nil then
	role_Sorcerer.main_tick(player)
    end
end

function M.sub_tick(player)
    if role_Healer.sub_tick ~= nil then
	role_Healer.sub_tick(player)
    end
    if player.status == 1 then -- 戦闘中
	invoke_magick_debuff(player, 'ディアII', 30)
	invoke_magick_debuff(player, 'ディストラ', 32)
	invoke_magick_debuff(player, 'フラズル', 38)
    end
end

return M
