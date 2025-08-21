local M = {}

function M.tick(player)
    local mob = windower.ffxi.get_mob_by_target("t")
    if iamLeader() == false then
        local p1 = windower.ffxi.get_mob_by_target("p1")
        if p1.target_index ~= mob.index then
	    command.send('input /attackoff <me>')
	end
    end
end

return M
