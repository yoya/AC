-- 祭壇の間 (オズトロヤ城深部)

local M = { id = 152 }

M.routes = {
    stone = {
	{x=-248,y=-98.9,desc="魔晶石ミッション"},
	{x=-341.3,y=-93.3},
	{x=-338.9,y=24.87}, {x=-345.14, y=43.47},
	{touch="Magicite"}
    },
}

M.essential_points = {
    entrance = {x=-248,y=-98.9},
}

M.automatic_routes = {
    entrance = { route="stone" },
}

return M
