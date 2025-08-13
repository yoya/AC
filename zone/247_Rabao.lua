-- ラバオ

local M = { id = 247 }

M.routes = {
    -- オデシーから出たとこ
    odymog = { -- オデシー横モグへ
	{x=-33.1,y=120.2,z=8}, {x=0,y=117,d=1},
	{x=4,y=118}, {x=4,y=119,z=8,d=0.5},
    },
    -- HP#2
    hp2ody = { -- オデシー入り口へ戻る
	{x=-21,y=111,z=8.1},  {x=-3.6,y=118.3,z=8,d=1},
    },
}

M.essentialPoints = {
    from_odyssey = {x=-33.1,y=120.2,z=8},
    hp2 = {x=-21,y=111,z=8.1},
}

M.automatic_routes = {
    from_odyssey = "odymog",
    hp2 = "hp2ody",
}

return M
