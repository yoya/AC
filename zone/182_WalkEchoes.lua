-- ウォークオブエコーズ

local M = { id = 182 }

M.routes = {
    ornate = {
	{x=-700,y=-441,z=0.4},
	{x=-699.9,y=-305.8,z=-18},
	{a="f8touch"}
    },
    -- バルドニア-ザルカバードから入ったとこ
    coffer = { -- WoE の宝箱
	{x=-420,y=-32,z=13.5,desc="WoE の宝箱"},
	{x=-414,y=-57,z=14,d=1}, {target="Treasure Coffer"}, {a="touch"}
    },
    conf04 = {
	{x=-414,y=-57,z=14,desc="宝箱からconf4へ"},
    },
    ['conf04-in'] = {
	{}, {x=622,y=700},
    },
    ['conf11-1'] = {
	{x=760,y=0,z=72,"Conf11入場"}, {x=741,y=-20},
	{x=739,y=-139}, {X=679,y=-156},
    }
}

M.essentialPoints = {
    from_WoE = {x=-420,y=-32,z=13.5},
    ['conf11-in'] = {x=760,y=0,z=72},
}

M.automatic_routes = {
    from_WoE = {route="coffer" },
}

return M
