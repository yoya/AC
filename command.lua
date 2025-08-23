-- Command

local M = {}

-- 直接 send_command を呼ぶと文字化けするのでラッパーを用意
function M.send(c)
    s = windower.to_shift_jis(c)
    windower.send_command(s)
end

return M
