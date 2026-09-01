-- 東アドゥリン

local M = { id = 257 }

local ac_equip = require 'ac/equip'

M.orig_body_item_id = 0
function M.zone_in()
    local orig_item_id = ac_equip.equip_item_by_slot_name("body")
    if orig_item_id ~= nil and orig_item_id ~= 27923 then
	M.orig_body_item_id = orig_item_id
    else
	-- 既にガーブを着ている等で元が判らない。前の記録は当てにならないので
	-- (キャラを切り替えると前のキャラのものが残る) 戻さない
	M.orig_body_item_id = 0
    end
    ac_equip.equip_item("body", 27923)  -- カウンセラーガーブ
    ac_equip.equip_item("right_ring", 27590)  -- シュネデックリング
end

function M.zone_out()
    if M.orig_body_item_id > 0 then
	ac_equip.equip_item("body", M.orig_body_item_id) -- 前のに戻す
	M.orig_body_item_id = 0
    else
	local acjob = require 'job'
	acjob.set_attack_equip()
	ac_equip.equip_item("right_ring", 27590)  -- シュネデックリング
    end
end

M.routes = {
    -- モグハウス
    mog2hp = {
	{x=-53.7,y=-128.5,z=-0.1,desc="モグハウスからHP"},
	-- {x=-54,y=-100,z=0,d=2},
	{x=-54,y=-99,d=1},
	-- -- {x=-54,y=-91,d=1}, -- {x=-48,y=-90,d=1}, {x=-50,y=-92,d=1},
	{a="f8"}, {target="Home Point #2"}, {wait=1}, {a="touch"}
    },
    ['mog2hp-spm'] = {
	{x=-53.7,y=-128.5,z=-0.1,desc="モグハウス>HP>サンド港(M)"},
	-- {x=-54,y=-100,z=0,d=2},
	{x=-53,y=-98,d=1}, {wait=2},  -- 表示されるまで待つ
	{a="f8"}, {target="Home Point #2"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"enter"}}, -- どのロージョンにする
	{keys={"right", "enter"}}, -- サンドリア王国
	{keys={"right", "enter"}}, -- サンドリア港
	{keys={"down", "down", "enter"}}, -- #2(M)
	{keys={"up", "enter"}}, -- ワープする？＞はい
    },
    ['mog2hp-jeuno-port'] = {
	{x=-53.7,y=-128.5,z=-0.1,desc="モグハウス>HP>ジュノ港(E)"},
	-- {x=-54,y=-100,z=0,d=2},
	{x=-53,y=-98,d=1}, {wait=2},  -- 表示されるまで待つ
	{a="f8"}, {target="Home Point #2"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"enter"}}, -- どのロージョンにする
	{keys={"right", "right", "enter"}}, -- ジュノ
	{keys={"right", "right", "enter"}}, -- ジュノ港
	{keys={"down", "enter"}}, -- #1(E)
	{keys={"up", "enter"}}, -- ワープする？＞はい
    },
    ['hp-jeuno-port'] = {
	{x=-51.2,y=-95,z=-0.1}, {wait=4},
	{a="f8"}, {target="Home Point #2"}, {wait=2}, {a="touch"}, {wait=2},
	{keys={"enter"}}, -- どのロージョンにする
	{keys={"right", "right", "enter"}}, -- ジュノ
	{keys={"right", "right", "enter"}}, -- ジュノ港
	{keys={"down", "enter"}}, -- #1(E)
	{keys={"up", "enter"}}, -- ワープする？＞はい
    },
    ['mog2hp-choco'] = {
	{x=-53.7,y=-128.5,z=-0.1,desc="モグハウス>HP>アトルガン#3(A)"},
	-- {x=-54,y=-100,z=0,d=2},
	{x=-53,y=-98,d=1}, {wait=2},  -- 表示されるまで待つ
	{a="f8"}, {target="Home Point #2"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"enter"}}, -- どのロージョンにする
	{keys={"right", "right", "down", "down", "enter"}}, -- 西アトルガン地方
	{keys={"down", "enter"}}, -- アトルガン白門
	{keys={"right", "enter"}}, -- #3(A)
	{keys={"up", "enter"}}, -- ワープする？＞はい
    },
    ['mog2hp-mhaura'] = {
	{x=-53.7,y=-128.5,z=-0.1,desc="モグハウス>HP>マウラ#1"},
	-- {x=-54,y=-100,z=0,d=2},
	{x=-53,y=-98,d=1}, {wait=2},  -- 表示されるまで待つ
	{a="f8"}, {target="Home Point #2"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"enter"}}, -- どのリージョンにする
	{keys={"right", "right", "right", "right", "down", "down", "enter"}}, -- コルシュシュ
	{keys={"down", "enter"}}, --  マウラ
	{keys={"down", "enter"}}, -- #1
	{keys={"up", "enter"}}, -- ワープする？＞はい
    },
    mog2wp = {
	{x=-53.7,y=-128.5,z=-0.1,desc="モグハウスすぐのWaypoint"}, {wait=1},
	{x=-62,y=-122,z=0}, {target="Waypoint"}, {wait=1},
	{a="touch"}, {wait=2},
	{keys={"right", "enter"}}, -- 東アドゥリン
	{keys={"right", "down", "enter"}}, -- ヤッセ方面船着き場前
    },
    gob = {
	{x=-56,y=-128.5,z=-0.1,desc="ゴブの不思議箱"},
	--{x=-58,y=-100}, {x=-63,y=-94},
	{x=-58,y=-101}, {x=-64,y=-94},
	{x=-80,y=-94,d=1}, {target="Winrix"}, {wait=1}, {a="touch"}, {wait=1},
	{a="touch"}, {keys={"down", "right", "right", "enter", 10, "escape"}},
	--{wait=5}, {a="esc"},
	{x=-64,y=-94}, {x=-58,y=-101},
	{x=-58,y=-118,z=-0.1}, {}
    },
    works = {
	{x=-56,y=-128.5,z=-0.1,desc="ワークス消化"},
	{x=-61,y=-123,z=0,d=1}, {wait=2},  -- 表示されるまで待つ,
	{target="Waypoint"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"right", "right", "right", "down", "enter"}}, -- カミール山麓
	{wait=0.5}, {keys={"right", "enter"}}, -- #2
    },
    auction = {
	{x=-56,y=-128.5,z=-0.1,desc="モグハウスからオークションへ"},
	{x=-54,y=-99}, {x=-48,y=-94},
	{x=-24.5,y=-92.3,z=-0.6}, {target="Auction Counter"}
    },
    -- HP#2(M)
    moghouse = {
	{auto=false},  -- auto だとリーダーの後を追いかけるので
	{x=-50.5,y=-95,z=-0.1,desc="HPからモグハウス"}, {x=-55,y=-101},
	{x=-56,y=-109}, {}
    },
    -- HP#2(M) に立ったまま、ワープ先を選ぶところまで進めて止まる
    hp2warp = {
	{auto=false},  -- auto だとリーダーの後を追いかけるので
	{x=-50.5,y=-95,z=-0.1,desc="HP#2からワープ先の選択まで"},
	{a="f8"}, {target="Home Point #2"}, {wait=1}, {a="touch"}
    },
    -- PCK
    pck = {
	{x=-101.3,y=-10.7,z=-0.1}, {x=-83,y=-2}, {x=-83,y=5},
	{x=-86,y=8}, {x=-110,y=10}, {x=-112,y=14},
	{x=-113,y=19.1,z=-0.7}, {a="f8touch"}
    },
    pckwp = {
	{x=-113,y=19.1,z=-0.7}, {x=-112,y=14}, {x=-110,y=10},
	{x=-86,y=8}, {x=-83,y=5}, {x=-83,y=-2},
	{x=-100.5,y=-9.4,z=-0.1}, {a="f8touch"}
    },
    f7rala = {
	{x=-101.3,y=-10.7,z=-0.1}, {x=-111.8,y=-1.6,z=0},
	{x=-123.5,y=4.2,z=0}, {x=-126.2,y=60.1,z=0},
	{x=-129,y=60.2,z=0.1}, {x=-130,y=57.3,z=0.9},
	{x=-129.7,y=28.9,z=8.1}, {x=-126.5,y=28.4,z=8.1},
	{}
    },
    -- SCT
    sct = {
	{x=-77.9,y=-63.9,z=-0.2}, {x=-109,y=-56.8},
	{x=-111.6,y=-54.2}, {x=-112.7,y=-48.9}, {a="f8touch"}
    },
    sctwp = {
	{x=-97.4,y=-51}, {x=-112.7,y=-48.9},
	{x=-111.6,y=-54.2},
	{x=-109,y=-56.8}, {x=-77.9,y=-63.9},
	{a="f8touch"}
    },
    -- ヤッセの船着場
    ['ionis-wp'] = {
	{auto=false},  -- auto だとリーダーの後を追いかけるので
	-- Waypoint
	{x=-57.8,y=85.2,z=-0.1},{x=-54.3,y=85,d=1},
	{target="Quiri-Aliri"}, {wait=1},
	{a="enter"}, {wait=1}, {a="enter"}, {keys={"up", "enter"}},
	{wait=2}, {x=-57.6,y=85.1,d=1}, {a="esc"},
	{target="Waypoint"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"right", "right", "right", "enter"}}, -- マリアミ渓谷を選択
	{keys={"right", "right", "enter"}}, -- #4 を選択
    },
    ['ionis-wp-sortie'] = {
	{auto=false},  -- auto だとリーダーの後を追いかけるので
	-- Waypoint
	{x=-57.8,y=85.2,z=-0.1},{x=-54.3,y=85,d=1},
	{target="Quiri-Aliri"}, {wait=1},
	{a="enter"}, {wait=1}, {a="enter"}, {keys={"up", "enter"}},
	{wait=2}, {x=-57.6,y=85.1,d=1}, {a="esc"},
	{target="Waypoint"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"right", "right", "right", "down", "enter"}}, -- カミール
	{keys={"right", "right", "enter"}}, -- #4 を選択
    },
    ['ionis-hp'] = {
	{auto=false},  -- auto だとリーダーの後を追いかけるので
	-- HP#1
	{x=-52.9,y=58.9,z=-0.1}, {x=-54,y=78,d=1},
	{x=-53.5,y=82,d=1},
	-- HP#1
	{target="Quiri-Aliri"}, {wait=1},
	{a="enter"}, {wait=1}, {a="enter"}, {keys={"up", "enter"}},
	{wait=2}, {x=-57.6,y=85.1,d=1},
	{target="Waypoint"}, {wait=1}, {a="touch"}, {wait=2},
	{keys={"right", "right", "right", "enter"}}, -- マリアミ渓谷を選択
	{keys={"right", "right", "enter"}}, -- #4 を選択
    },
    -- 太陽の広場 (Coronal Esplanade)
    bayld = { -- ベヤルド交換
	{x=27.1,y=-60.8,z=-40.2}, {x=62,y=-74}, {x=66,y=-76}, {x=66,y=-109},
	{x=63,y=-113,z=-40.3,d=1}, {target="Runje Desaali"}, {auto=true}
    },
    -- 城門前
    zaff = {
	{x=96,y=-74.5,z=-40.2,desc="Zaffeld(魔女クエ)"},
	{x=70,y=-54,d=1}, {x=71,y=-16,d=1},
	{target="Zaffeld"}
    },
    -- モグハウス内
    house2garden = {
	{x=0,y=0,z=0}, {x=-1, y=-7}, {wait=1},
	{keys={"escape", "escape", "escape", "numpad5"}},
	{wait=1},
	{a="opendoor"},
	{wait=1},
	{keys={"up", "enter"}}, -- 出るエリアを選択する
	{keys={"up", "enter"}}, -- モグガーデン
    },
}

