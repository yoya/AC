-- ファイル保存するデータ

local res = require 'resources'

local io_chat = require("io/chat")
local ac_char = require("ac/char")
local utils = require "utils"

function M.record_char()
    print("ac/record:record_char")
    local player = windower.ffxi.get_player()
    if player == nil then
	print("record.record: player == nil")
	return
    end
    -- addon_path の最後に / がついてる。
    local record_path = windower.addon_path .. "saved"
    if windower.dir_exists(record_path) == false then
	print("record_path not found: "..record_path)
	return
    end
    local filename = record_path .. "/"..(player.name)..".txt"
    -- print(filename, M.eminence_point)
    local f = io.open(filename, "w")
    if f == nil then
	print("io.open failed")
	return
    end
    f:write(player.name)
    local namelen = string.len(player.name)
    if namelen < 7 then
	f:write(string.rep(" ", 7 - namelen))
    end
    if player.status > 1 and player.status ~= 33 then
	-- 33: healing??
	f:write("(status:"..player.status..")")
    end
    f:write(" "..player.main_job..":"..player.main_job_level)
    if player.main_job_level < 99 then
	f:write("("..ac_char.current_exp_point().."/"..ac_char.next_exp_point()..")")
    end
    local jobpt = player.job_points[string.lower(player.main_job)]
    -- マスターレベルなら、きっとメリットポイント気にしないので非表示
    if player.main_job_level >= 75 and jobpt.jp_spent < 2100 then
	f:write(" (merit:"..ac_char.current_merit_point().."/"..ac_char.max_merit_point()..")")
    end
    if player.main_job_level >= 99 then
	f:write(" Ilv:"..player.item_level)
	if jobpt.jp_spent < 2100 then
	    -- ジョブポイント表示
	    f:write(" JP:"..jobpt.jp_spent.."+"..jobpt.jp.."="..(jobpt.jp_spent+jobpt.jp))
	    -- 次にキャパポupする jobポイントの閾値を表示する
	    local cp_jp_list = {5,25,55,95,145,205,275,355,445,545,655,775,905,1045,1195,1355,2100}
	    local prev_jp = 0
	    local next_jp = 5
	    for i, p in ipairs(cp_jp_list) do
		if prev_jp <= jobpt.jp_spent and jobpt.jp_spent < p then
		    next_jp = p
		    break
		end
		prev_jp = p
	    end
	    f:write("(next:"..next_jp..")")
	elseif jobpt.jp_spent >= 2100 and ac_char.real_master_level() >= 0 then
	    f:write(" Mlv:"..ac_char.real_master_level())
	    local exemplar_percent = math.floor(100 * ac_char.current_exemplar_point()/ac_char.next_exemplar_point() + 0.5)
	    f:write("("..ac_char.current_exemplar_point().."/"..ac_char.next_exemplar_point().."="..exemplar_percent.."%)")
	end
    end
    f:write("\n")
    local items = windower.ffxi.get_items()
    f:write("Eminence:"..ac_char.eminence_point().."  Unity:"..ac_char.unity_point().."  Gil:"..utils.string.gil_string(items.gil).."\n")
    f:close()
end

function M.eminence(pt)
    M.eminence_point = pt
    M.record()
end

function M.unity(pt)
    M.unity_point = pt
    M.record()
end

