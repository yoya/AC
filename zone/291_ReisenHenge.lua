-- 醴泉島-秘境

local M = { id = 291 }

M.routes = {
    -- 入り口
    shift = { -- Shiftrix
	{x=-500,y=-487.7,z=-19.1}, {wait=4},
	{target="Shiftrix"}, {a="touch"}
    },
    -- ドメイン
    quet = {  -- Quetzalcoatl
	{x=640,y=-921,z=-372},--{x=618,y=-949,z=-371,d=2},
	--{x=620,y=-948,z=-371,d=2}, -- 右前すぎる気がする
	{x=621,y=-947,z=-371,d=2},
	{puller=true}
    },
    -- Ethereal Ingress
    omen = { -- Earthly Convrescence (オーメン入り口
	{x=-390.2,y=-835.1,z=-439.8},
	{x=-357.5,y=-837.7,z=-440, d=1},
	{target="Earthly Concrescence"}
    },
    -- オーメン出てから
    incant = { -- Incantrix
	{x=-378,y=-820,z=-441.3},
	{x=-361,y=-842,z=-440.3,d=1}, --  {a="f8touch"}
	{target="Incantrix"}, {a="touch"}
    },
}

M.essentialPoints = {
    entrance = {x=-500,y=-487.7,z=-19.1},
    domain = {x=640,y=-921,z=-372},
    ingress = {x=-390.2,y=-835.1,z=-439.8},
    from_omen = {x=-378,y=-820,z=-441.3},
    toad_pond = {x=-440,y=-36,z=-41.4},
}

M.automatic_routes = {
    entrance = { route="shift" },  -- Shiftrix
    ingress = { route="omen" },
    from_omen = { route="incant" }, -- Incantrix
    domain = { route="quet"}, -- Quetzalcoatl
}

return M
