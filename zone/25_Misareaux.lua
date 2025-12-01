-- ミザレオ海岸

local M = { id = 25 }

M.routes = {
    -- 地下壕から西に出たとこスタート
    dila = { -- Dilapidated Gate. ウルミアの場所。
	{x=638.9,y=-220.9}, {x=632.1,y=-224.6}, {a="mount"},
	{x=626.8,y=-228.3}, {x=613,y=-253.2},
	{x=576,y=-267.8}, {x=536.2,y=-308.1},
	{x=507.8,y=-366}, {x=491.1,y=-385.5}, {x=422.6,y=-407.3},
	-- 崖から降りる
	{x=410.1,y=-406.2,z=22.9},
	{x=334,y=-399.5}, {x=285.3,y=-401.4}, {x=268.4,y=-412.2},
	{x=264.5,y=-423.3}, {a="dismount"},
	{x=260.6,y=-436.5}, {a="esc"}, {wait=1}, {a="touch"}
    },
    -- HP#1
    esca = { -- Undulating Confluence
	{x=-66,y=562,z=-17.3}, {x=-64,y=571,z=-18.8,d=1}, {x=-54,y=571,z=-21.8}-- ,
	-- {w=5}, {a="tab"},
    },
}

M.essentialPoints = {
    homepoint_1 = {x=-66,y=562,z=-17.3},
}

M.automatic_routes = {
    homepoint_1 = { route="esca" },
}

return M

