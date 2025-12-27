-- 風水士

local M = {}

local command = require 'command'
local role_Sorcerer = require 'role/Sorcerer'

local aczone = require 'zone'
local ac_pos = require 'ac/pos'
local io_chat = require 'io/chat'
local task = require 'task'

M.mainJobProbTable = {
    { 10, 120, 'input /ma ケアル <p1>', 4, true },
    { 10, 120, 'input /ma ヘイスト <p2>', 6 },
    { 10,5*60/2, 'input /ja コリメイトファーバー <me>', 6 },
}

function isDefensive()
    return M.parent.needSafety()
end

function inde_setup(jobRank)
    local GEO_inde = "インデヘイスト"
    local GEO_entrust = "インデデック"
    if jobRank == 2 then
	local GEO_inde = "インデフューリー"
	local GEO_entrust = "インデスト"
    end
    if isDefensive() then
	GEO_inde = "インデバリア"  -- 防御up
	if jobRank == 2 then
	    GEO_inde = "インデアトゥーン"  -- 魔回避up
	end
    end
    -- TODO: MB パーティ対応
    --   GEO_inde = "インデフォーカス" -- 魔命 up
    --   GEO_inde = "インデアキュメン" -- 魔攻 up
    -- TODO: 格上の敵対応
    --   GEO_inde = "インデプレサイス" -- 命中up
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ma '..GEO_inde..' <me>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 2, 7, 180/2, false)
    -- 戦闘開始で硬直してる可能性があるので、3秒待つ
    local done = task.setTask(level, t)
    if done then
	-- io_chat.setNextColor(6)
	-- io_chat.print("インデ展開")
    end
    -- エントラスト TODO:実行可能な時に狙って処理する
    c = 'input /ja エントラスト <me>; wait 2; input /ma '..GEO_entrust..' <p2>'
    -- command, delay, duration, period, eachfight
    t = task.newTask(c, 2, 7, 600, false)
    local done = task.setTask(level, t)
    if done then
	-- io_chat.setNextColor(6)
	-- io_chat.print("エントラストインデ展開")
    end
end

function geo_setup(jobRank)
    -- print("geo_setup jobRank:"..jobRank)
    local GEO_geo = "ジオフレイル"  -- 敵の防御down
    if jobRank == 2 then
	GEO_geo = "ジオトーパー" -- 敵の回避率down
    end
    if isDefensive() then
	GEO_geo = "ジオウィルト"  -- 敵の攻撃力down
	if jobRank == 2 then
	    GEO_geo = "ジオフェイド" -- 敵の魔法攻撃力down
	end
    end
    -- TODO: MB パーティ対応
    --   GEO_geo = "ジオマレーズ" -- 魔防down
    --   GEO_geo = "ジオアトゥーン" -- 魔回避down
    -- TODO: 格上の敵対応
    --   GEO_geo = "ジオトーパー" -- 敵の回避率down
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ja グローリーブレイズ <me>; wait 2; input /ma '..GEO_geo..' <bt>; wait 2; input /ja サークルエンリッチ <me>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 2, 10, 5, false)
    -- 戦闘開始で硬直してる可能性があるので、3秒待つ
    local done = task.setTask(level, t)
    if done then
	-- io_chat.setNextColor(6)
	-- io_chat.print("ラバン設置します")
    end
end

function geo_release(name)
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ja '..name..' <me>'
    -- command, delay, duration, period, eachfight
    local t = task.newTask(c, 1, 2, 0, false)
    local done = task.setTask(level, t)
    if done then
	-- io_chat.setNextColor(4) -- ピンク
	-- io_chat.print("ラバン消去します")
    end
end

-- 状況に応じて羅盤解除
function geo_release_with_contexte(player, pet, mob)
    local mobpetdist = ac_pos.distance(pet, mob)
    if mobpetdist >= 6 then
	-- 羅盤が戦闘場所から離れてたら消す
	-- io_chat.setNextColor(4) -- ピンク
	-- local pd = math.floor(mobpetdist * 100 + 0.5) / 100;
	-- io_chat.print("羅盤と敵の距離="..pd)
	geo_release("フルサークル")
    elseif player.vitals.mp < 100 then  -- TODO: パーティのMPを考慮
	geo_release("レイディアルアルカナ")
    elseif player.vitals.hp < 300 then  -- TODO: パーティのHPを考慮
	geo_release("メンドハレイション")
    end
end

function M.main_tick(player)
    local jobRank = 1  -- あとで party 情報を元に設定
    if player.status == 1 then -- 戦闘中
	inde_setup(jobRank)
	local pet = windower.ffxi.get_mob_by_target("pet")
	if pet == nil then  -- 羅盤が無い場合
	    geo_setup(jobRank)
	else -- 羅盤がある場合
	    local mob = windower.ffxi.get_mob_by_target("t")
	    if mob ~= nil then
		-- 状況に応じて羅盤解除
		geo_release_with_contexte(player, pet, mob)
	    end
	end
	if player.vitals.mp >= 1000 then  -- MP に余裕があれば
	    if role_Sorcerer.main_tick ~= nil then
		role_Sorcerer.main_tick(player)
	    end
	end
    end
end

function M.dothebest_main(player)
    local level = task.PRIORITY_HIGH
    local jaList = { "ボルスター", "フルサークル" }
    for i, ja_name in ipairs(jaList) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local t = task.newTask(c, (i-1)*2, 2, 10, false)
	task.setTask(level, t)
    end
    windower.ffxi.run(false)
    geo_setup(1)
    inde_setup(1)
end


return M
