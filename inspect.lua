-- 行動を判断する為の監視データ
-- 最後に WS をうった時間とか。

local utils = require 'utils'

local M = {
    ws_time = 0,
    sc_ws_1_time = 0,
    sc_ws_2_time = 0,
}
utils.inspect = M

function M.ws()
    M.ws_time = os.time()
end

function M.sc_ws_1()
    M.sc_ws_1_time = os.time()
end

function M.sc_ws_2()
    M.sc_ws_2_time = os.time()
end

return M
