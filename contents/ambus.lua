local M = {}

local command = require 'command'
local io_net = require 'io/net'
local io_chat = require 'io/chat'

local ac_party = require 'ac/party'
local iamLeader = ac_party.iamLeader

local keyboard = require 'keyboard'
local pushKeys = keyboard.pushKeys

-- これらの敵と戦っていて、それ以外の敵が現れた時は、
-- それ以外の方にターゲットを移す

local postponeEnemies = {
    ["Bozzetto Enceladus"] = true, -- 巨人族
    ["Dastardly Banneret"] = true, -- アルカナ類 イヴィルウェポン
    ["Bozzetto Necronura"] = true, -- ボロッゴ族(かえる)
    ["Possessed Heartwing"] = true, -- リフキン
    ["Master Manipulator"] = true, -- ソウルフレア
    ["Goes"] = true, -- プリン
}

local preferEnemyTable = {
    -- 巨人族
    "Bozzetto Marshal",      -- 戦士   (マイティストライク)
    "Bozzetto Swiftshooter", -- 狩人   (イーグルアイ)
    "Bozzetto Fistfighter",  -- モンク (百烈拳)
    "Bozzetto Trainer",      -- 獣使い (あやつる)
    -- アルカナ類 イヴィルウェポン
    "Iniquitous Axes",
    "Iniquitous Staves",
    "Iniquitous Blades",
    "Iniquitous Scythes",
    "Iniquitous Cudgels",
    "Iniquitous Spears",
    "Iniquitous Katana",
    "Bozzetto Golden Bomb",
    -- ボロッゴ族(かえる)
    "Bozzetto Croaker",
    -- ハートウィンド
    "Tenacious Umbril",  -- アンブリルははやく倒す
    "Shifty Umbril",
    "Brawny Umbril",
    "Resilient Umbril",
    "Tireless Umbril",
    -- "Alacritous Leafkin", -- リフキンは残した方が良い
    -- "Vital Leafkin",
    -- "Keen Leafkin",
    -- "Eldritch Leafkin",
    -- "Rejuvenating Leafkin",
    -- ソウルフレア
    "Bozzetto Imp",
    --
}

function searchPreferEnemy()
    local arr = {}
    for i, name in ipairs(preferEnemyTable) do
	local mob = windower.ffxi.get_mob_by_name(name)
	if mob ~= nil then
	    io_chat.print("searchPreferEnemy", mob.name, mob.status)
	    if  mob.status == 0 or mob.status == 1 then
		table.insert(arr, mob)
	    end
	end
    end
    return arr
end

function searchEnemy(range, excludeEmemy)
    print("searchEnemy", range, excludeEmemy)
    -- 何故かアンバスでは常に空っぽが返る
    -- local mobArr = windower.ffxi.get_mob_array()
    local mobArr = searchPreferEnemy()
    -- io_chat.print("searchEnemy: #mobArr", #mobArr)
    for i, mob in ipairs(mobArr) do
	io_chat.setNextColor(8) -- 明るい赤紫
	io_chat.print("searchEnemy name", excludeEmemy, mob.name)
	if (mob.status == 0 or mob.status == 1) and mob.spawn_type == 16 and
	    mob.distance < range then
	    if mob.name ~= excludeEmemy then
		return mob
	    end
	end
    end
end

function M.tick(player)
    if player.status == 1 then
	local mob = windower.ffxi.get_mob_by_target("t")
	if mob == nil then
	    return
	end
	--[[
	if iamLeader() == false then
	    local p1 = windower.ffxi.get_mob_by_target("p1")
	    if p1.target_index ~= mob.index then
		io_chat.setNextColor(8) -- 明るい赤紫
		io_chat.print("敵が違うので戦闘中断")
		command.send('input /attackoff <me>')
	    end
	    end
	]]
	if postponeEnemies[mob.name] == true then
	    print("postponeEnemies")
	    local nextMob = searchEnemy(30, mob.name)
	    if nextMob ~= nil then
		io_chat.setNextColor(8) -- 明るい赤紫
		io_chat.print("より優先度の高い敵を発見")
		command.send('input /attackoff <me>')
		io_net.targetByMob(nextMob)
		command.send('wait 1; input /attack <t>')
	    end
	end
	-- 敵から距離があると近づく処理。飛ばされた後用
	if 5 < mob.distance then
            pushKeys({"w", "w", "w"})
	end
    end
end

return M
