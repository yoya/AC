-- アットワ地溝

local M = { id = 7 }

M.routes = {
 -- CL125 ワープ
    loose = {
        {x=-311,y=167,z=-5.1}, {x=-286,y=178},
        {a="mount"}, {x=-286,y=185},
        {x=-300,y=194}, {x=-302,y=219}, {x=-297,y=241},
        {x=-295,y=254}, {x=-279,y=260}, {x=-268,y=258.7},
        {x=-262,y=260}, {x=-245,y=260}, -- 天然の橋
        {x=-245,y=250}, {x=-229,y=246}, {x=-219,y=260},
        {x=-210,y=262}, {x=-189,y=256},
        {x=-180,y=241}, {x=-180,y=185}, {x=-174,y=181},
        {x=-138,y=181}, {x=-103,y=179}, {x=-99,y=166},
        {x=-98,y=144}, {x=-104,y=139}, {x=-112,y=134},
        {x=-115,y=129}, {x=-108,y=115},
        {x=-101,y=117}, {x=-99,y=98}, -- 天然の橋
        {x=-99,y=73}, {x=-101,y=60}, {x=-104,y=23},
        {x=-112,y=-1}, {x=-100,y=-40}, {x=-95,y=-55},
        {x=-66,y=-61}, {x=-46,y=-59}, -- 天然の橋
        {x=-43,y=-48}, {x=-29,y=-45}, {x=-18.5,y=-60},
        {x=-9,y=-61}, {x=4,y=-59}, {x=46,y=-61},
        {x=57,y=-50}, {x=57,y=8}, {x=47,y=20},
        {x=20,y=24}, {x=19,y=60}, {x=20,y=78},
        {x=29,y=95}, {x=49,y=102}, {x=55,y=114},
        {x=62,y=113},
        --- 洞窟から出る
        {x=75,y=86}, {x=89,y=81}, {x=132,y=86},
        {x=183.3,y=131.7}, {x=242,y=199}, {x=285,y=214},
        {x=344,y=217}, {x=397,y=198}, {x=439,y=150},
        {x=478,y=124}, {x=519,y=119}, {x=521,y=91},
        {x=528,y=71}, {x=510,y=40},
        {a="dismount"}, {x=481,y=42},
    },
    loose2entrance = { --登山口へ移動。（マウントは使わない）
        {x=478.9,y=41.7,z=20}, {x=509,y=35},
        {x=517,y=27}, {x=503,y=15},
        {x=488,y=9}, {x=472,y=7}, {x=461.5,y=19},
        {x=453,y=15}, {x=444,y=17},
        {x=406.4,y=-9.3}, {x=394.6,y=-19.1}
    },
}

return M

