-- 醴泉島-秘境

local M = { id = 291 }

M.routes = {
    -- Ethereal Ingress
    omen = { -- Earthly Convrescence (オーメン入り口
	{x=-390.2,y=-835.1,z=-439.8},
	{x=-357.5,y=-837.7,z=-440, d=1}
    },
    -- オーメン出てから
    incant = { -- Incantrix
	{x=-378,y=-820,z=-441.3},
	{x=-361,y=-842,z=-440.3,d=1}, {a="f8touch"}
    },
}

M.essentialPoints = {
    ingress = {x=-390.2,y=-835.1,z=-439.8},
    from_omen = {x=-378,y=-820,z=-441.3},
}

M.automatic_routes = {
    ingress = "omen",
    from_omen = "incant",
}

return M
