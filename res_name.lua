-- resources の名前引きを安全に行う
--
-- res.items[id].name のように直に引くと、res に未収載の id
-- (新規実装アイテムや res の更新漏れ) で nil 参照になって落ちる。
-- ここを通せば代わりに "unknown(<id>)" が返る。

local res = require('resources')

local M = {}

local function lookup(tbl, id, key)
    if id == nil then
	return "unknown(nil)"
    end
    local e = tbl[id]
    if e == nil or e[key] == nil then
	return "unknown("..tostring(id)..")"
    end
    return e[key]
end

function M.item(id)          return lookup(res.items, id, 'name') end
function M.item_ja(id)       return lookup(res.items, id, 'ja') end
function M.key_item(id)      return lookup(res.key_items, id, 'name') end
function M.spell(id)         return lookup(res.spells, id, 'name') end
function M.weapon_skill_ja(id) return lookup(res.weapon_skills, id, 'ja') end

return M
