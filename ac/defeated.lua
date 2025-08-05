-- 敵を倒した時の処理

local M = {}

local ac_stat = require('ac/stat')
local io_chat =  require('io/chat')
local ac_record =  require('ac/record')

-- 敵を倒した時に呼ばれる関数
function M.done()
    ac_stat.print()
    ac_record.record()
    local player = windower.ffxi.get_player()
    local jobpt = player.job_points[string.lower(player.main_job)]
    if jobpt.jp > 0 then
	local cp_jp_list = {5,25,55,95,145,205,275,355,445,545,655,775,905,1045,1195,1355}
	for i, p in ipairs(cp_jp_list) do
	    if jobpt.jp_spent < p and p <= jobpt.jp_spent+jobpt.jp then
		io_chat.setNextColor(3)
		io_chat.print("======= job point: "..p.." <= "..jobpt.jp_spent.."+"..jobpt.jp)
	    end
	end
    end
end

return M
