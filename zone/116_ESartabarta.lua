-- 東サルタバルタ

local M = { id = 116 }

M.routes = {
    -- ウィンダス出口から
    lily = {
	{x=-125.6,y=-520.5,z=-4,desc="内ホルトト遺跡(Lily Tower)"},
	{x=-106,y=-514,z=-4.8}, {a="mount"},
	{x=5,y=-402}, {x=35,y=-370}, {x=106,y=-315},
	{x=191,y=-231}, {x=213,y=-121},
	-- 橋を渉る
	{x=215,y=-92}, {x=253,y=-48}, {x=277,y=-30},
	{x=319,y=35},
	-- 塔の入り口
	{x=361.5,y=100.5}, {a="dismount"}, {x=380,y=100,z=-13.2}, {}
    },
}

M.essential_points = {
    from_win = {x=-125.6,y=-520.5,z=-4}
}

M.automatic_routes = {
    from_win = { route="lily", contents="mission" },
}

return M
