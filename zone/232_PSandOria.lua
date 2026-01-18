-- サンドリア港

local M = { id = 232 }

M.routes = {
    greeter = {  -- ログポ交換
	{x=49,y=-106,z=-12,desc="Greeter Moogle(ログポ交換)"},
	{x=66,y=-123,d=1}, {x=65,y=-126,z=-16,d=2},
	{target="Greeter Moogle"}, {a="touch"}
    },
    mogshop = {
	{x=49,y=-106,z=-12,desc="モグ販売"},
	{x=50,y=-112,z=-12}, {target="Curio Vendor Moogle"},
	{a="touch"}
    },
}

M.essentialPoints = {
    hp2_M = {x=49,y=-106,z=-12},
}

M.automatic_routes = {
    -- hp2_M = { route="greeter", contents="loginpoint" },
    hp2_M = { route="mogshop" },
}

return M
