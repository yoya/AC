local M = {}

function M.sisyphus_check(player)
    local me = windower.ffxi.get_mob_by_target("me")
    if -297 < me.x and me.x < -157 and
	-406 < me.y and me.y < -296 and
	-185 < me.z and me.z < -176 then
	-- (x=-169,y=286,z=-176)  (x=-297,y=319,z=-176)
	-- (x=-157,y=406,z=-184)  (x=-216,y=398,z=-185)
	-- 中心 (x=-210,y=-352,z=-180),
	-- 実際のよさそうな場所。(x=-221,y=318,z=-175)
	local mobArr = windower.ffxi.get_mob_array()
	for i, m in pairs(mobArr) do
	    if m.name == "Sisyphus" then
		if m.status == 0 then
		    io_chat.info("Sisyphus ポップ中")
		    local dx = m.x - me.x
		    local dy = m.y - me.y
		    if 3*3 < (dx * dy + dy * dy)  then
			windower.ffxi.run(dx, dy)
		    else
			windower.ffxi.run(false)
		    end
		elseif m.status == 1 then
		    io_chat.info("Sisyphus 戦闘中")
		end
	    end
	end
    end
end

function M.tick(player)
    local zone = windower.ffxi.get_info().zone
    M.sisyphus_check(player, zone)
end

return M
