-- テリガン岬

local M = { id = 113 }

M.routes = {
    -- HP#1
    frag = { -- 風の祈り (古代石碑巡礼)
	{x=-303,y=525,z=-8}, {x=-301,y=507}, {a="mount"},
	{x=-288,y=491}, {x=-271,y=452}, {x=-263,y=445},
	{x=-216.5,y=435}, {x=-149,y=432},
	{x=-141,y=423}, {x=-132.5,y=419.5}, {x=-109,y=420},
	{x=-100.5,y=424.5}, {x=-102,y=443}, {a="dismount"},
	{x=-108,y=451.5,z=-8.1},
    },
    -- Unityワープ
    ved = {
	{x=68.2,y=148,z=-6.2,desc="Vedrfolnir(Unity1,CL128)"},
	{x=72,y=148,z=-5.3,d=1}, {a="mount"},
	{x=79,y=148,z=0.2}, {x=140,y=151,z=0.7,d=1}, {a="dismount"}
    },
}

M.essentialPoints = {
    unity_warp = {x=68.2,y=148,z=-6.2},
}

M.automatic_routes = {
    unity_warp = { route="ved" },
}

return M
