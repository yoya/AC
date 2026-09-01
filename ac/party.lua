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
    -- ソロの時はリーダー扱い。ただし判定はキャッシュの後。party1_leader は
    -- ソロだと nil なので、p1 == nil を先に見ると、パーティ情報がまだ
    -- 届いていないだけのメンバーまでリーダーになり、role/Leader.tick_idle 側に
    -- 流れてしまう。実リーダーを一度でも見ていれば M.leader_id が残っているので、
    -- それも無い時だけを本当のソロとする。M.leader_mob() も同じ M.leader_id を
    -- 見るので、この順なら 2 つの答えが食い違わない
    if party1_leader == nil and party.p1 == nil then
	return true
    end
    if party1_leader == player.id then
        return true
    end
    return false
end

-- リーダーが IPC で配ってくる交戦相手。
--
-- 他 PC の target_index は、その PC がロックオンしていない限り自分の
-- クライアントに届かない。届かない間は 0 か、クライアントが最後に観測した
-- 古い値 (戦闘前に触っていた味方やフェイス) が残る。それを敵と見なすと
-- 味方を殴りに行くし、見送ると claim が付く (リーダーが実際に殴る) まで
-- 参戦できない。どちらも避けたいので、リーダー自身に教えてもらう。
M.leader_enemy_index = nil
M.leader_enemy_id = nil
local leader_enemy_at = 0

-- これより古い情報は使わない。リーダーが落ちた時に古い敵を掴み続けない為
local LEADER_ENEMY_FRESH_SEC = 10

-- io/ipc から呼ばれる。source は送り主の名前で、実リーダー以外は捨てる
function M.set_leader_enemy(source, index, id)
    local leader = M.leader_mob()
    if leader == nil or leader.name ~= source then
	return  -- 同じマシンの別窓。パーティのリーダーではない
    end
    M.leader_enemy_index = index
    M.leader_enemy_id = id
    leader_enemy_at = os.time()
end

-- リーダーの交戦相手の index, id。分からなければ nil
function M.get_leader_enemy()
    if M.leader_enemy_index == nil or M.leader_enemy_index == 0 or
	os.time() - leader_enemy_at > LEADER_ENEMY_FRESH_SEC then
	return nil
    end
    return M.leader_enemy_index, M.leader_enemy_id
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

-- 元は未定義の id と、注入されていない M.parent を参照していて呼ぶと落ちた。
-- やりたい事は count_member と同じなので、そちらに寄せる
function M.has_job_member_in_party(jobName)
    return M.count_member({ main_job = jobName }) > 0
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
	    -- cond に指定された項目を「全て」満たすものを数える。
	    -- or だと、指定していない項目が常に true を返すので
	    -- {main_job="PLD"} を渡しても全員が数えられてしまっていた
	    if M.prop_match_if_exist(info, cond, "main_job") and
		M.prop_match_if_exist(info, cond, "name") then
		count = count + 1
	    end
	end
    end
    return count
end

-- メンバーのバフ情報の鮮度。0x076 はバフが変わった時に届くので、これより
-- 古ければ「分からない」とする。古い情報で「歌が欠けている」と誤判定すると
-- 歌い過ぎる方に倒れるので、分からない側を選ぶ
local BUFF_FRESH_SEC = 60

-- メンバーにかかっている status_id のバフの数。分からなければ nil。
-- 0x076 は残り時間を持たないので、数えられるのは有無だけ
function M.member_buff_count(id, status_id)
    local info = M.member_table[id]
    if info == nil or info.buffs_at == nil or
	os.time() - info.buffs_at > BUFF_FRESH_SEC then
	return nil
    end
    local count = 0
    for _, buff_id in ipairs(info.buffs) do
	if buff_id == status_id then
	    count = count + 1
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
