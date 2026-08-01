local M = {}

local io_chat = require 'io/chat'
local pstatus = require 'player_status'

function M.mob_check(player, me, mob_name, range)
    if range.x1 < me.x and me.x < range.x2 and
	range.y1 < me.y and me.y < range.y2 and
	range.z1 < me.z and me.z < range.z2 then
	local mob_arr = windower.ffxi.get_mob_array()
	for i, m in pairs(mob_arr) do
	    if m.name == mob_name then
		if m.status == pstatus.IDLE then
		    io_chat.notice(mob_name, "ポップ中")
		    local dx = m.x - me.x
		    local dy = m.y - me.y
		    if 3*3 < (dx * dy + dy * dy)  then
			windower.ffxi.run(dx, dy)
		    else
			windower.ffxi.run(false)
		    end
		elseif m.status == pstatus.ENGAGED then
		    io_chat.info(mob_name, "戦闘中")
		end
	    end
	end
    end
end


function M.sisyphus_check(player, me)
    -- (x=-169,y=286,z=-176)  (x=-297,y=319,z=-176)
    -- (x=-157,y=406,z=-184)  (x=-216,y=398,z=-185)
    -- 中心 (x=-210,y=-352,z=-180),
    -- 実際のよさそうな場所。(x=-221,y=318,z=-175)
    local range = { x1=-297, x2=-157, y1=-406, y2=-296, z1=-185, z2= -176 }
    return M.mob_check(player, me, "Sisyphus", range)
end

function M.jacu_check(player, me)
    -- I-8
    --右上 {x=394,y=242,z=-31.9},
    -- {x=271,y=85,z=-51.2}, {x=239,y=190,z=-47.7},
    local range = { x1=239,x2=394, y1=85,y2=242, z1=-52,z2=-31}  -- I-8
    M.mob_check(player, me, "Jaculus", range)
end

function M.tick(player)
    local me = windower.ffxi.get_mob_by_target("me")
    if me == nil then return end
    M.sisyphus_check(player, me)
    M.jacu_check(player, me)
end

return M
