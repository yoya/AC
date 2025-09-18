-- 南サンドリア

local M = { id = 230 }

M.routes = {
    -- HP#1(E)
    vw = { -- void watch
	{x=-84.5,y=-65.5,z=1}, {x=-101.1,y=-18.5,z=2}
    },
    -- HP#2(A)
    sgate = {  -- 南門
	{x=45,y=-34,z=2}, {x=45,y=-29}, {x=53,y=-25},
	{x=65.5,y=-25.5}, {x=75,y=-35}
    },
    -- HP#4
    hina = {
	{x=-164,y=11,z=-1}, {x=-188,y=45},
	{x=-203,y=92},
	{x=-274,y=98}, {a="f8touch"}, {x=-277,y=98},
	{x=-291,y=98}, {x=-292,y=103},
	{x=-293.5,y=103}, {a="f8touch"}, {x=-296.5,y=103},
	{x=-299,y=100.5}, {a="f8touch"}
    },
}

M.essentialPoints = {
    hp1_e = {x=-84.5,y=-65.5,z=1},
    hp2_a = {x=45,y=-34,z=2},
}

M.automatic_routes = {
    hp1_e = { route="vw"},
    hp2_a = { route="sgate"},
}

return M
