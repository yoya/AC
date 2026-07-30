-- パーティ関連

local M = {}

local res = require('resources')
local io_chat = require 'io/chat'

local jobs = res.jobs

M.leader_id = nil

M.member_table = { }

function M.iam_leader()
    local player = windower.ffxi.get_player()
    if player == nil then
	print("ac/party.iam_leader player == nul")
	return nil
    end
    local party = windower.ffxi.get_party()
    local party1_leader = party.party1_leader
    -- print("ac_party.iam_leader", party.party1_leader, player.id)
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

-- パーティリーダーの mob を返す。フォローすべき相手はスロット "p1" とは
-- 限らない (p0 は必ず自分で、p1 は自分以外の先頭にすぎない)。実リーダーは
-- party1_leader の id で引く。M.leader_id は iam_leader がキャッシュする。
function M.leader_mob()
    local party = windower.ffxi.get_party()
    if party.party1_leader ~= nil then
	M.leader_id = party.party1_leader
    end
    if M.leader_id == nil then
	return nil
    end
    return windower.ffxi.get_mob_by_id(M.leader_id)
end

function M.is_member_id(id)
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

function M.is_member_index(index)
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

function M.has_job_member_in_party(jobName)
    local stat = M.parent.stat
    local party = windower.ffxi.get_party()
    for i = 0, 5 do -- 自分含めて全員
	local target = "p"..i
	local member = party[target]
	local info = M.member_table[id]
	-- 該当メンバーがいる。かつエリア内にいる
	if info ~= nil and info.index > 0 and
	    info.main_job == jobName then -- 間違ってそう。要調査
	    info.target = target
	    print("ac/party.has_job_member_in_party", info.main_job, jobName)
	    return true
	end
    end
    return false
end

function M.has_tank_job_member_in_party()
    if M.count_member( { main_job="PLD" } ) +
	M.count_member( { main_job="RUN" } ) +
	M.count_member( { main_job="WAR" } ) >= 1 then
	return true
    end
    return false
end


function create_member_info()
    return { buffs = {} }
end

local function object_assign(obj1, obj2)
    for k, v in pairs(obj2) do
	obj1[k] = v
    end
end

-- incoming/chunk から呼ばれる
function M.update_party_member_info(id, info)
    if M.member_table[id] == nil then
	M.member_table[id] = create_member_info()
    end
    if info.main_job ~= nil then
	info.main_job = jobs[info.main_job].ens
    end
    if info.sub_job ~= nil then
	info.sub_job = jobs[info.sub_job].ens
    end
    object_assign(M.member_table[id], info)
end

-- conf { main_job, name }

function M.prop_match_if_exist(info, cond, propname)
    if cond == nil or cond[propname] == nil then
	return true
    end
    if info[propname] == cond[propname] then
	return true
    end
    return false
end

function M.count_member(cond)
    local count = 0
    for id, info in pairs(M.member_table) do
	if info.index > 0 then
	    if M.prop_match_if_exist(info, cond, "main_job") or
		M.prop_match_if_exist(info, cond, "name") then
		count = count + 1
	    end
	end
    end
    return count
end

function M.show_party_members()
    io_chat.set_next_color(5)
    io_chat.print("=== show_party_members")
    for id, info in pairs(M.member_table) do
	if info.index > 0 then
	    io_chat.set_next_color(6)
	    io_chat.print(id, info.name, info.main_job, info.sub_job)
	    io_chat.print(info)
	end
    end
end

return M
