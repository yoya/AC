-- 角度計算

local M = {}

-- 0 は正として扱う(角度として都合がよい)
function numsign(a)
    if a < 0 then
	return -1
    end
    return 1
end

-- 範囲は 0 < theta < 2*math.pi
function M.normalangle(a)
    if 0 <= a and a < 2*math.pi then
	return a
    end
    return a % (2*math.pi)
end

-- 範囲は -math.pi < theta < math.pi
function M.signedangle(a)
    a = M.normalangle(a)
    if a < math.pi then
        return a
    end
    return a - (2*math.pi)
end

-- 中間の角度
function M.midangle(a, b)
    a = M.normalangle(a)
    b = M.normalangle(b)
    -- a と b の角度が180 度以内の場合
    if math.abs(b - a) < math.pi then
	return (a + b) / 2
    end
    a = M.signedangle(a)
    b = M.signedangle(b)
    return M.normalangle((a + b)/2)
end

return M
