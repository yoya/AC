-- ファイル保存するデータ

local io_chat = require("io/chat")
local utils_table = require "utils/table"

local M = {
    eminence_point = -1,
    unity_point = -1,
}

function M.record()
    local player = windower.ffxi.get_player()
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
    f:write("name: "..player.name)
    f:write("  "..player.main_job..":"..player.main_job_level)
    if player.main_job_level >= 99 then
	f:write(" Ilv:"..player.item_level)
	local jobpt = player.job_points[string.lower(player.main_job)]
	f:write(" JP:"..jobpt.jp_spent.."+"..jobpt.jp)
    end
    f:write("\n")
    f:write("eminence: "..M.eminence_point.."  unity: "..M.unity_point.."\n")
    --[[
    local jpText = ""
    for job, points in pairs(player.job_points) do
	if points.jp > 0 then
	    jpText = jpText .. job .. ": ".. utils_table.tableToString(points).."\n"
	end
    end
    :write("job_points: "..jpText)
    ]]
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

return M
