-- バストゥーク商業区

local M = { id = 235 }

M.routes = {
    -- HP#4 から
    brygid = {
	{x=-190,y=-68,z=-6}, {x=-186,y=-73}, {x=-175,y=-77},
	{x=-119,y=-95}, {x=-93,y=-97}, {x=-89,y=-104},
	{x=-89.6,y=-106.7}, {a="f8touch"}
    }
}

M.essentialPoints = {
    from_bas = {x=20.5,y=3.6,z=0},
}

M.automatic_routes = {
}

return M
