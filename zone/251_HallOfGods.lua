-- 神々の間

local M = { id = 251 }

M.routes = {
    -- 入り口
    grate = { -- Cermet Grate
	{x=-1.1,y=-176.1,z=-0.1,desc="Cermet Grate"}, {x=1, y=-66},
	{x=2,y=-17}, {x=4,y=-9}, {x=4,y=9}, {x=2,y=17},
	{x=0,y=47,z=-12.3}
    },
    -- from_grate
    circle = {
	{x=0,y=51.9,z=-12.3,desc="空への転送装置"},
	{x=0,y=70,z=-12.3}, {x=0, y=103,z=-20.3}, {x=0,y=144,z=-20.7},
	{target="Shimmering Circle"}, {a="enter"}
    },
    -- from_circle
    sky = {
	{x=0.1,y=250.7,z=0.1}, {x=0,y=282}, {x=0.5,y=362,z=0}, {}
    }
}

M.essentialPoints = {
    -- x={-1-1,1.5},
    entrance = {x=-0,y=-176.1,z=-0.1,dx=2},
    from_grate = {x=0,y=51.9,z=-12.3},
    from_circle = {x=0.1, y=250.7,z=0.1},
}

M.automatic_routes = {
    entrance = { route="grate" },
    from_grate = { route="circle" },
    from_circle = { route="sky" },
}

return M
