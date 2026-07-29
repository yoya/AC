-- 風水士

local M = {}

local command = require 'command'
local role_Sorcerer = require 'role/Sorcerer'

local aczone = require 'zone'
local ac_pos = require 'ac/pos'
local io_chat = require 'io/chat'
local task = require 'task'
local pstatus = require 'player_status'

M.main_job_prob_table = {
    { 10, 120, 'input /ma ケアル <p1>', 4, true },
    { 10, 120, 'input /ma ヘイスト <p2>', 6 },
    { 10,5*60/2, 'input /ja コリメイトファーバー <me>', 6 },
}

function inde_setup(job_rank)
    local GEO_inde = "インデヘイスト"
    local GEO_entrust = "インデデック"
    if job_rank == 2 then
	GEO_inde = "インデフューリー"
	GEO_entrust = "インデスト"
    end
    if M.parent.need_safety() then
	GEO_inde = "インデバリア"  -- 防御up
	if job_rank == 2 then
	    GEO_inde = "インデアトゥーン"  -- 魔回避up
	end
    end
    -- TODO: MB パーティ対応
    --   GEO_inde = "インデフォーカス" -- 魔命 up
    --   GEO_inde = "インデアキュメン" -- 魔攻 up
    -- TODO: 格上の敵対応
    --   GEO_inde = "インデプレサイス" -- 命中up
    local level = task.PRIORITY_LOW
    local c = 'input /ma '..GEO_inde..' <me>'
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 2, 7, 180/2, false)
    -- 戦闘開始で硬直してる可能性があるので、3秒待つ
    local done = task.set_task(level, t)
    if done then
	-- io_chat.set_next_color(6)
	-- io_chat.print("インデ展開")
    end
    -- エントラスト TODO:実行可能な時に狙って処理する
    c = 'input /ja エントラスト <me>; wait 2; input /ma '..GEO_entrust..' <p2>'
    -- command, delay, duration, period, eachfight
    t = task.new_task(c, 2, 7, 600, false)
    local done = task.set_task(level, t)
    if done then
	-- io_chat.set_next_color(6)
	-- io_chat.print("エントラストインデ展開")
    end
end

function geo_setup(job_rank)
    -- print("geo_setup job_rank:"..job_rank)
    local GEO_geo = "ジオフレイル"  -- 敵の防御down
    if job_rank == 2 then
	GEO_geo = "ジオトーパー" -- 敵の回避率down
    end
    if M.parent.need_safety() then
	GEO_geo = "ジオウィルト"  -- 敵の攻撃力down
	if job_rank == 2 then
	    GEO_geo = "ジオフェイド" -- 敵の魔法攻撃力down
	end
    end
    -- TODO: MB パーティ対応
    --   GEO_geo = "ジオマレーズ" -- 魔防down
    --   GEO_geo = "ジオアトゥーン" -- 魔回避down
    -- TODO: 格上の敵対応
    --   GEO_geo = "ジオトーパー" -- 敵の回避率down
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ja グローリーブレイズ <me>; wait 2; input /ma '..GEO_geo..' <t>; wait 2; input /ja サークルエンリッチ <me>'
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 2, 10, 5, false)
    -- 戦闘開始で硬直してる可能性があるので、3秒待つ
    local done = task.set_task(level, t)
    if done then
	-- io_chat.set_next_color(6)
	-- io_chat.print("ラバン設置します")
    end
end

function geo_release(name)
    local level = task.PRIORITY_MIDDLE
    local c = 'input /ja '..name..' <me>'
    -- command, delay, duration, period, eachfight
    local t = task.new_task(c, 1, 2, 0, false)
    local done = task.set_task(level, t)
    if done then
	-- io_chat.set_next_color(4) -- ピンク
	-- io_chat.print("ラバン消去します")
    end
end

-- 状況に応じて羅盤解除
function geo_release_with_contexte(player, pet, mob)
    local mobpetdist = ac_pos.distance(pet, mob)
    if mobpetdist >= 6 then
	-- 羅盤が戦闘場所から離れてたら消す
	-- io_chat.set_next_color(4) -- ピンク
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
    local job_rank = 1  -- あとで party 情報を元に設定
    local pet = windower.ffxi.get_mob_by_target("pet")
    local mob = windower.ffxi.get_mob_by_target("t")
    if player.status == pstatus.IDLE then -- 待機中
	if pet ~= nil and mob ~= nil then
	    -- 遠く離れたラバンは解除する
	    local mobpetdist = ac_pos.distance(pet, mob)
	    if mobpetdist >= 32 then
		geo_release("フルサークル")
	    end
	end
    elseif player.status == pstatus.ENGAGED then -- 戦闘中
	inde_setup(job_rank)
	if pet == nil then  -- 羅盤が無い場合
	    geo_setup(job_rank)
	else -- 羅盤がある場合
	    if pet ~= nil and mob ~= nil then
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
    local ja_list = { "ボルスター", "フルサークル" }
    local ti = 1
    for i, ja_name in ipairs(ja_list) do
	local c = "input /ja "..ja_name.." <me>"
	-- command, delay, duration, period, eachfight
	local ta = task.new_task(c, ti, 2, 10, false)
	task.set_task(level, ta)
	ti = ti + 2
    end
    windower.ffxi.run(false)
    geo_setup(1) -- 後で見直す
    geo_setup(2) -- 1 の recast 対策で 2 を実行
    inde_setup(2)
    inde_setup(1)
end

M.battle_equip = {
    body = {
	23507, -- ＡＺコート+3
	23172, -- ＡＺコート+2
	25787, -- シャマシュローブ
	26969, -- ヴリコダラ  -- FC+5 ケアル回復+
	25719, -- マーリンジュバ
	26939, -- ＡＺコート+1
	26894, -- テルキネシャジュブ
    },
    left_ring = {
	26184, -- スティキニリング+1
	26225, -- メダダリング
    },
    right_ring = {
	26225, -- メダダリング
	26208, -- ジャリリング
	26183, -- スティキニリング
	27553, -- レソネンス
    },
}

return M
