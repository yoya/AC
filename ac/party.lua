-- パーティ関連

local M = {}

function M.isMemberIndex(index)
    local party = windower.ffxi.get_party()
    for _, x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
	    -- 該当メンバーがいる。かつエリア内にいる
            if member ~= nil and member.mob ~= nil then
		if  member.mob.index == index then
                    return true
                end
            end
        end
    end
    return false
end

function M.hasJobMemberInParty(jobName)
    local stat = M.parent.stat
    print(stat)
    local party = windower.ffxi.get_party()
    for i = 0, 5 do -- 自分含めて全員
	local member = party["p"..i]
	-- 該当メンバーがいる。かつエリア内にいる
	if member ~= nil and member.mob ~= nil then
	    if  member.mob.main_job == jobName then -- 間違ってそう。要調査
		return true
	    end
	end
    end
    return false
end

return M
    
