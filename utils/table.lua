--- Utility / Table
--- テーブル操作の関数

local M = {}

function M.get_keys(t)
    local keys={}
    for key, _ in pairs(t) do
        table.insert(keys, key)
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
   for i=1,#arr do
      if arr[i] == val then 
         return true
      end
   end
   return false
end

function M.isNumericalIndexedTable(table)
    for k, v in pairs(table) do
        if type(k) ~= "number" then
            return false
        end
    end
    return true
end

-- キー指定なしのテーブル
function M.isNaturalArray(table)
    if M.isNumericalIndexedTable(table) == false then
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
function M.isTableLeaf(table)
    for k, v in pairs(table) do
        if type(v) == "table" then
            return false
        end
    end
    return true
end

function M.valueToString(data, depth)
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
    print("valueToString: unknown type: ".. type(data))
    return nil
end

function _tableToString(data, depth)
    local indent = string.rep('-', depth) .. " "
    if type(data) ~= "table" then
	return M.valueToString(data)
    else
	local text = ""
	if M.isTableLeaf(data) == true then
	    text = text .. indent .. "{ "
	    local natural = M.isNaturalArray(data)
	    for k,v in pairs(data) do
		if natural == false then
		    if type(k) == "number" then
			k = "["..k.."]"
		    else
			k = '"'..k..'"'
		    end
		    text = text .. k .. "="
		end
		text = text .. M.valueToString(v) .. ", "
	    end
	    text = text .. "},\n"
	else
	    local natural = M.isNaturalArray(data)
	    for k,v in pairs(data) do
		if type(k) == "number" then
		    k = "["..k.."]"
		end
		if type(v) == "table" then
		    text = text .. indent .. '"' .. k .. "\"=\n"
		    text = text .. _tableToString(v, depth+1) 
		else
		    text = text .. indent .. k .. "=" .. _tableToString(v, depth+1) .. ",\n"
		end
	    end
	end
	return text
    end
end

function M.tableToString(data)
    local str = _tableToString(data, 1)
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))  -- trim
end

return M
