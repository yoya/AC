-- 凍結の回廊

local M = { id = 203 }

local contents = require 'contents'

M.routes = {
    -- CL135 ワープ
    frag = { -- 氷の祈り (古代石碑巡礼)
	{x=500.4,y=523.3,z=0},
	{x=502,y=574}, {x=507.5,y=578},
	{x=540.5,y=581}, {x=549.5,y=585.5},
	-- ここまで共通
	{x=567,y=607},
    },
    proto = { -- 氷のクリスタル
	{x=500.4,y=523.3,z=0},
	{x=502,y=574}, {x=507.5,y=578},
	{x=540.5,y=581}, {x=549.5,y=585.5},
	-- ここまで共通
	{x=558.5,y=598}, {a="f8touch"}
    },
    bc = contents.trial.bc_route,
}

M.essentialPoints = {
    entrance = {x=500,y=523.3,z=0},
    bc_in = contents.trial.bc_point,
}

M.automatic_routes = {
    entrance = { route="proto" },
    bc_in = { route="bc" },
}

return M
