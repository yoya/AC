-- アトルガン白門

local M = { id = 50 }

M.routes = {
    -- 合成
    gento = {
        {r="gento2"}, {r="gentoa"}
    },
    -- #1 出発
    naja = { -- サムライセンチネル
        {x=-20.1,y=-19.9,z=0}, {x=17.3,y=-7.6,z=0},
        {x=19.8,y=-7.9,z=0}, {x=20.1,y=-24.6,z=-6},
        {x=18.3,y=-26.1,z=-6}, {x=-13.4,y=-28.4,z=-6},
        {x=-14.9,y=-30.6,z=-6}, {x=-15.2,y=-49.5,z=-6},
        {x=-13.5,y=-51.4,z=-6}, {x=12.6,y=-53.7,z=-6},
        {x=14,y=-55.7,z=-6}, {x=16.6,y=-62.1,z=-6},
        {x=17.8,y=-63.4,z=-6}, {x=23.2,y=-62.9,z=-6},
        {x=23.4,y=-62.1,z=-6}, {a="f8touch"},
        {x=24.3,y=-59,z=-6}, {x=31.6,y=-56,z=-6.3}            
    },
    -- #2 出発
    gento2 = { -- 幻灯ワープ
        {x=129,y=-16}, {x=112,y=20.9},
        {x=112,y=24.23}, {a="f8touch"},
        {x=112.7,y=29}, {x=124.2,y=32.4},
        {x=124.9,y=60.9}, {x=124.9,y=62}, {a="f8touch"}
    },
    ass = { -- 公務代理店 (アサルト)へ
        {x=129,y=-16}, {x=114.9,y=-18.9}, {x=112.3,y=-23.5},
         {a="f8touch"}, {x=111.9,y=-27.5}, 
        {x=112,y=-41}, {x=112,y=-41.8}, {a="f8touch"},
    },
    wala = { -- ワラーラ寺院へ
        {x=129,y=-16,z=0}, {x=94.3,y=6.2}, {x=81.7,y=19.6},
        {x=80.5,y=23.3}, {a="f8touch"},
        {x=79.9,y=28}
    },
    tea = { -- 茶屋シャララト
        {x=129,y=-16,z=0}, {x=83.6,y=-20.7},
        {x=80.5,y=-24.1}, {x=81,y=-55.4},
        {x=83,y=-62.3,z=0}, {x=81.4,y=-63.8,z=0},
        {x=66.8,y=-65.3,z=-6}, {x=65.6,y=-66.8,z=-6},
        {x=55.7,y=-68.3,z=-6}, {x=54.2,y=-69.6,z=-6},
        {x=54.3,y=-103.3,z=-6}, {x=62,y=-108.6,z=-6},
        {x=64.1,y=-115.4,z=-6}, {x=65.9,y=-116.8,z=-6},
        {x=77.4,y=-119.6,z=-6}, {x=78.1,y=-122.7,z=-6},
    },
    -- 公務代理店 (アサルト)
    gentoa = {
        {x=119.6,y=-37.2}, {x=112.5,y=-35.4},
        {x=112.1,y=-27}, {a="f8touch"}, {x=111.9,y=-23},
        {x=112,y=23.1}, {a="f8touch"}, {x=112.2,y=27.3},
        {x=114.2,y=30.3}, {x=125.2,y=31.8},
        {x=125,y=60.2}, {a="f8touch"}
    },
}

return M

