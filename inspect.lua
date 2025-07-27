-- 行動を判断する為の監視データ
-- 最後に WS をうった時間とか。

local M = {}

M.ws = function()
    M.ws_time = os.time()
end

M.eminence_point = function(pt)
    M.eminence_point = pt
end
