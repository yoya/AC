-- 西アドゥリン

local M = { id = 256 }

M.routes = {
    pio = { {x=-105.5,y=-13.5}, {x=-101,y=-11},
	{x=-96.2,y=15.5}, {x=-88.8,y=15}
    },
    levil = { {x=-105.5,y=-13.5}, {x=-101,y=-11},
	{x=-97,y=16}, {x=-88.4,y=13}, {a="f8touch"}
    },
    piowp =  {{x=-88.8,y=15},  {x=-96.2,y=15.5},
	{x=-102.4,y=-11.13}, {x=-107.3,y=-11.1,a="f8touch"}, 
    },          
    cou = { {x=4.9,y=-4.7,z=0}, {x=-10,y=6,z=-0.1}, {x=-32.5,y=28.7,z=0.7},
	{x=-31.8,y=30}, {x=-29.1,y=35.1},
	{x=-28.6,y=35.8} ,{a="f8touch"}
    },
    couwp = { {x=-30,y=33.7}, {x=-32.5,y=28.7,z=0.7}, {x=-10,y=6,z=-0.1},
	{x=1.3,y=-2.4}, {x=0.9,y=-2.3}, -- {x=2.0,y=-2.9},
	{x=4,y=-4.5,z=0}, {a="f8touch"}
    },
    mum = {
	{x=-21.9,y=-81.9,z=-0.2}, {x=-15.7,y=-89.6},
	{x=-16,y=-92.9}, {x=-32.7,y=-110.3}, {x=-37.8,y=-108},
	{x=-39.8,y=-106.5}
	-- {x=-39.8,y=-106.5,a="f8touch"}
    },
    mumwp = {
	{x=-39.8,y=-106.5},{x=-37.8,y=-108},
	{x=-32.7,y=-110.3}, {x=-16,y=-92.9},
	{x=-15.7,y=-89.6}, {x=-21.9,y=-81.9,z=-0.2},
	{a="f8touch"}
    },
    tomato = { -- レンタルハウスから水道トマトの場所
	{x=-1.4,y=-142}, {x=11.1,y=-137.8}, {x=37.3,y=-158},
	{x=77.21,y=-181.4}, {x=81,y=-180.1}, {x=81.7,y=-151.4},
	{x=80.6,y=-148.7}, {x=78.9,y=-148.5}, {}
    },
    f5rala = { -- F5からララ水道
	{x=51,y=126.3}, {x=29.8,y=102.7}, {x=-41.3,y=102.8},
	{x=-43,y=121}, {x=-75,y=121.5}, {x=-74.6,y=118.9}, {}
    },
    -- ビッグブリッジ前
    k8rala = {
	{x=174.8,y=-35.8,z=3.8}, {x=141.4,y=-2.3,z=4},
	{x=141.9,y=37.2,z=12}, {x=145.4,y=37.1,z=12},
	{x=145.1,y=4.8,z=20}, {x=142,y=4.4,z=20}, {}
    },
}

M.essentialPoints = {
    wp_mum = {x=-21,y=-79.9,z=-0.2},
}

M.automatic_routes = {
    wp_mum = "mum"
}


return M
