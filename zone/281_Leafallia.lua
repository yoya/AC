-- リファーリア

local M = { id = 281 }

M.routes = {
    -- HP#1
    aged = {
	{x=4.6,y=8.2,z=-0.3,desc="Aged Stump"}, {x=-1.7,y=9.1,d=1},
	{x=-25.7,y=32,d=1}, {a="f8touch"}
    },
    ody= {
	{x=3.8,y=8.2,z=-0.3,desc="渦巻き(Odyssean Passage)"},
	{x=-18,y=4,d=1}, {x=-23,y=0,z=-0.4,d=1},
	{target="Odyssean Passage"}, {a="touch"}
    },
}

M.essential_points = {
    -- x={3.0,4.6}
    hp1 = {x=3.8,y=8.2,z=-0.3}
}

M.automatic_routes = {
    hp1 = { route="ody"},
}

return M
