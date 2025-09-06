-- パーティ関連

local M = {}

local res = require('resources')
local io_chat = require 'io/chat'

local jobs = res.jobs

M.leader_id = nil

M.member_table = { }

function M.iamLeader()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    local party1_leader = party.party1_leader
    -- print("ac_party.iamLeader", party.party1_leader, player.id)
    if party1_leader == nil then
	party1_leader = M.leader_id
    else
	M.leader_id = party1_leader
    end
    if party1_leader == player.id then
        return true
    end
    return false
end

function M.isMemberId(id)
    local party = windower.ffxi.get_party()
    for _, x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
	    -- 該当メンバーがいる。かつエリア内にいる
            if member ~= nil and member.mob ~= nil then
		if  member.mob.id == id then
                    return true
                end
            end
        end
    end
    return false
end

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

function createMemberInfo()
    return { buffs = {} }
end

function  object_assign(obj1, obj2)
    for k, v in pairs(obj2) do
	obj1[k] = v
    end
end

-- incoming/chunk から呼ばれる
function M.updatePartyMemberInfo(id, info)
    if M.member_table[id] == nil then
	M.member_table[id] = createMemberInfo()
    end
    if info.main_job ~= nil then
	info.main_job = jobs[info.main_job].ens
    end
    if info.sub_job ~= nil then
	info.sub_job = jobs[info.sub_job].ens
    end
    object_assign(M.member_table[id], info)
end

function M.showPartyMembers()
    io_chat.setNextColor(5)
    io_chat.print("=== showPartyMembers")
    for id, info in pairs(M.member_table) do
	io_chat.setNextColor(6)
	io_chat.print(id, info.name, info.main_job, info.sub_job)
	io_chat.print(info)
    end
end

return M
