---
--- Utility
--- 雑多な関数群。整理できてない

packets = require 'packets'
command = require 'command'

local M = {}

function M.iamLeader()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    if party.party1_leader == player.id then
        return true
    end
    return false
end

function isMobAttackableTargetIndex(index)
    if index == 0 then -- 占有されてない
        return true
    end
    local party = windower.ffxi.get_party()
    for x in pairs({"p", "a1", "a2"}) do -- アライアンス全員
        for i = 0, 5 do -- 自分含めて全員
            local member = party[x..i]
            if member.mob ~= nil then
                if index == member.mob.target_index then
                    return true
                end
            end
        end
    end
    return false
end

--- 多分、戦える敵 (レイド戦には未対応)+
function isMobAttackable(mob)
    if (mob.status == 0 or mob.status == 1) and
        mob.spawn_type == 16 and
        isMobAttackableTargetIndex(mob.target_index) then
        return true
    end
end

M.isMobAttackable = isMobAttackable

function M.pushKeys(keys)
    local command = ""
    for i, k in ipairs(keys) do
        command = command.."setkey "..k.." down; wait 0.1; setkey "..k.." up; wait 0.1; "
    end
    command.send(command)
end


function M.get_keys(t)
    local keys={}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

function M.array_reverse(arr)
    rev = {}
    for i=#arr, 1, -1 do
        rev[#rev+1] = arr[i]
    end
    return rev
end

function M.merge_lists(t1, t2)
    local merged = {}
    for _, v in ipairs(t1) do
        table.insert(merged, v)
    end
    for _, v in ipairs(t2) do
        table.insert(merged, v)
    end
    return merged
end

function M.merge_tables(t1, t2)
    local merged = {}
    for k, v in pairs(t1) do
        merged[k] = v
    end
    for k, v in pairs(t2) do
        merged[k] = v
    end
    return merged
end

function isNumericalIndexedTable(table)
    local isNumeric = true
    if isNumeric == nil then
        return false
    end
    for k, v in pairs(table) do
        if type(k) ~= "number" then
            isNumeric = false
        end
    end
    return isNumeric
end

function boolToStringIfBool(b)
    if type(b) == 'boolean' then
        b = b and "true" or "false"
    end
    return b
end

function utf8ToSJISIfString(s)
    if type(s) == 'string' then
	return windower.to_shift_jis(s)
    end
    return s
end
    

function roundIfNumber(n)
    if type(n) == 'number' then
        n = math.round(n, 2)
    end
    return n
end

function _printChat(text, depth, maxDepth)
    if text == nil then
        text = "(nil)"
    end
    if type(text) ~= "table" then
---        print(text, depth)
        indent = string.rep('- ', depth)
        text = boolToStringIfBool(text)
	text = utf8ToSJISIfString(text)
	text = roundIfNumber(text)
        windower.add_to_chat(17, indent .. text)
--        windower.add_to_chat(0, indent .. text)
        return
    elseif isNumericalIndexedTable(text) then
        mesg = ""
        if #text >= 10 then
                mesg = mesg .. "(count:"..#text.."): "
        end
        for k, v in pairs(text) do
            v = boolToStringIfBool(v)
	    v = utf8ToSJISIfString(v)
	    v = roundIfNumber(v)
            if type(v) == "table" then
                _printChat(v, depth+1, maxDepth+1)
            else
                mesg = mesg .. " " ..v
            end
        end
        _printChat(mesg, depth+1, maxDepth+1)
    else
        for k, v in pairs(text) do
            if type(v) ~= "table" then
                v = boolToStringIfBool(v)
		v = utf8ToSJISIfString(v)
                v = roundIfNumber(v)
                _printChat(k..": "..v, depth, maxDepth+1)
            else
                _printChat(k..": ", depth, maxDepth+1)
                if depth <= maxDepth then
                    _printChat(v, depth+1, maxDepth+1)
                else
                    _printChat("(count:"..#v..")", depth+1, maxDepth)
                end
            end
        end
    end
end


function printChat(text)
    _printChat(text, 1, 1)
end
M.printChat = printChat

local ignoreMobs = S{
    "fep2",
    "Resolute Leafkin", -- ミッション「門」
}
M.getNearestFightableMob = function(pos, dist, preferMobs)
--    print("M.getNearestFightableMob", preferMobs);
--    M.printChat("getNearestFifhtableMob")
-- 距離(デフォルト20)以内だけ対象
    local mob = nil
    local mobArr = windower.ffxi.get_mob_array()
    for i, m in pairs(mobArr) do
        --- リンクすると status が 1になるので対象にする
--        print("preferMobs: " ..  m.name, "  c:", preferMobs:contains(m.name))
        if ( preferMobs == nil or preferMobs:contains(m.name)) and
            isMobAttackable(m) then
            local dx = m.x - pos.x
            local dy = m.y - pos.y
            local dz = m.z - pos.z
            d = math.sqrt(dx*dx + dy*dy)
            --- 高さが８違うのは無視。
            if m.x ~= 0 and m.y ~= 0 and m.z ~= 0 and d < dist and math.abs(dz) < 1 then
--             if m.name == "Water Elemental" then
--                    printChat(i .. ": name:" .. m.name ..", dist:".. m.distance .. ", status:".. m.status ..", d:".. d)
--                printChat(m)
--             end
                if ignoreMobs:contains(m.name) == false then
--                if m.name ~= "fep2" then 
                    mob = m
                    dist = d
                end
            end
        end
    end
---    print("mob", mob.name)
    return mob
end

M.targetByMobId = function(mobId)
---    print("tagetByMobId", mobId)
    local player = windower.ffxi.get_player()
    packets.inject(packets.new('incoming', 0x58, {
        ['Player'] = player.id,
        ['Target'] = mobId,
        ['Index'] = player.index
    }))
end

M.targetByMobIndex= function(mobIndex)
---    print("tagetByMobId", mobId)
    if mobIndex == 0 then
        print("targetByMobIndex mobIndex: "..mobIndex)
        return
    end
    local player = windower.ffxi.get_player()
    local mob = windower.ffxi.get_mob_by_index(mobIndex)
    if mob == nil then
        return
    end
    packets.inject(packets.new('incoming', 0x58, {
        ['Player'] = player.id,
        ['Target'] = mob.id,
        ['Index'] = player.index
    }))
end

-- パーティで戦闘中のモンスターがいれば、それを返す
M.PartyTargetMob = function()
--    printChat("PartyTargetMob")
    local party = windower.ffxi.get_party()
    for i = 1, 5 do -- 自分以外
        local member = party["p"..i]
        if member.mob ~= nil and member.mob.status == 1 then
            local index = member.mob.target_index
            if index > 0 then
                local mob = windower.ffxi.get_mob_by_index(index)
                if isMobAttackable(mob) then
                    return mob
                end
            end
        end
    end
    return nil
end


local turnToFront = function(target)
    local push_numpad5 = 'setkey numpad5 down; wait 0.1; setkey numpad5 up'
    command.send(push_numpad5..'; wait 0.5; '..push_numpad5)
end
M.turnToFront = turnToFront

local turnToPos = function(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    --- atan2 のままだと右を向くので、90度の補正
    local dir = math.atan2(dx, dy) - 3.14/2
    windower.ffxi.turn(dir)
end
M.turnToPos = turnToPos

M.turnToTarget = function(target)
---    print("turnToTarget:"..target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
---        print("turnToTarget: target:"..#target.." not found")
        return false
    end
    local me = windower.ffxi.get_mob_by_target("me")
    turnToPos(me.x, me.y, mob.x, mob.y)
end

M.distance = function(target)
    local mob = windower.ffxi.get_mob_by_target(target)
    if mob == nil then
        print("distance: target:"..#target.." not found")
        return false
    end
    return mob.distance;
end

M.rankInJob = function()
    printChat("rankInJob")
    local party = windower.ffxi.get_party()
    for i = 0, 5 do
        local member = party["p"..i]
        if i == 1 then
            printChat(member)
        end
    end
end

M.cureIfPartyHPisLow = function()
    local player = windower.ffxi.get_player()
    local mainJob = player.main_job
    local subJob = player.sub_job
    if mainJob ~= "WHM" and mainJob ~= "SCH" and
       mainJob ~= "RDM" then
        mainJob = nil
    end
    if subJob ~= "WHM" and subJob ~= "SCH" and
        subJob ~= "RDM" then
        subJob = nil
    end
    if mainJob == nil and subJob == nil then
        return
    end
--    print("cureIfPartyHPisLow:"..mainJob)
    local player_mp = player.vitals.mp
    if player_mp < 8 then
        print("few player mp:"..player_mp)
        return
    end
    local party = windower.ffxi.get_party()
    for i=0,5 do
        local t = "p"..i
        local member = party[t]
        if member ~= nil and  member.mob ~= nil then
            local hpp = member.hpp
            local hp = member.hp
            local hp_need_cure = 75
            if mainJob == "RDM" or mainJob == nil then
                hp_need_cure = 65
            end
            if mainJob == "BLM" then
                hp_need_cure = 50
            end
            if hp > 0 and hpp < hp_need_cure
                and hp < 1800 then
--              print(t.." HP: "..hp.." ("..hpp.."%)")
                local c = 'input /ma ケアル <'..t..'>'
                if hp < 300 and mainJob == "WHM" then
                    c = 'input /ja 女神の祝福 <me>'
                elseif hp < 500 and player_mp >= 88 then
                   c = 'input /ma ケアルIV <'..t..'>'
                elseif hp < 1000  and player_mp >= 46 then
                    c = 'input /ma ケアルIII <'..t..'>'
                elseif hp < 1500  and player_mp >= 24 then
                    c = 'input /ma ケアルII <'..t..'>'
                end
                windower.ffxi.run(false)
                command.send(c)
                coroutine.sleep(2)
            end
        end
    end
end

return M
