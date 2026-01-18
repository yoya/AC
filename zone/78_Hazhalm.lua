-- ハザルム試験場

local M = { id = 78 }

M.routes = {
    gate = {
	{x=652.8,y=-104,z=-269.5,desc="Entry Gate(オーディンの間)"},
	{x=634,y=-99}, {x=622,y=-88},
	{x=613,y=-67}, {x=592,y=-58}, {x=583,y=-48}, {x=577,y=-32},
	{x=569,y=-23}, {x=565,y=-21}, {x=559,y=-22}, {x=551,y=-26},
	{x=542,y=-30}, {x=510,y=-21}, {x=490,y=-20,z=-226.1}, {a="f8"},
	{target="Entry Gate"}, {a="touch"},
    }
    
}

M.essentialPoints = {
    entrance = {x=652.8,y=-104,z=-269.5},
}

M.automatic_routes = {
    entrance = { route="gate" },
}

return M
