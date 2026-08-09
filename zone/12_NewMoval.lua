-- ムバルポロス新市街

local M = { id = 12 }

M.routes = {
    shaft = {
	{x=439,y=-18,z=27.9,desc="Mine Shaft #2716"}, {x=449,y=-19},
	-- x={451.9},y={-20.9,-20.5},z{=28.2}
	{x=451.9,y=-20.5,z=28.2}, {}
    },
    warpshaft = {
	{x=216,y=185.1,z=19.9,desc="BC出口からBCに戻るワープまで"},
	{x=212,y=181}, {x=190,y=179}, {x=183,y=170},
	{x=178,y=153}, {x=173,y=146}, {x=163,y=137},
	{target="Sleakachiq"}
    },
}

M.essential_points = {
    hp1 = {x=439,y=-18,z=27.9},
    -- x={215.3,216},y={185.1,185.9},z=19.9},
    bcexit = {x=216,y=185.1,z=19.9},
}

M.automatic_routes = {
    hp1 = { route="shaft" },
    bcexit = { route="warpshaft" },
}

return M