M.essential_points = {
    pck = {x=-101.3,y=-10.7,z=-0.1},
    -- x=(-59.4,-51.5),y=-128.5
    from_moghouse = {x=-56,y=-128.5,z=-0.1, dx=5,dy=1},
    homepoint_1 = {x=-52.9,y=58.9,z=-0.1, d=1.5},
    -- HP#2(M) x=(-51.3,-50.5), y=(-95.7--93.3)
    homepoint_2_M = {x=-50.5,y=-95.5,z=-0.1, d=2.5},
    yahse_dock = {x=-57.8,y=85.2,z=-0.1},
    sun_square = {x=27.1,y=-60.8,z=-40.2}, -- 太陽の広場 (Coronal Esplanade)
    moghouse_in = {x=0,y=0,z=0}
}

M.automatic_routes = {
    pck = { route="pck" },
    from_moghouse = {
	{ route="mog2hp" },
	{ route="mog2hp-spm", contents="LoginPoint" },
	{ route="gob", contents="GobMys" },-- Gobbie Mystery Box
	{ route="works", contents="works" },
	{ route="mog2wp", contents="Sortie" },
	{ route="mog2wp", contents="Leveling" },
	{ route="mog2hp-jeuno-port", contents="Abyssea" },
	{ route="mog2hp-choco", contents="ChocoboRace" },
	{ route="mog2hp-mhaura", contents="Ambus" },
    },
    homepoint_2_M = {
	{ route="moghouse" },
	-- オーブを持っている時は、モグハウスに行かずワープ先の選択まで進める
	{ route="hp2warp", contents="trove", item={
	      9275,  -- マーズオーブ
	      9276,  -- ビーナスオーブ
	} },
	{ route="hp-jeuno-port", contents="Leveling",
	  zone_from=273 -- ウォーの門 (レベル上げ)
	},
    },
    yahse_dock = {
	{ route="ionis-wp" },
	{ route="ionis-wp-sortie", contents="Sortie"},
    },
    homepoint_1 = { route="ionis-hp" },
    sun_square = { route="bayld" }, -- ベヤルド交換
    moghouse_in = { route="house2garden", contents={"Leveling", "Abyssea"},
		    zone_from=-280},
}

return M
