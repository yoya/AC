--- ���̃t�@�C���� SJIS �ۑ�
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
    'victory', 'shishin', 'tokon', 'dragon', 'tackle',-- �i��
    'manda', 'exen', 'rudra', 'evis',  'dance', 'shadow', -- �Z��
    'savage', 'chant', -- �Ў茕
    'reso','ground', -- ���茕
    'rui', 'ramp', -- �Ў蕀
    'ukko', 'steel',  --���蕀
    'dai',  -- ���葄
    'demi', 'spin', 'ent', 'frost', -- ���茕
    'shoha', 'hocho', 'gekko', 'kagero', 'yuki', -- ���蓁
    'shun', -- �Ў蓁
    'moon', 'realm', 'hexa', 'shine', 'circle', -- �Ў螞
    'myrkr', 'spirit', 'full', 'heavy', -- ���螞
    'spiral', 'cross', -- ���芙
    'apex', -- �|
    'leaden', 'hot', 'wild' -- �ˌ�(�e)
}

ws.weaponskillTable = {
    -- �i��
    tackle = '�^�b�N��',
    shishin = '�l�_�~��',
    victory = '�r�N�g���[�X�}�C�g',
    tokon = '���������r',
    dragon = '�h���S���u���E',
    -- �Z��
    manda = '�}���_���N�X�^�b�u',
    rudra = '���h���X�g�[��',
    dance = '�_���V���O�G�b�W',
    shadow = '�V���h�[�X�e�b�`',
    evis = '�G���B�T���[�V����',
    wasp = '���X�v�X�e�B���O',
    energy = '�G�i�W�[�h���C��',
    aeolian = '�C�I���A���G�b�W',
    exen = '�G�N�[���e���^�[',
    -- �Ў茕
    chant = '�V�����f���V�j��',
    savage = '�T�x�b�W�u���[�h',
    flat = '�t���b�g�u���[�h',
    circle = '�T�[�N���u���[�h',
    -- ���茕
    demi = '�f�~�f�B�G�[�V����',
    spin = '�X�s���X���b�V��',    
    reso = '���]���[�V����',
    ground = '�O���E���h�X�g���C�N',
    frost = '�t���X�g�o�C�g',
    -- �Ў蕀
    rui = '���C�l�[�^�[',
    ramp = '�����y�[�W',
    -- ���蕀
    ukko = '�E�b�R�t���[���[',
    steel = '�X�`�[���T�C�N����',
    -- ���葄
    dai = '��ԗ�',
    -- ���芙
    ent = '�G���g���s�[',
    -- ���蓁
    kagero = '�l�V�����E�z��', -- �n��
    yuki = '���V�����E�ᕗ', -- �d���A�y��
    gekko = '���V�����E����', -- �ђʁA�Ռ�
    hocho = '�\\��V�����E�P��', -- �h��̓_�E��
    shoha = '�\\��V�����E�Ɣj', --�@�h��̓J�b�g�B�i��ɋ���
    -- �Ў蓁
    shun = '�u',
    -- �Ў螞
    shine = '�V���C���X�g���C�N',
    realm = '���������C�U�[',
    moon = '���[�����C�g',
    full = '�t���X�C���O',
    hexa = '�w�L�T�X�g���C�N',
    -- ���螞
    myrkr = '�~���L��',
    spirit = '�X�s���b�g�e�[�J�[',
    cata = '�J�^�N���X��',
    brain = '�u���C���V�F�C�J�[',
    heavy = '�w���B�X�C���O',
    -- ���芙
    spiral = '�X�p�C�����w��',
    cross = '�N���X���[�p�[',
    -- �|
    apex = '�G�C�y�N�X�A���[',
    -- �ˌ�(�e)
    leaden = '���f���T�����[�g',
    hot = '�z�b�g�V���b�g',
    wild = '���C���h�t�@�C�A',
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
--    if mob.hpp < math.random(30, 33) and -- �Ґ򓇂�����
    if mob.hpp < math.random(3,5) and -- �E�H�[APEX������
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
