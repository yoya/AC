-- status

local M = {
    -- これらが揃うまで tick は動かさない
    player = nil,
    party = nil,
    leader = nil,
    me = nil,
    time = nil,
    datetime = nil,
    -- 以下のは状況次第
    target = nil,
    pet = nil,
}

-- tick の度に実行する
function M.update()
    M.player = windower.ffxi.get_player()
    M.party = windower.ffxi.get_party()
    if M.player ~= nil and M.party ~= nil then
	M.leader = M.party.party1_leader == M.player.id
    end
    M.me = windower.ffxi.get_mob_by_target("me")
    M.target = windower.ffxi.get_mob_by_target("t")
    M.pet = windower.ffxi.get_mob_by_target("pet")
    M.time = os.time()
    M.datetime = os.date("%X", M.time)
end

function M.valid()
    if M.player == nil or M.party == nil or M.leader then
	return false
    end
    if M.me == nil then
	return false
    end
    if M.time == nil or M.datetime == nil then
	return false
    end
    return true
end

function M.show()
    
end

return M
