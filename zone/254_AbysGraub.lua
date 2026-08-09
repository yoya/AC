-- アビセア-グロウベルグ

local M = { id = 254 }

M.routes = {
    conf = {
	{x=-552,y=-760,z=32.4}, {auto=false},
	{x=-528.2,y=-772.7},
	{x=-528.9,y=-776.1,d=1}, {a="f8touch"}, {wait=1},
	-- ビジタントをつける
	{keys={"right", "enter", "right", "enter", "up", "enter", "up", "enter"}}, {wait=2},
	{x=-517,y=-755,d=1}, {target="Veridical Conflux #01"}, {a="f8touch"}
    },
    trade1 = {
	{x=481,y=680,z=56,d=50}, {x=430,y=658}, {x=416,y=668},
	{x=377,y=651}, {x=338,y=637}, {x=325,y=641,d=1},
    },
    -- #3
    mina = {
	{x=424,y=-174,z=-0.9,desc="ミナルジャの頭骨 Minaruja(I-10)"},
	{x=369,y=-145}, {x=340,y=-117,z=-15}, {auto=true}
    },
    jac = {
	{x=340,y=-117,z=-15,desc="ジャキュルスの翅 Jaculus(I-8)"},
	-- {x=327,y=29},
	{x=316,y=163},
    },
    wiv = {
	{x=346,y=213,z=-39.4,desc=""},
    },
    ning = {
	{x=380,y=240,z=-31,desc="Ningishzida"},
    },
    alfa = {
	{x=310,y=173,z=-32,desc="アルファルドの牙"}
    },
    alfa2 = {
	{x=310,t=158,z=-33.5,desc="アルファルドの牙"}
    },
}

M.essential_points = {
    entrance = {x=-552,y=-760,z=32.4},
    ['j-5'] = {x=481,y=680,z=56}, -- Raja (千切れた鉄巨人の鎖, 歪んだチャリオットの装甲)
    alfard = {x=310,y=173,z=-32,desc="アルファルドの牙"}
}

M.automatic_routes = {
    entrance = { route="conf" },
}

M.essential_items = {
    -- 鋼鉄の鎧板
    3265, -- 泡立つ燃料         -- Sinister Seidel (マジックポット族)
    3260, -- ミルストーンの破片 -- Teekesselchen (マジックポット族)
    3266, -- 漆黒のうで         -- Stygian Djinn (ジン族)
    3293, -- 鋼鉄の鎧板         -- Ironclad Sunderer (鉄巨人族)
    -- 三日月形の無色のジェイド
    -- 三日月形の変色ジェイド (Dark Elemental, Air Elemental)
    -- 三日月形の藍色のジェイド (Gamayun)
    3294, -- 無色の魂 (Maere)
    -- アルファルドの牙
    3261, -- ミナルジャの頭骨 Minaruja(I-10)
    3262, -- ジャキュルスの翅	Jaculus(I-8)
    3267, -- 森神の翼 (雑魚ウィヴル族) #3 から北
    3268, -- 上質な鎧竜の装甲	Glade Wivre
    3291, -- アルファルドの牙
}
M.essential_key_items = {
    1564, -- 三日月形の無色のジェイド
    1565, -- 三日月形の変色ジェイド (Dark Elemental, Air Elemental)
    1654, -- 三日月形の藍色のジェイド (Gamayun)
    -- アルファルドの牙
    1530, -- 毒々しいハイドラの牙
}

--function M.defeated_handler() 呼ばれない？
--    acitem.show_own_items(items)
--end

--M.event_handlers = {
--    { event_type="stat", handler=M.defeated_handler }
--}

return M
