-- アビセア-グロウベルグ

local M = { id = 254 }

local acitem = require 'item'

M.routes = {
    conf = {
	 {x=-552,y=-760,z=32.4}, {x=-528.2,y=-772.7},
	 {x=-528.9,y=-776.1}, {a="f8touch"}
    },
    trade1 = {
	{x=481,y=680,z=56,d=50}, {x=430,y=658}, {x=416,y=668},
	{x=377,y=651}, {x=338,y=637}, {x=325,y=641,d=1},
    },
}

M.essentialPoints = {
    entrance = {x=-552,y=-760,z=32.4},
    ['j-5'] = {x=481,y=680,z=56}, -- Raja (千切れた鉄巨人の鎖, 歪んだチャリオットの装甲)
}

M.automatic_routes = {
    entrance = { route="conf" },
}

function M.defeated_handler()
    local items = {
	-- 鋼鉄の鎧板
	3265, -- 泡立つ燃料         -- Sinister Seidel (マジックポット族)
	3260, -- ミルストーンの破片 -- Teekesselchen (マジックポット族)
	3266, -- 漆黒のうで         -- Stygian Djinn (ジン族)
	3293, -- 鋼鉄の鎧板         -- Ironclad Sunderer (鉄巨人族)
	-- 三日月形の無色のジェイド
	-- 三日月形の変色ジェイド (Dark Elemental, Air Elemental)
	-- 三日月形の藍色のジェイド (Gamayun)
	3294, -- 無色の魂 (Maere)
    }
    local key_items = {
	-- 三日月形の無色のジェイド
	-- 三日月形の変色ジェイド (Dark Elemental, Air Elemental)
	-- 三日月形の藍色のジェイド (Gamayun)
    }
    acitem.showOwnItems(items)
end

M.event_handlers = {
    { event_type="stat", handler=M.defeated_handler }
}

return M
