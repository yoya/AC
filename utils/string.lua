-- 文字列

M = {}

function M.split_multi(text, seps)
    local prev_start = 0
    local prev_end = 0
    local textArr = {}
    for i, s in ipairs(seps) do
	local s, e = text:find(s)
	if s == nil or e == nil then
	    return nil
	end
	if s <= prev_start or e < prev_end then
	    return nil
	end
	textArr[i] = text:sub(prev_end+1, s-1)
	prev_start = s
	prev_end = e
    end
    textArr[#textArr+1] = text:sub(prev_end + 1, text:len())
    return textArr
end

return M
