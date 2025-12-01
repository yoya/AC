-- カザム

local M = { id = 250 }

M.routes = {
    war = {  -- Jakoh Wahcondalo (族長)
	{x=76.7,y=-94.5,z=-13}, {x=76,y=-101}, {x=77,y=-112},
	{x=81,y=-113}, {a="opendoor"}, {x=85,y=-113},
	{x=98.4,y=-114.4,z=-15}, {a="f8touch"}
    }
}

M.essentialPoints = {
    hp_1 = {x=76.7,y=-94.5,z=-13},
}

M.automatic_routes = {
}

return M
