-- チョコボサーキット

local M = { id = 70 }

local command = require 'command'
local incoming_text = require 'incoming/text'

function M.incoming_text_handler(text)
    -- レースが終わったらデジョンする
    -- エミネンス目標対応で、レースの連続観戦はしない前提
    if string.contains(text, "次回の開催までごきげんよう！") then
	command.send("ac warp")
    end
end

M.text_handler_idx = nil
function M.zone_in()
    M.text_handler_idx = incoming_text.addListener("", M.incoming_text_handler)
end

function M.zone_out()
    if M.text_handler_idx ~= nil then
	incoming_text.removeListener(M.text_handler_idx)
    end
end

M.routes = {
    ent = {
	{x=-320,y=-475,z=-0.3}, {x=-326,y=-464},
	{x=-327.1,y=-456.2}, {x=-329,y=-454},
	{x=-330,y=-448},
	{x=-330.3,y=-413},
	{a="f8touch"}, {a="wait"}, {a="up"}, {a="enter"}
	--{x=-330.3,y=-413}, {a="f8touch"}, {a="wait"},
	--{a="wait"},{a="up"}, {a="wait"}, {a="enter"}
    },
    -- アトルガンから入った場所
    aht2warp = {  -- ワープで飛ぶ
	{x=-149.9,y=-386.4,z=0}, {x=-160,y=-378},
	{x=-162.5,y=-372,z=0}, {}, {w=3},
	{a="up"}, {a="enter"}
	--{a="up"}, {a="wait"}, {a="enter"}
    },
    aht2warp2ent = {
	{x=-280,y=-463,z=-4}, {x=-276,y=-466}, {x=-253.1,y=-469.2,z=-5},
	{a="f8touch"}, {a="wait"}, {a="up"}, {a="enter"}
	--{a="f8touch"}, {a="wait"},
	--{a="wait"}, {a="up"}, {a="wait"}, {a="enter"}
    },
}

M.essentialPoints = {
    wand_warp_point = {x=-320,y=-475,z=-0.3},
    from_aht = {x=-149.9,y=-386.4,z=0},
    from_aht_warp = {x=-280,y=-463,z=-4},
}

M.automatic_routes = {
    wand_warp_point = { route="ent" },
    from_aht = { route="aht2warp" },
    from_aht_warp = { route="aht2warp2ent" },
}

return M
