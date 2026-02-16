-- キャラクター情報

local M = {
    charTable = {},
}

local res = require('resources')
local ac_data = require('ac/data')

local io_chat = require('io/chat')
local jobs = res.jobs

function M.init(id, char)
    M.charTable = {}
    --[[ user_id => eminence_point
	         => login_point
                 => unity_point
	         => main_job
                 => job => exp_point ...
    ]]
end

function M.update_points(id, char)
    local point_keys = {
	"eminence_point", "login_point", "unity_point",
	"hallmark", "total_hallmark",  "gallantry",
	"domain_point", "mog_segments", "gallimaufry"
    }
    for i, key in ipairs(point_keys) do
	if char[key] ~= nil then
	    M.charTable[id][key] = char[key]
	end
    end
end

function M.update_job_info(id, main_job, sub_job, char)
    local limit_breaker = char.limit_breaker
    local current_merit_point = char.current_merit_point
    local max_merit_point = char.max_merit_point
    local current_exp_point = char.current_exp_point
    local next_exp_point = char.next_exp_point
    local synched_master_level = char.synched_master_level
    local master_breaker = char.master_breaker
    local current_exemplar_point = char.current_exemplar_point
    local next_exemplar_point = char.next_exemplar_point
    -- io_chat.print(id, main_job, char)
    --
    M.charTable[id].main_job = main_job
    M.charTable[id].sub_job = sub_job
    --
    if main_job_id ~= nil and main_job_id > 0 then
	M.charTable[id].main_job = main_job
    end
    if sub_job_id ~= nil and sub_job_id > 0 then
	M.charTable[id].sub_job = sub_job
    end
    --
    local limit_breaker = char.limit_breaker
    local current_merit_point = char.current_merit_point
    local max_merit_point = char.max_merit_point
    if limit_breaker ~= nil and limit_breaker == true then
	M.charTable[id][main_job].current_merit_point = current_merit_point
	M.charTable[id][main_job].max_merit_point = max_merit_point
    end
    -- master level
    if current_exp_point ~= nil then
	M.charTable[id][main_job].current_exp_point = current_exp_point
    end
    if next_exp_point ~= nil then
	M.charTable[id][main_job].next_exp_point = next_exp_point
    end
    if synched_master_level ~= nil then
	M.charTable[id][main_job].synched_master_level = synched_master_level
    end
    if master_breaker ~= nil and master_breaker == true then
	if current_exemplar_point ~= nil then
	    M.charTable[id][main_job].current_exemplar_point = current_exemplar_point
	end
	if next_exemplar_point ~= nil then
	    M.charTable[id][main_job].next_exemplar_point = next_exemplar_point
	    for m, p in pairs(ac_data.next_exemplar_table) do
		if next_exemplar_point == p then
		    M.charTable[id][main_job].real_master_level = m
		    break
		end
	    end
	end
    end
end

function M.update(id, char)
    if M.charTable[id] == nil then
	M.charTable[id] = {
	    eminence_point = -1,
	    login_point = -1,
	    unity_point = -1,
	    hallmark = -1,
	    total_hallmark = -1,
	    gallantry = -1,
	    domain_point = -1,
	    mog_segments = -1,
	    gallimaufry = -1,
	}
    end
    local player = windower.ffxi.get_player()
    local main_job = nil
    local sub_job = nil
    if player.id == id then
	main_job = player.main_job
	sub_job = player.sub_job
    end
    local main_job_id = char.main_job_id
    local sub_job_id = char.sub_job_id
    if main_job_id ~= nil then
	main_job = jobs[main_job_id].ens
    end
    if sub_job_id ~= nil then
	sub_job = jobs[sub_job_id].ens
    end
    if main_job == nil or main_job == 0 then
	return  -- フェイスとか
    end
    M.update_points(id, char)
    if M.charTable[id][main_job] == nil then
	M.charTable[id][main_job] = {
	    current_merit_point = -1,
	    max_merit_point = -1,
	    current_exp_point = -1,
	    next_exp_point = -1,
	    real_master_level = -1,
	    current_exemplar_point = -1,
	    next_exemplar_point = -1,
	}
    end
    M.update_job_info(id, main_job, sub_job, char)
end

-- char point

function get_char_point(key)
    local player = windower.ffxi.get_player()
    if M.charTable[player.id] == nil then
	return -1
    end
    return M.charTable[player.id][key]
end


function M.eminence_point()
    return get_char_point("eminence_point")
end

function M.login_point()
    return get_char_point("login_point")
end

function M.unity_point()
    return get_char_point("unity_point")
end

function M.hallmark()
    return get_char_point("hallmark")
end

function M.total_hallmark()
    return get_char_point("total_hallmark")
end

function M.gallantry()
    return get_char_point("gallantry")
end

function M.domain_point()
    return get_char_point("domain_point")
end

function M.mog_segments()
    return get_char_point("mog_segments")
end

function M.gallimaufry()
    return get_char_point("gallimaufry")
end

-- char job info

function get_char_point_by_job(key)
    local player = windower.ffxi.get_player()
    if M.charTable[player.id] == nil then
	return -1
    end
    if M.charTable[player.id][player.main_job] == nil then
	return -1
    end
    return M.charTable[player.id][player.main_job][key]
end

function M.current_merit_point()
    return get_char_point_by_job("current_merit_point")
end

function M.max_merit_point()
    return get_char_point_by_job("max_merit_point")
end

function M.current_exp_point()
    return get_char_point_by_job("current_exp_point")
end

function M.next_exp_point()
    return get_char_point_by_job("next_exp_point")
end

function M.real_master_level()
    return get_char_point_by_job("real_master_level")
end

function M.synched_master_level()
    return get_char_point_by_job("synched_master_level")
end

function M.current_exemplar_point()
    return get_char_point_by_job("current_exemplar_point")
end

function M.next_exemplar_point()
    return get_char_point_by_job("next_exemplar_point")
end

function M.print()
    io_chat.setNextColor(5)
    io_chat.print("### ac/char print #"..#M.charTable)
    for id, char in pairs(M.charTable) do
	local mob = windower.ffxi.get_mob_by_id(id)
	io_chat.setNextColor(6)
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
