-- カダーバの浮沼

local M = { id = 79 }

M.routes = {
    pec = { -- 珍妙なモンスター
	{x=660,y=239.5,z=-4}, {x=652,y=260},
	{a="mount"}, {x=657.6,y=282.9},
	{x=687,y=326.2}, {x=709.7,y=357.8},
	{x=728,y=384.6}, {x=720.6,y=449.4},
	{x=732.6,y=477.1}, {x=734.4,y=519.5},
	{x=749,y=537.2}, {x=776.4,y=539.6},
	{x=787.4,y=644.6}, {a="dismount"}
    },
    -- 本ワープ
    arra = { -- すぐ左のアラパゴに入る
	{x=-658,y=341,z=-13}, {x=-640.8,y=340,z=-16}, {}
    }
}

M.essentialPoints = {
    book_warp = {x=-658,y=341,z=-13},
}

M.automatic_routes = {
    book_warp = "arra"
}

return M
