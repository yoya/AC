-- トライマライ水路

local M = { id = 169 }

M.routes = {
    -- 本ワープ
    eight = {
	{x=-308.2,y=261,z=16,desc="8属性扉の方に戻る"},
	{x=-302,y=263}, {x=-301,y=296}, {x=-303,y=299},
	{x=-336,y=299}, {x=-338,y=296},
	{x=-341.1,y=278,z=8}, {}
    },
    -- HP#1 開始
    moon = { -- 満月の泉
	{x=-257.5,y=81,z=24},{x=-259,y=84,z=24}, {}
	--{x=-258,y=83,z=24}, {}
    }
}

M.essential_points = {
    hp1 = {x=-257.5,y=81,z=24},
    from_horutoto = {x=-341.1,y=278,z=8},
}

M.automatic_routes = {
    hp1 = { route="moon" },
}

return M
