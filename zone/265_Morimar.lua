-- モリマー台地

local M = { id = 265 }

M.routes = {
    -- WP#1
    ergon = {
	{x=368,y=37.5,z=-16}, {x=363.7,y=51.2}, {a="mount"},
	{x=361,y=68.4}, {x=335,y=221.4}, {x=330,y=230.6},
	{x=328.6,y=251.5}, {x=338.4,y=265}, {x=355.7,y=271.6},
	{x=373.7,y=269.5}, {x=391.8,y=262.7}, {x=407.8,y=262},
	{x=429.1,y=271.2}, {x=483.8,y=325.4}, {a="dismount"}
    },
    -- WP#2
    raive1 = {
	{x=112.8,y=324.4,z=-0.5}, {x=113,y=316,d=1},
	{a="faith"}, {a="mount"},
	{x=123,y=248}, {x=74,y=191}, {x=46,y=151}, {x=17,y=96},
	{x=14,y=93,z=0}, {a="dismount"},
	{x=0,y=65,z=-0.1}, {target="Bedrock Crag"},
	{enemy_filter="Bedrock"}, {auto=true}
    },
    raive2 = {
	{x=0,y=65,z=-0.1}, -- {x=-2,y=70,z=-0.4},
	{x=-13,y=74}, {a="mount"},
	{x=-50,y=105}, {x=-72,y=119}, {a="dismount"},
	{x=-83,y=127,z=0.2}, {x=-98,y=139,z=-1},
	{target="Grimy Boulders"}, {enemy_filter="Grimy"}
    }
}

return M
