-- 風水士

local M = {}

local command = require 'command'
local role_Sorcerer = require 'role/Sorcerer'

local ac_pos = require 'ac/pos'
local io_chat = require 'io/chat'
local task = require 'task'

--- 通常の敵
--local GEO_inde = "インデフューリー"
local GEO_inde = "インデヘイスト"
local GEO_geo = "ジオフレイル"  -- 防御down
local GEO_inde2 = "インデヒューリー" -- 攻撃力up
local GEO_geo2 = "ジオトーパー" -- 回避down

--- 格上の敵
--local GEO_inde = "インデプレサイス" --- 命中up
--- 醴泉島かえる
--local GEO_inde = "インデリジェネ"
--local GEO_geo = "ジオバリア"  -- 防御down

--- アンバス用
--- local GEO_inde = "インデバリア" --- アンバス物防up
---local GEO_geo = "ジオアトゥーン" --- 魔回避down
---local GEO_inde = "インデフェンド" --- アンバス魔防up
--- カオス戦用
--- local GEO_inde = "インデフェンド" --- アンバス魔防up

M.mainJobProbTable = {
    { 100, 120, 'input /ma ケアル <p1>', 4 },
    { 100, 120, 'input /ma ヘイスト <p2>', 6 },
    --{ 50, 30, 'input /ma サンダー <t>', 3},
    --{ 50, 30, 'input /ma サンダーII <t>', 3},
    -- { 100, 30, 'input /ma サンダーIII <t>', 3},
    --{ 50, 30, 'input /ma ファイア <t>', 3},
    --{ 50, 30, 'input /ma  ファイアII <t>', 3},
    -- { 100, 30, 'input /ma ファイアIII <t>', 3},
    --{ 50, 30, 'input /ma ブリザド <t>', 3},
    --{ 50, 30, 'input /ma ブリザドII <t>', 3},
    -- { 100, 30, 'input /ma ブリザドIII <t>', 3},
}

M.mainJobProbTable_1 = {
    { 150, 300/3, 'input /ma '..GEO_geo..' <t>; wait 1; input /ja サークルエンリッチ <me>', 6 },
    -- { 250, 20, 'input /ma '..GEO_geo..' <t>', 6 },
    -- { 50, 600/2, 'input /ja グローリーブレイズ <me>; wait 1; input /ja フルサークル <me>; wait 1; input /ma '..GEO_geo..' <t>', 12  },
    { 150, 180/2, 'input /ma '..GEO_inde..' <me>', 4 },
    { 10, 600, 'input /ja エントラスト <me>; wait 2; input /ma インデデック <p2>', 6 },
    { 10, 300, 'input /ja メンドハレイション <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
    { 10, 300, 'input /ja レイディアルアルカナ <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
}

M.mainJobProbTable_2 = {
    { 150, 300/2, 'input /ma '..GEO_geo2..' <t>; wait 1; input /ja サークルエンリッチ <me>', 6 },
    { 250, 20, 'input /ma '..GEO_geo2..' <t>', 6 },
    -- { 50, 600/2, 'input /ja グローリーブレイズ <me>; wait 1; input /ja フルサークル <me>; wait 1; input /ma '..GEO_geo2..' <t>', 12  },
    { 150, 180, 'input /ma '..GEO_inde2..' <me>', 4 },
    { 10, 600, 'input /ja エントラスト <me>; wait 2; input /ma インデスト <p2>', 6 },
    { 10, 300, 'input /ja メンドハレイション <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
    { 10, 300, 'input /ja レイディアルアルカナ <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
}
 
M.subJobProbTable = { }

function geo_setup()
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ja グローリーブレイズ <me>; wait 2; input /ma '..GEO_geo..' <bt>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 2, 10, 5, false)
    -- 戦闘開始で硬直してる可能性があるので、3秒待つ
    local done = task.setTask(level, t)
    if done then
	io_chat.setNextColor(6)
	io_chat.print("ラバン設置します")
    end
end

function geo_release()
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ja フルサークル <me>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 1, 2, 0, false)
    local done = task.setTask(level, t)
    if done then
	io_chat.setNextColor(4) -- ピンク
	io_chat.print("ラバン消去します")
    end
end

function M.main_tick(player)
    local pet = windower.ffxi.get_mob_by_target("<pet>")
    if player.status == 1 then -- 戦闘中
	local mob = windower.ffxi.get_mob_by_target("<t>")
	local mobpetdist = ac_pos.distance(pet, mob)
	if mob ~= nil then
	    -- 羅盤がなくて戦闘中の敵がいる時は設置する
	    if pet == nil then
		geo_setup()
	    elseif mobpetdist > math.random(30, 40) then
		-- 羅盤が戦闘場所から離れてたら消す
		io_chat.setNextColor(4) -- ピンク
		local pd = math.floor(mobpetdist * 100 + 0.5) / 100;
		io_chat.print("ラバンの距離:"..pd)
		geo_release()
	    end
	end
	if player.vitals.mp >= 1000 then  -- MP に余裕があれば
	    if role_Sorcerer.main_tick ~= nil then
		role_Sorcerer.main_tick(player)
	    end
	end
    end
end

return M
