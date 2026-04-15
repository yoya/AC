-- アビセア-ウルガラン

local M = { id = 253 }

local acitem = require 'item'

M.routes = {
    conf = {
	{x=-236,y=-520,z=-40}, {x=-222.6,y=-522.3},
	{x=-222.2,y=-524.9}, {a="f8touch"}
    },
    -- #7
    gear = {
	{x=-257.4,y=236.8,z=-176.3,desc="Sub-zero Gear"},
	{x=-247,y=237}, {x=-235,y=237}, {x=-217,y=220}, {x=-209,y=206},
	-- 隠れる
	{x=-212,y=178}, {x=-233,y=83}, {x=-245,y=23}, {x=-255,y=9},
	{x=-273,y=-4},
    },
    gear2mena = {
	{x=-273,y=-4,d=10,desc="Gear から Menace へ"},
	{x=-255,y=9}, {x=-245,y=23},
	---
	{x=-234,y=41}, {x=-215,y=71}, {x=-164,y=112},
	{x=-155,y=111}, {x=-146,y=105}, {x=-141,y=93},
	{x=-139,y=69}, {x=-128,y=46,z=-176.1}
    },
    trade1 = {
	{x=-71,y=26,z=-175.3,d=50,desc="Koghatu(ヘルカルギア>べべルギア)"},
	{x=-111,y=8,z=-176.1},
    },
    trade2 = {
	{x=-71,y=26,z=-175.3,d=50,desc="Ironclad Triturator(不凍液+べべルギア>鋼鉄の鎧板)"},
	{x=-20,y=53,z=-175},
    },
}

M.essentialPoints = {
    entrance = {x=-236,y=-520,z=-40},
    h8center = {x=-71,y=26,z=-175.3},
}

M.automatic_routes = {
    entrance = { route="conf" },
}

function M.statprint_handler()
    print("zone/253 statprint_handler")
    local items = {
	-- 鋼鉄の鎧板
	3251, -- 不凍液
	3250, -- ヘリカルギア
	3245, -- ベベルギア
	3293, -- 鋼鉄の鎧板
	-- アペデマクの角
	3252, -- 凍えるうで
	3246, -- 雪神の魂
	3253, -- 上質なマーリド毛皮
	3247, -- シーシュポスの破片
	3289, -- アペデマクの角
    }
    local key_items = {
	1525, -- 破れたキマイラの翼
    }
    acitem.showOwnItems(items)
    acitem.showOwnKeyItems(key_items)
end

M.event_handlers = {
    { event_type="statprint", handler=M.statprint_handler }
}

return M
