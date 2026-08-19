-- ジュノ港

local M = { id = 246 }

local command = require 'command'

M.routes = {
   -- HP (E)
    shemo = { {x=36,y=8.8,z=0},{x=-29,y=3},
	{x=-54.5,y=3.5}, {x=-57,y=8.5}, {x=-55.5,y=10.5},
	{a="esc"}, {target="Shemo"}, {auto=true}
    },
    ['shemo2hp-adu-east-mog'] = {
	{x=-55.5,y=10.5,"Shemo から HP#1に戻る"},
	{x=-57,y=8.5}, {x=-54.5,y=3.5},	{x=-29,y=3}, {x=36,y=8.8,z=0},
	{a="f8"}, {target="Home Point #1"},{wait=1}, {a="touch"}, {wait=2},
	{keys={"enter"}}, -- どのロージョンにする
	{keys={"right", "right", "right", "enter"}}, -- アドゥリン諸島
	{keys={"right", "enter"}}, -- 東アドゥリン
	{keys={"right", "enter"}}, -- HP#2(M)
	{keys={"up", "enter"}} -- ワープする？＞はい
    },
    abys = { {x=36,y=8.8,z=0, desc="アビセア"},
	{x=-45,y=-4}, {x=-50,y=-7,d=1}, -- {x=-53,y=-8,d=1},
	{target="Joachim"}, {wait=4},
	{keys={"enter"}}, {wait=2}, -- どうする？
	{keys={"enter"}}, {wait=3}, -- トラバーサ石がほしい
	{keys={"enter"}}, {wait=3}, -- うまくいかないので、もう一度実行
	{x=-53,y=-10},
	{target="Horst"}, {wait=2},
	{keys={"enter"}}, {wait=2}, -- 何をお願いしますか？
	{keys={"down", "down", "enter"}}, {wait=1}, -- 禁断の口まで転送してほしい
    },
    -- HP (M)
    oboro = {
	{x=-155,y=-3,z=-1}, {x=-153,y=3}, {x=-151,y=6},
	-- 階段を降りる
	{x=-153,y=31,d=1}, {x=-159,y=52,d=1}, {x=-173,y=79,d=1},
	{x=-178.4,y=84.5,z=11}, {target="Oboro"}
    },
}

M.essential_points = {
    homepoint_1_E = {x=36,y=8.8,z=0},
    homepoint_2_M = {x=-155,y=-3,z=-1},
}

M.automatic_routes = {
    homepoint_1_E = {
	{ route="shemo" },
	{ route="abys", contents="Abyssea" },
    },
    homepoint_2_M = { route="oboro" },
}

function M.incoming_text_listener(text)
    if string.contains(text, "↑ トレード終了 ↑") then
	command.send("ac move shemo2hp-adu-east-mog")
    end
end

return M
