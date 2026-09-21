package.path = package.path .. ";../?.lua"
-- windower に触らない部分 (コマンド文字列の解析) だけ
local ability = require('ac/ability')

local function eq(cmd, name, target)
    local l = ability.parse_ja(cmd)
    assert(#l == 1 and l[1].name == name and l[1].target == target, cmd)
end

eq("input /ja ナイチンゲール <me>", "ナイチンゲール", "me")
eq("input /ja かばう <p1>", "かばう", "p1")
eq("input /ja B.フラリッシュ <me>", "B.フラリッシュ", "me")
eq("input /ja ランパート <me>; wait 1; input /ma ケアルIII <me>", "ランパート", "me")
assert(#ability.parse_ja("input /ma ケアルIII <me>") == 0)
assert(#ability.parse_ja("input /pet たたかえ <t>") == 0)
assert(#ability.parse_ja("input /ja ランパート <me>; wait 1; input /ja マジェスティ <me>") == 2)
print("ability_test ok")
