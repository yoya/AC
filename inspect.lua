-- 行動を判断する為の監視データ
-- 最後に WS をうった時間とか。

local utils = require 'utils'

local M = {
    ws_time = 0,
    eminence_point = 0,
}
utils.inspect = M

function M.ws()
    M.ws_time = os.time()
end

function M.eminence(pt)
    M.eminence_point = pt
end

return M
