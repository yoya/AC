local M = {}

local acitem = require 'item'

function M.contents_in(player)
    print("contents/level.contents_in")
    local item_list = {
	5190, -- カルボナーラ
	6063, -- フルーツパフェ
	5777, -- ペアクレープ
    }
    acitem.show_own_items(item_list)
end
    
return M
