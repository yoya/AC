-- ラ・ロフの劇場

local M = { id = 180 }

M.routes = {
    circle1 = {
	{x=-605.8,y=436.1,z=-23.8}, {x=-605.1,y=480.5,z=-22.7},
	{a="f8touch"}
    },
    circle2 = {
	{x=-236.5,y=413.4,z=-138.4}, {x=-262.3,y=377.9,z=-137.3},
	{a="f8touch"}
    },
    circle3 = {
	{x=60.1,y=473.4,z=-225.5}, {x=18.4,y=486.8,z=-224.3},
	{a="f8touch"}
    },
    circle4 = { -- EV
	{x=189.8,y=346.5,z=-174.7}, {x=230.9,y=359.7,z=-173.6},
	{a="f8touch"}
    },
    circle5 = { -- GK
	{x=527.3,y=559.2,z=-39.3}, {x=553.3,y=524.3,z=-38.2},
	{a="f8touch"}
    },
    bc = {
	{wait=5}, {a="up"}, {a="enter"},
	{x=8.1,y=-108.4,z=-33.3}, {x=23,y=-82}, {x=21,y=-77},
	{x=15,y=-70}, {x=12,y=-64}, {x=19,y=-49}, {x=19,y=-45},
	{x=5.6,y=-20.1,z=-25.4}
    },
}

M.essentialPoints = {
    entrance1 = {x=-605.8,y=436.1,z=-23.8},
    entrance2 = {x=-236.5,y=413.4,z=-138.4},
    entrance3 = {x=60.1,y=473.4,y=-225.5},
    entrance4 = {x=189.8,y=346.5,z=-174.7},
    entrance5 = {x=527.3,y=559.2,z=-39.3},
    bc_in = {x=8.1,y=-108.4,z=-33.3},
    bc_out4 = {x=323.4,y=-443.8,z=-108.4},
}

M.automatic_routes = {
    entrance1 = { route="circle1" },
    entrance2 = { route="circle2" },
    entrance3 = { route="circle3" },
    entrance4 = { route="circle4" },
    entrance5 = { route="circle5" },
    bc_in = { route="bc" },
}

return M
