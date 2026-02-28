-- ベクトル操作

local M = {}

function norm(vec)
    local x = vec.x
    local y = vec.y
    local len = math.sqrt(x * x + y * y)
    return {x=x/len, y=y/len}
end

function M.CosineSimilarity(vec1, vec2)
    vec1 = norm(vec1)
    vec2 = norm(vec2)
    return vec1.x*vec2.x + vec1.y*vec2.y
end

return M
