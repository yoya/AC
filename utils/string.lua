-- 文字列

local M = {}

-- https://gist.github.com/ram-nadella/dd067dfeb3c798299e8d
function M.trim(text)
    return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end

function M.split_multi(text, seps)
    local prev_start = 0
    local prev_end = 0
    local text_arr = {}
    for i, sep in ipairs(seps) do
	local s, e = text:find(sep)
	if s == nil or e == nil then
	    return nil
	end
	if s <= prev_start or e < prev_end then
	    return nil
	end
	text_arr[i] = text:sub(prev_end+1, s-1)
	prev_start = s
	prev_end = e
    end
    text_arr[#text_arr+1] = text:sub(prev_end + 1, text:len())
    return text_arr
end

function M.gil_string(gil, sep, digit)
    if sep == nil then
	sep = ','
    end
    if digit == nil then
	digit = 3
    end
    local gil_str = tostring(gil)
    local gil_str2 = ''
    local n = string.len(gil_str)
    for i = 1, n do
	gil_str2 = gil_str2 .. string.sub(gil_str,i, i)
	if (n-i)%digit == 0 and i ~= n then
	    gil_str2 = gil_str2 .. sep
	end
    end
    return gil_str2
end

-- 標準 string.format は nil を受け取るとエラー終了するので、その対策。
-- io/chat.printf は pcall で凌いでいるが、こちらは nil を "(nil)" に
-- 置き換えて渡すので、どの引数が nil だったかが出力に残る
function M.format(f, ...)
    local n = select('#', ...)
    local args = {...}
    for i = 1, n do
	if args[i] == nil then
	    args[i] = "(nil)"
	end
    end
    return string.format(f, unpack(args, 1, n))
end

return M
