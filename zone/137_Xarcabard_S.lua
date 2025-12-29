-- ザルカバード〔Ｓ〕

local M = { id = 137 }

local io_net = require 'io/net'

M.routes = {
    -- HP#1
    animal = {  -- Animal Spoor
	{x=224.3,y=-253.2,z=-13.2}, {x=226,y=-247}, {a="mount"},
	{x=294,y=-242,d=1}, {x=389,y=-222,d=1}, {x=407,y=-207},
	{x=447,y=-182}, {x=476,y=-179}, {x=495,y=-188},
	{x=504,y=-221}, {x=518,y=-241}, {x=524,y=-269}, {x=536,y=-281},
	{a="dismount"}, {x=542.7,y=-289,z=-0.2}, {a="f8touch"}
    },
    rut = {  -- Wheel Rut
	{x=224.3,y=-253.2,z=-13.2}, {x=226,y=-247}, {a="mount"},
	{x=253,y=-250}, {x=334,y=-289}, {x=339,y=-298},
	{a="dismount"}, {x=343.7,y=-307.5,z=-0.4}, {a="f8touch"}
    },
    forb = { -- Forbidding Portal
	{x=224.3,y=-253.2,z=-13.2}, {x=226,y=-247}, {a="mount"},
	{x=261,y=-199}, {x=304,y=-157}, {x=329,y=-103}, {x=358,y=-53},
	{x=384,y=-4}, {x=389,y=12}, {x=396,y=30}, {x=395,y=50},
	{x=393,y=65}, {x=391,y=86}, {x=375,y=107}, {x=350,y=117},
	{x=320,y=139}, {x=320,y=147}, {a="dismount"},
	{x=320,y=156,z=-8.9}, {a="opendoor"}
	
    },
    red = {
	{x=224.3,y=-253.2,z=-13.2}, {x=226,y=-247}, {a="mount"},
	{x=187,y=-229,d=1}, {x=151,y=-176,d=1}, {x=119,y=-164,d=1},
	{x=75,y=-168,d=1}, {x=32,y=-164,d=1}, {x=1,y=-153},
	{x=-28,y=-115}, {x=-44,y=-86}, {x=-70,y=-75},
	{x=-101,y=-48}, {a="dismount"}, {x=-104.8,y=-51.4,z=-25.5},
	{target="Rally Point: Red"}
    },
    red2green = {
	{x=-104.8,y=-51.4,z=-25.5}, {x=-101,y=-48}, {a="mount"},
	{x=-70,y=-75}, {x=-44,y=-86}, {x=-28,y=-115},
	{x=1,y=-153}, {x=32,y=-164,d=1}, {x=33,y=-209},	{a="dismount"},
	{x=42,y=-217}, {x=52.1,y=-205.4,z=-23.7}, {target="Rally Point: Green"}
    },
    green2spell = {
	{x=54,y=-203.8,z=-23.4}, {x=52,y=-217},
	{x=75,y=-247,z=-24.1},
    },
    green2blue = {
	{x=54,y=-203.8,z=-23.4}, {x=42,y=-217}, {a="mount"},
	{x=33,y=-209}, {x=32,y=-164,d=1},
	-- 共通 red2green と
	{x=22,y=-113}, {x=55,y=-104}, {x=135,y=-31}, {a="dismount"},
	{x=135.7,y=-26.1,z=-16.5}, {target="Rally Point: Blue"}

    },
    blue2snow = { -- Excavated Snow
	{x=135.7,y=-26.1,z=-16.5}, {x=146.3,y=-16.8,z=-17.8},
	{target="Excavated Snow"}
    }
}

M.essentialPoints = {
    hp_1 = {x=224.3,y=253.2,z=-13.2}
}

M.automatic_routes = {
    -- hp_1 = { route="wanted" },
}

return M
