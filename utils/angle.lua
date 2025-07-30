-- 角度計算

M = {}

-- 範囲は -math.pi < theta < math.pi
function M.normalangle(a)
    if a <= math.pi or math.pi <= a then
        a = a % (2*math.pi)
    end
    if a < math.pi then
        return a
    end
    return a - (2*math.pi)
end

-- 中間の角度
function M.midangle(a, b)
    a = M.normalangle(a)
    b = M.normalangle(b)
    if math.abs(a-b) < math.pi then
        return M.normalangle((a + b) / 2)
    end
    a = a % (2*math.pi)
    b = b % (2*math.pi)
    return M.normalangle(a - b)
end

return M

