-- キャラクター情報

local res = require('resources')

local M = {
    charTable = {},
    real_master_level = -1,
    current_exemplar_point = -1,
    next_exemplar_point = -1,
}

local io_chat = require('io/chat')
local jobs = res.jobs

function M.init(id, char)
    M.charTable = {}
    M.real_master_level = -1
    M.current_exemplar_point = -1
    M.next_exemplar_point = -1
end

function M.update(id, char)
    if M.charTable[id] == nil then
	M.charTable[id] = {}
    end
    local main_job_id = char.main_job_id
    local sub_job_id = char.sub_job_id
    local master_level = char.master_level
    local master_breaker = char.master_breaker
    if main_job_id ~= nil and main_job_id > 0 then
	M.charTable[id].main_job = jobs[main_job_id].ens
    end
    if sub_job_id ~= nil and sub_job_id > 0 then
	M.charTable[id].sub_job = jobs[sub_job_id].ens
    end
    local master_level = char.master_level
    if master_breaker ~= nil and master_breaker == true and
	master_level ~= nil then
	M.charTable[id].master_level = master_level
    end
end

-- https://wiki.ffo.jp/html/38412.html
local next_exemplar_table = {
    [0] = 2500, [1] = 5550, [2] = 8721, [3] = 11919, [4] = 15122,
    [5] = 18327, [6] = 21532, [7] = 24737, [8] = 27942, [9] = 31147,
    [10] = 41205, [11] = 48130, [12] = 53677, [13] = 58614, [14] = 63292,
    [15] = 67848, [16] = 72353, [17] = 76835, [18] = 81307, [19] = 85775,
    [20] = 109112, [21] = 127014, [22] = 141329, [23] = 153277, [24] = 163663,
    [25] = 173018, [26] = 181692, [27] = 189917, [28] = 197845, [29] = 205578,
    [30] = 258409, [31] = 307400, [32] = 353012, [33] = 395651, [34] = 435673,
    [35] = 473392, [36] = 509085, [37] = 542995, [38] = 575336, [39] = 606296,
    [40] = 769426, [41] = 951369, [42] = 1154006, [43] = 1379407,
    [44] = 1629848, [45] = 1907833, [46] = 2216116, [47] = 2557728,
    [48] = 2936001, [49] = 3354601, [50] = 3817561
}

function M.current_exemplar(pt)
    M.current_exemplar_point = pt
end

function M.next_exemplar(pt)
    M.next_exemplar_point = pt
    for m, p in pairs(next_exemplar_table) do
	if pt == p then
	    M.real_master_level = m
	    break
	end
    end
end

function M.print()
    for id, char in pairs(M.charTable) do
	local mob = windower.ffxi.get_mob_by_id(id)
	io_chat.print(id, mob.name, char)
    end
end

return M

--[[ -- 不要かも
local master_level_exemplar_point_table = {
    [0] = 0, [1] = 2500, [2] = 8050, [3] = 16771, [4] = 28690, [5] = 43812,
    [6] = 62139, [7] = 83671, [8] = 108408, [9] = 136350, [10] = 167497,
    [11] = 208702, [12] = 256832, [13] = 310509, [14] = 369123, [15] = 432415,
    [16] = 500263, [17] = 572616, [18] = 649451, [19] = 730758, [20] = 816533,
    [21] = 925645, [22] = 1052659, [23] = 1193988, [24] = 1347265,
    [25] = 1510928, [26] = 1683946, [27] = 1865638, [28] = 2055555,
    [29] = 2253400, [30] = 2458978, [31] = 2717387, [32] = 3024787,
    [33] = 3377799, [34] = 3773450, [35] = 4209123, [36] = 4682515,
    [37] = 5191600, [38] = 5734595, [39] = 6309931, [40] = 6916227,
    [41] = 7685653, [42] = 8637022, [43] = 9791028, [44] = 11170435,
    [45] = 12800283, [46] = 14708116, [47] = 16924232, [48] = 19481960,
    [49] = 22417961, [50] = 25772562, -- [51] = 29590123
}
]]
