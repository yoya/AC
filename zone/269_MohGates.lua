-- モーの門

local M = { id = 269 }

M.routes = {
    common1 = {
	{x=300,y=-359,z=50},
    },
    common2 = {
	{x=100.5,y=-479.5,z=50},
    }
}

M.essentialPoints = {
    from_yahse1 = {x=300,y=-359,z=50},
    from_yahse2 = {x=100.5,y=-479.5,z=50},
}

M.automatic_routes = {
    -- from_yahse1 = { route="common1" },  -- 危なく無い場所まで
    -- from_yahse2 = { route="common2" },  -- 危なく無い場所まで
}

return M
