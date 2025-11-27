-- weapon skill

require('functions')
local res = require 'resources'
local utils = require 'utils'
local get_keys = utils.table.get_keys
local command = require 'command'
local io_chat = require 'io/chat'

local M = {}

M.weaponskill = 'flat'

local preferWeaponSkill = {
    'dragon', 'victory', 'asyura', 'shishin', 'tokon', 'rangeki', 'combo', -- 格闘
    'evis', 'rudra', 'manda', 'exen',  'dance', 'shadow', -- 短剣
    'savage', 'chant', 'requ', -- 片手剣
    'reso','ground', -- 両手剣
    'rui', 'ramp', -- 片手斧
    'ukko', 'steel', 'uph', 'shield', --両手斧
    'dai',  -- 両手槍
    'demi', 'spin', 'frost', -- 両手剣
    'jin', 'ten', -- 片手等
    'kasha', 'shoha', 'hocho', 'gekko', 'kagero', 'yuki', -- 両手刀
    'shun', -- 片手刀
    'moon', 'realm', 'hexa', 'shine', 'circle', -- 片手棍
    'myrkr', 'spirit', 'full', 'heavy', -- 両手棍
    'spiral', 'cross', 'ent', -- 両手鎌
    'apex', -- 弓
    'leaden', 'hot', 'wild' -- 射撃(銃)
}

M.weaponskillTable = {
    -- 格闘
    -- tackle = 'タックル',
    combo = 'コンボ',
    rangeki = '乱撃',
    shishin = '四神円舞',
    victory = 'ビクトリースマイト',
    tokon = '闘魂旋風脚',
    dragon = 'ドラゴンブロウ',
    asyura = '夢想阿修羅拳',
    -- 短剣
    evis = 'エヴィサレーション',
    manda = 'マンダリクスタッブ',
    rudra = 'ルドラストーム',
    dance = 'ダンシングエッジ',
    shadow = 'シャドーステッチ',
    wasp = 'ワスプスティング',
    energy = 'エナジードレイン',
    aeolian = 'イオリアンエッジ',
    exen = 'エクゼンテレター',
    -- 片手剣
    requ = 'レクイエスカット',
    savage = 'サベッジブレード',
    chant = 'シャンデュシニュ',
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
    shield = 'シールドブレイク',
    ukko = 'ウッコフューリー',
    steel = 'スチールサイクロン',
    uph = 'アップヒーバル',
    -- 両手槍
    dai = '大車輪',
    -- 両手鎌
    spiral = 'スパイラルヘル',
    cross = 'クロスリーパー',
    ent = 'エントロピー',
    -- 片手刀
    jin = '迅',
    ten = '天',
    -- 両手刀
    kasha = '九之太刀・花車', -- 核熱
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
    -- 弓
    apex = 'エイペクスアロー',
    -- 射撃(銃)
    leaden = 'レデンサリュート',
    hot = 'ホットショット',
    wild = 'ワイルドファイア',
}

M.weaponskillTargetMeTable = {
    "myrkr", "moon",
}

M.getWeaponSkillUsage = function()
    local abilities = windower.ffxi.get_abilities()
    -- local weaponSkillUsage = table.concat(get_keys(M.weaponskillTable), " | ") .. "\n"
    local weaponSkillUsage = "  "
    for key, name in pairs(M.weaponskillTable) do
        for key2, name2 in pairs(abilities.weapon_skills) do
            local n = res.weapon_skills[name2]['ja']
            if name == n then
                entry =  key .. " = " .. name
                weaponSkillUsage = weaponSkillUsage .. entry .. "\n"
            end
        end
    end
    return weaponSkillUsage
end

M.getAnyWeaponSkill = function()
    local abilities = windower.ffxi.get_abilities()
    for k_, k in pairs(preferWeaponSkill) do
        v = M.weaponskillTable[k]
        for k2, v2 in pairs(abilities.weapon_skills) do
            name = res.weapon_skills[v2]['ja']
            if name == v then
                return k
            end
        end
    end
    return nil
end

M.exec = function()
    if M.weaponskill == nil then
        return
    end        
    local mob = windower.ffxi.get_mob_by_target("t")
    if mob == nil or mob.distance/mob.model_size > 12 then
        return
    end
    local player = windower.ffxi.get_player()
--    print(player.vitals.tp)
--    if mob.hpp < math.random(30, 33) and -- 醴泉島かえる
    --    if mob.hpp < math.random(3,5) and -- ウォーAPEXかえる
    --[[
    if mob.hpp < math.random(2,3) and -- ウォーAPEXかえる
        player.vitals.tp < 3000 then
        return
	end
    ]]
    wsname = M.weaponskillTable[M.weaponskill]
    local target = "<t>"
    if utils.table.contains(M.weaponskillTargetMeTable, M.weaponskill) then
        target = "<me>"
    end
    windower.ffxi.run(false)
    command.send('input /ws ' .. wsname .. ' ' .. target)
    coroutine.sleep(1)
end

M.init = function()
    M.weaponskill = M.getAnyWeaponSkill()
    if M.weaponskill ~= nil then
	io_chat.print('set any ' .. M.weaponskill .. ' => ' .. M.weaponskillTable[M.weaponskill])
    end
end

return M
