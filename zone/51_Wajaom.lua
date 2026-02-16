-- ワジャーム樹林

local M = { id = 51 }

M.routes = {
    -- CL125or135 ワープ
    pec = { --- 珍妙なモンスター
	{x=100,y=-163,z=-12}, {x=99,y=-170},  {a="mount"},
	{x=87.7,y=-256.6},
	{x=25.3,y=-264.9}, {x=-25.5,y=-294.5},
	{x=-55.9,y=-348.4}, {x=-63.3,y=-457.9},
	{x=-97,y=-463.2}, {x=-98.3,y=-542.2},{x=-52.6,y=-610.1},
	{x=-56,y=-640}, {a="dismount"}, {x=-57,y=-648.8},
    },
    -- アトルガン白門から
    vw = {
	{x=690.2,y=220,z=-18.5}, {x=679,y=221,z=-15.5},
	{x=681,y=231,z=-15.7}, {target="Atmacite Refiner"}, {a="touch"}
    },
}

M.essentialPoints = {
    unity_warp = {x=100,y=-163,z=-12},
    from_whitegate = {x=690.2,y=220,z=-18.5},
}

M.automatic_routes = {
    unity_warp = { route="pec" },
    from_whitegate = { route="vw" },
}

return M