function M.record_spells()
    print("ac/record:record_spells")
    local spells = windower.ffxi.get_spells()
    local white_spells = {}
    local black_spells = {}
    local summon_spells = {}
    local ninjutsu_spells = {}
    local blue_spells = {}
    local geo_spells = {}
    local trust_spells = {}
    local misc_spells = {}
    local all_spells = {
	white = white_spells,
	black = black_spells,
	blue = blue_spells,
	summon = summon_spells,
	ninjutsu = ninjutsu_spells,
	geo = geo_spells,
	trust = trust_spells,
	misc = misc_spells,
    }
    for i, v in ipairs(spells) do
	if v == true then
	    local name = res.spells[i].name
	    -- io_chat.print(i, name)
	    if 1 <= i and i <= 143 then
		white_spells[i] = name
	    elseif 144 <= i and i <= 276 then
		black_spells[i] = name
	    elseif 278 <= i and i <= 285 then -- 計略(1)
		black_spells[i] = name
	    elseif 286 <= i and i <= 287 then -- アドル
		white_spells[i] = name
	    elseif 289 <= i and i <= 307 then -- 召喚
		summon_spells[i] = name
	    elseif 308 <= i and i <= 317 then -- 策+エン系
		white_spells[i] = name
	    elseif 318 <= i and i <= 354 then -- 忍術
		ninjutsu_spells[i] = name
	    elseif i == 365 then -- ブレクガ
		black_spells[i] = name
	    elseif i == 367 then -- デス
		black_spells[i] = name
	    elseif 473 <= i and i <= 495 then -- ケアルラ, アディ
		white_spells[i] = name
	    elseif 496 <= i and i <= 502 then -- ジャ系
		black_spells[i] = name
	    elseif i == 504 then -- リジェネV
		white_spells[i] = name
	    elseif 505 <= i and i <= 510 then -- 忍術
		ninjutsu_spells[i] = name
	    elseif i == 511 then -- ヘイストII
		white_spells[i] = name
	    elseif 513 <= i and i <= 751 then -- 青魔法
		blue_spells[i] = name
	    elseif 768 <= i and i <= 827 then --  風水魔法
		geo_spells[i] = name
	    elseif 828 <= i and i <= 839 then -- ファイラ〜ウォタラII
		black_spells[i] = name
	    elseif i == 840 then -- フォイル
		white_spells[i] = name
	    elseif 841 <= i and i <= 844 then -- ディストラ〜フラズルII
		black_spells[i] = name
	    elseif i == 845 then -- スナップ
		white_spells[i] = name
	    elseif i == 847 then -- アトモス召喚
		summon_spells[i] = name
	    elseif i == 848 then -- リレイズIV
		white_spells[i] = name
	    elseif 849 <= i and i <= 854 then -- ファイアVI
		black_spells[i] = name
	    elseif 857 <= i and i <= 864 then -- 陣II
		white_spells[i] = name
	    elseif 865 <= i and i <= 870 then -- ファイラIII〜
		black_spells[i] = name
	    elseif i == 881 then -- アスピルIII
		black_spells[i] = name
	    elseif 885 <= i and i <= 892 then -- 計
		black_spells[i] = name
	    elseif i == 893 then -- フルケア
		white_spells[i] = name
	    elseif 896 <= i and i <= 1019 then -- フェイス
		trust_spells[i] = name
	    else
		misc_spells[i] = name
	    end
	end
    end
        local player = windower.ffxi.get_player()
    if player == nil then
	print("record.record: player == nil")
	return
    end
    -- addon_path の最後に / がついてる。
    local record_path = windower.addon_path .. "saved"
    if windower.dir_exists(record_path) == false then
	print("record_path not found: "..record_path)
	return
    end
    local filename = record_path .. "/"..(player.name).."-spells.json"
    -- print(filename, M.eminence_point)
    local f = io.open(filename, "w")
    if f == nil then
	print("io.open failed")
	return
    end
    -- f:write(player.name)
    f:write("{\n")
    local first1 = true
    for k, v in pairs(all_spells) do
	if first1 == false then
	    f:write(",\n")
	end
	f:write("  \""..k.."\": {\n")
	local first = true
	for i, _ in ipairs(spells) do
	    s = v[i]
	    if s ~= nil then
		if first == false then
		    f:write(",\n")
		end
		f:write("    \""..i.."\":\""..s.."\"")
		first = false
	    end
	end
	f:write("\n  }")
	first1 = false
    end
    f:write("}\n")
    f:close()
end

return M
