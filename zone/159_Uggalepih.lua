-- ウガレピ寺院

local M = { id = 159 }

M.routes = {
    -- 本ワープ。マップ１(ユタンガから入ったとこ)
    granite = {
	{x=60,y=58,z=-8}, {x=95.9,y=59}, {x=98.9,y=57},
	{x=98.5,y=41.6}, {x=101.2,y=25.2}, {x=103.3,y=22.5},
	{x=135.9,y=17.9}, {x=138.2,y=16},
	{x=142,y=-51.8},{x=143.8,y=-54.9},
	{x=174.8,y=-55.3}, {x=177.6,y=-52.7},
	{x=181.7,y=-27.5}, {x=184.3,y=-24.6},
	{x=214.8,y=-15.3}, {x=217.8,y=-12.4},
	{x=220,y=8.8},
	{x=220,y=27.7}, {a="f8touch"}, -- Granite Door
	{x=221.8,y=52.5}, {x=224.9,y=54.6},
	{x=254.8,y=64.9}, {x=257.3,y=67.5},
	{x=261.8,y=125.6}, {x=264.5,y=127.9},
	{x=268.6,y=130.4}, {x=272.5,y=134.2},
	{x=272.4,y=145}, {x=269.9,y=147.9},
	{x=264.1,y=151.5}, {x=262.2,y=154.1},
	{x=258.3,y=175.4}, {x=257.7,y=178.1},
	{x=242.4,y=179.8}, {}
    },
    -- マップ３。盗賊のナイフの場所
    graviton = {
	{x=198.9,y=301.1,z=-16}, {x=216.4,y=300},
	{a="invisi"}, {x=218.8, y=298.4},
	{x=221.7,y=276.7}, {x=226,y=272}, {x=229.6,y=267.9},
	{x=232.7,y=264.2}, {x=236.1,y=261.5},
	{x=254.6,y=261.4}, {x=258.2,y=264.7},
	{x=260.5,y=296.6}, {x=264,y=298.6},
	{x=283.2,y=301.8}, {x=293,y=311},
	{x=308.1,y=310.2}, {x=313.8,y=301.8},
	{x=333.9, y=301.4}, {x=340,y=304.1},
	{x=340,y=328.7,z=0}
    },
}

return M

