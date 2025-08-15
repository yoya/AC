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

function M.gil_string(gil)
    local gil_str = tostring(gil)
    local gil_str2 = ''
    local n = string.len(gil_str)
    for i = 1, n do
	gil_str2 = gil_str2 .. string.sub(gil_str,i, i)
	if (n-i)%3 == 0 and i ~= n then
	    gil_str2 = gil_str2 .. ','
	end
    end
    return gil_str2
end

return M
