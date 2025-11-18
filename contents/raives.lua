local M = {}

M.preferredEnemyList = {
    -- コロナイズ・レイヴ 
    "Knotted Root", "Bedrock Crag", "Broadleaf Palm", "Monolithic Boulder",
    "Gnarled Rampart", "Icy Palisade",
    "Amaranth Barrier", "Heliotrope Barrier",
    -- レイア・レイヴ
    "Wasp Nest", "Grimy Boulders", "Sere Stump", "Banespore",
    "Avian Roost", "Arboreal Bastion", "Wintry Cave", "Dimensional Tether",
}

-- 発生中か否か。該当の敵が近くにいるかで判断
function M.arise()
    for i, name in ipairs(M.preferredEnemyList) do
	local mob = windower.ffxi.get_mob_by_name(name)
	if mob ~= nil and mob.distance < 1000 then
	    print("raives arised: " .. mob.name .. " found")
	    return true
	end
    end
    return false
end

return M
