--- このファイルは SJIS 保存
---
--- weapon skill
---

require('functions')
res = require 'resources'
utils = require 'autoutils'
local get_keys = utils.get_keys

--- local weaponskill = 'mandalic'
--- local weaponskill = 'energy'

local ws = {}

ws.weaponskill = 'flat'


local preferWeaponSkill = {
    'victory', 'shishin', 'tokon', 'dragon', 'tackle',-- 格闘
    'manda', 'exen', 'rudra', 'evis',  'dance', 'shadow', -- 短剣
    'savage', 'chant', -- 片手剣
    'reso','ground', -- 両手剣
    'rui', 'ramp', -- 片手斧
    'ukko', 'steel',  --両手斧
    'dai',  -- 両手槍
    'demi', 'spin', 'ent', 'frost', -- 両手剣
    'shoha', 'hocho', 'gekko', 'kagero', 'yuki', -- 両手刀
    'shun', -- 片手刀
    'moon', 'realm', 'hexa', 'shine', 'circle', -- 片手棍
    'myrkr', 'spirit', 'full', 'heavy', -- 両手棍
    'spiral', 'cross', -- 両手鎌
    'apex', -- 弓
    'leaden', 'hot', 'wild' -- 射撃(銃)
}

ws.weaponskillTable = {
    -- 格闘
    tackle = 'タックル',
    shishin = '四神円舞',
    victory = 'ビクトリースマイト',
    tokon = '闘魂旋風脚',
    dragon = 'ドラゴンブロウ',
    -- 短剣
    manda = 'マンダリクスタッブ',
    rudra = 'ルドラストーム',
    dance = 'ダンシングエッジ',
    shadow = 'シャドーステッチ',
    evis = 'エヴィサレーション',
    wasp = 'ワスプスティング',
    energy = 'エナジードレイン',
    aeolian = 'イオリアンエッジ',
    exen = 'エクゼンテレター',
    -- 片手剣
    chant = 'シャンデュシニュ',
    savage = 'サベッジブレード',
    flat = 'フラットブレード',
    circle = 'サークルブレード',
    -- 両手剣
    demi = 'デミディエーション',
    spin = 'スピンスラッシュ',    
    reso = 'レゾルーション',
    ground = 'グラウンドストライク',
    frost = 'フロストバイト',
    -- 片手斧
    rui = 'ルイネーター',
    ramp = 'ランページ',
    -- 両手斧
    ukko = 'ウッコフューリー',
    steel = 'スチールサイクロン',
    -- 両手槍
    dai = '大車輪',
    -- 両手鎌
    ent = 'エントロピー',
    -- 両手刀
    kagero = '四之太刀・陽炎', -- 溶解
    yuki = '七之太刀・雪風', -- 硬化、炸裂
    gekko = '八之太刀・月光', -- 貫通、衝撃
    hocho = '十\一之太刀・鳳蝶', -- 防御力ダウン
    shoha = '十\二之太刀・照破', --　防御力カット。格上に強い
    -- 片手刀
    shun = '瞬',
    -- 片手棍
    shine = 'シャインストライク',
    realm = 'レルムレイザー',
    moon = 'ムーンライト',
    full = 'フルスイング',
    hexa = 'ヘキサストライク',
    -- 両手棍
    myrkr = 'ミルキル',
    spirit = 'スピリットテーカー',
    cata = 'カタクリスム',
    brain = 'ブレインシェイカー',
    heavy = 'ヘヴィスイング',
    -- 両手鎌
    spiral = 'スパイラルヘル',
    cross = 'クロスリーパー',
    -- 弓
    apex = 'エイペクスアロー',
    -- 射撃(銃)
    leaden = 'レデンサリュート',
    hot = 'ホットショット',
    wild = 'ワイルドファイア',
}

ws.weaponskillTargetMeTable = S{
    "myrkr", "moon",
}

ws.getWeaponSkillUsage = function()
    local abilities = windower.ffxi.get_abilities()
    -- local weaponSkillUsage = table.concat(get_keys(ws.weaponskillTable), " | ") .. "\n"
    local weaponSkillUsage = "  "
    for key, name in pairs(ws.weaponskillTable) do
        for key2, name2 in pairs(abilities.weapon_skills) do
            local n = windower.to_shift_jis(res.weapon_skills[name2]['ja'])
            if name == n then
                entry =  key .. " = " .. name -- windower.to_shift_jis(name)
                weaponSkillUsage = weaponSkillUsage .. entry .. "\n"
            end
        end
    end
    return weaponSkillUsage
end

ws.getAnyWeaponSkill = function()
    local abilities = windower.ffxi.get_abilities()
    for k_, k in pairs(preferWeaponSkill) do
        v = ws.weaponskillTable[k]
        for k2, v2 in pairs(abilities.weapon_skills) do
            name = windower.to_shift_jis(res.weapon_skills[v2]['ja'])
            if name == v then
                return k
            end
        end
    end
    return nil
end

ws.exec = function()
    if ws.weaponskill == nil then
        return
    end        
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil or mob.distance/mob.model_size > 10 then
        return
    end
    local player = windower.ffxi.get_player()
--    print(player.vitals.tp)
--    if mob.hpp < math.random(30, 33) and -- 醴泉島かえる
    if mob.hpp < math.random(3,5) and -- ウォーAPEXかえる
        player.vitals.tp < 3000 then
        return
    end
    wsname = ws.weaponskillTable[ws.weaponskill]
    local target = "<t>"
    if ws.weaponskillTargetMeTable:contains(ws.weaponskill) then
        target = "<me>"
    end
    windower.ffxi.run(false)
    windower.send_command('input /ws ' .. wsname .. ' ' .. target)
end

ws.init = function()
    ws.weaponskill = ws.getAnyWeaponSkill()
    if ws.weaponskill ~= nil then
        windower.add_to_chat(17, 'set any ' .. ws.weaponskill .. ' => ' .. ws.weaponskillTable[ws.weaponskill])
    end
end

return ws
