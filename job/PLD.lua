-- ナイト

local M = {}

local command = require 'command'
local io_chat = require 'io/chat'
local role_Healer = require 'role/Healer'

M.mainJobProbTable = {
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

M.subJobProbTable = {
    { 200, 45, 'input /ma フラッシュ <t>', 1 },
    { 100, 300, 'input /ja センチネル <me>', 0 },
    { 100, 180, 'input /ja かばう <p1>', 0 },
}

function M.main_tick(player)
    if player.status == 1 then -- 戦闘中
	local hp = player.vitals.hp
	if hp < 300 then
	    io_chat.setNextColor(3)
	    io_chat.printf("HP: %d < 300 => インビンシブル", hp)
	    command.send("input /ja インビンシブル <me>")
	end
	if role_Healer.main_tick ~= nil then
	    role_Healer.main_tick(player)
	end
    end
end

return M
