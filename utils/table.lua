--- Utility / Table
--- テーブル操作の関数

local M = {}

function M.count_keys(t)
    local count = 0
    for key, _ in pairs(t) do
	count = count + 1
    end
    return count
end

function M.get_keys(t)
    local keys={}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

-- key と value を逆にする
function M.swap_key_value_table(t)
    local keys={}
    for key, value in pairs(t) do
	keys[value] = key
    end
    return keys
end

function M.array_reverse(arr)
    rev = {}
    for i=#arr, 1, -1 do
        rev[#rev+1] = arr[i]
    end
    return rev
end

function M.merge_lists(t1, t2)
    if type(t1) ~= "table" then print(debug.traceback()) end
    local merged = {}
    for _, v in ipairs(t1) do
        table.insert(merged, v)
    end
    for _, v in ipairs(t2) do
        table.insert(merged, v)
    end
    return merged
end

function M.merge_tables(t1, t2)
    local merged = {}
    for k, v in pairs(t1) do
        merged[k] = v
    end
    for k, v in pairs(t2) do
        merged[k] = v
    end
    return merged
end

function M.contains(arr, val)
    if arr == nil then print(debug.traceback()) end
    for i=1,#arr do
	if arr[i] == val then
	    return true
	end
    end
    return false
end

function M.contains_substr(arr, text)
    for i=1,#arr do
	if string.find(arr[i], text) ~= nil then
	    return true
	end
    end
    return false
end

function M.is_numerical_indexed_table(table)
    for k, v in pairs(table) do
        if type(k) ~= "number" then
            return false
        end
    end
    return true
end

-- キー指定なしのテーブル
function M.is_natural_array(table)
    if M.is_numerical_indexed_table(table) == false then
	return false -- 必要ないかも？
    end
    local i = 1
    for k, v in pairs(table) do
	if k ~= i then
            return false
        end
	i = i + 1
    end
    return true
end

-- 末端のテーブルなら true
function M.is_table_leaf(table)
    for k, v in pairs(table) do
        if type(v) == "table" then
            return false
        end
    end
    return true
end

function M.value_to_string(data, depth)
    if data == nil then
	return "(nil)"
    elseif type(data) == "string" then
	return data
    elseif type(data) == "number" then
	-- return indent .. math.round(data, 2)
	local n = math.floor(data * 100 + 0.5) / 100;
	return n
    elseif type(data) == "boolean" then
	local b = data and "true" or "false"
	return b
    end
    print("value_to_string: unknown type: ".. type(data))
    return nil
end

function _table_to_string(data, depth)
    local indent = string.rep('-', depth) .. " "
    if type(data) ~= "table" then
	return M.value_to_string(data)
    else
	local text = ""
	if M.is_table_leaf(data) == true then
	    text = text .. indent .. "{ "
	    local natural = M.is_natural_array(data)
	    for k,v in pairs(data) do
		if natural == false then
		    if type(k) == "number" then
			k = "["..k.."]"
		    else
			k = '"'..k..'"'
		    end
		    text = text .. k .. "="
		end
		text = text .. M.value_to_string(v) .. ", "
	    end
	    text = text .. "},\n"
	else
	    local natural = M.is_natural_array(data)
	    for k,v in pairs(data) do
		if type(k) == "number" then
		    k = "["..k.."]"
		end
		if type(v) == "table" then
		    text = text .. indent .. '"' .. k .. "\"=\n"
		    text = text .. _table_to_string(v, depth+1) 
		else
		    text = text .. indent .. k .. "=" .. _table_to_string(v, depth+1) .. ",\n"
		end
	    end
	end
	return text
    end
end

function M.table_to_string(data)
    local str = _table_to_string(data, 1)
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))  -- trim
end

function M.convert_array_to_set(arr)
    local t = {}
    for i, v in ipairs(arr) do
	t[v] = true
    end
    return t
end

function M.assign_values(to, from)
    assert(type(to) == 'table')
    assert(type(from) == 'table')
    for k, v in pairs(from) do
	if type(v) ~= 'table' then
	    to[k] = v
	else
	    M.assign_values(to[k], v)
	end

    end
end
    
function M.deepclone(obj)
    if type(obj) ~= 'table' then
	return obj
    end
    local tbl = {}
    for k, v in pairs(obj) do
	tbl[k] = M.deepclone(v)
    end
    return tbl
end

return M
