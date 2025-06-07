---
--- Prob
--- �m���I�ȃR�}���h���s

--- packets = require 'packets'

utils = require 'autoutils'
local merge_tables = utils.merge_tables

local M = {}

--- job = { probPermil(1/1000), recast, command, wait }

--- local SMN_summon_head = "input /pet �_�b�̋A�� <me>; wait 3; "
--- local SMN_summon_tail = "; wait 3; input /pet �_�b�̋A�� <me>"
local SMN_summon_head = ""
local SMN_summon_tail = "; wait 3; input /pet �_�b�̍U�� <t>"

--- �ʏ�̓I
---local GEO_inde = "�C���f�t���[���["
--local GEO_inde = "�C���f�w�C�X�g"
--local GEO_geo = "�W�I�t���C��"  -- �h��down
local GEO_inde2 = "�C���f�q���[���[" -- �U����up
local GEO_geo2 = "�W�I�g�[�p�[" -- ���down
--- �i��̓G
---local GEO_inde = "�C���f�v���T�C�X" --- ����up
--- �Ґ򓇂�����
local GEO_inde = "�C���f���W�F�l"
local GEO_geo = "�W�I�o���A"  -- �h��down

--- �A���o�X�p
--- local GEO_inde = "�C���f�o���A" --- �A���o�X���hup
---local GEO_geo = "�W�I�A�g�D�[��" --- �����down
---local GEO_inde = "�C���f�t�F���h" --- �A���o�X���hup
--- �J�I�X��p
--- local GEO_inde = "�C���f�t�F���h" --- �A���o�X���hup

local sendCommandProbTable = {
    WAR = {
        { 60, 300, 'input /ja �E�H�[�N���C <me>', 0 },
---        { 60, 10, 'input /ja �o�[�T�N <me>', 0 },
---        { 60, 10, 'input /ja �A�O���b�T�[ <me>', 0 },
        { 60, 10, 'input /ja �u���b�h���C�W <me>', 0 },
        { 60, 60, 'input /ja ���� <t>', 0 },
        { 60, 10, 'input /ja ���X�g�����g <me>', 0 },
        { 60, 10, 'input /ja ���^���G�[�V���� <me>', 0},
    },
    MNK = {
        { 60, 180, 'input /ja �W�� <me>', 0 },
        { 60, 180, 'input /ja �`���N�� <me>', 0 },
        { 60, 600, 'input /ja �}���g�� <me>', 0 },
        { 60, 300, 'input /ja �L������ <me>', 0 },
        { 60, 300, 'input /ja �C���s�^�X <me>', 0 },
    },
    WHM = {
--        { 100, 120, 'input /ma �f�B�A <t>', 3 },
        { 100, 120, 'input /ma �f�B�AII <t>', 3 },
--      { 100, 120, 'input /ma �X���E <t>', 3 },
--      { 100, 120, 'input /ma �p���C�Y <t>', 3 },
--        { 100, 120, 'input /ma �A�h�� <t>', 3 },
        { 50, 300-100, 'input /ma �A�f�B�f�b�N <me>', 5 },
--        { 100, 180, 'input /ma �I�[�X�s�X <me>', 1 },
        { 50, 600-300, 'input /ma �o�E�H�^�� <me>', 1 },
--       { 100, 120, 'input /ma ���W�F�lIV <p1>', 6 },
--       { 100, 120, 'input /ma ���W�F�lIV <p2>', 6 },
        { 100, 120, 'input /ma ���W�F�lIII <p1>', 6 },
--        { 100, 120, 'input /ma ���W�F�lIII <p2>', 6 },
        { 100, 120, 'input /ma �w�C�X�g <p1>', 6 },
        { 100, 120, 'input /ma �w�C�X�g <p2>', 6 },
--        { 100, 120, 'input /ma �w�C�X�g <p3>', 6 },
        { 100, 180, 'input /ja �n�[�g�I�u�\\���X <me>', 0 },
--        { 100, 600, 'input /ja ���_�̐��� <me>', 0 },
        { 10, 300, 'input /ma �����C�YIV <me>', 0 },
--        { 500, 60, 'input /ma �P�A�� <p1>', 3 },
--      { 200, 60, 'input /ma �P�A��II <p1>', 3 },
        { 10, 300-30, 'input /ma �u�����N <me>', 5},
        { 10, 300-30, 'input /ma �X�g���X�L�� <me>', 5},
--        { 100, 60, 'input /ma �o�j�V�� <t>', 3 },
--      { 100, 60, 'input /ma �o�j�V��II <t>', 3 },
--        { 100, 60, 'input /ma �o�j�V��III <t>', 3 },
--        { 100, 60, 'input /ma �z�[���[ <t>', 3 },
--        { 100, 60, 'input /ma �z�[���[II <t>', 3 },
        { 100, 600, 'input /ja �f���H�[�V���� <p2>', 0 },
    },
    BLM = {
        { 100, 10, 'input /ma �u���U�hII <t>', 2 },
        { 100, 10, 'input /ma �u���U�hIII <t>', 3 },
--      { 100, 10, 'input /ma �u���U�hIV <t>', 4 },
--      { 100, 10, 'input /ma �u���U�hV <t>', 5 },
--        { 100,10, 'input /ma �T���_�[ <t>', 2 },
        { 200,10, 'input /ma �T���_�[II <t>', 2 },
        { 400, 10, 'input /ma �T���_�[III <t>', 3 },
--      { 200, 10, 'input /ma �T���_�[IV <t>', 4 },
--        { 100, 10, 'input /ma �T���_�[V <t>', 5 },
--[[
        { 200,10, 'input /ma �o�C�I <t>', 2 },
        { 200,10, 'input /ma �h���C�� <t>', 2 },
        { 200,10, 'input /ma �X�^�� <t>', 2 },
        { 200,10, 'input /ma �X�g�[�� <t>', 2 },
        { 200,10, 'input /ma �u���U�h <t>', 2 },
]]
        { 100, 10, 'input /ma �V���b�N�X�p�C�N <me>', 5 },
     },          
    RDM = {
        { 200, 300*2, 'input /ja �R���|�[�W���[ <me>', 0 },
        { 100, 30, 'input /ma �f�B�X�y�� <t>', 3 },
        { 200, 180, 'input /ma �f�B�AIII <t>', 3 },
        { 100, 300, 'input /ma �f�B�X�g��II <t>', 4 },
        { 100, 180*3, 'input /ma �X�g���CII <me>', 4 },
        { 100, 300*3, 'input /ma �Q�C���f�b�N <me>', 4 },
        { 100, 150*3, 'input /ma ���t���V��III <me>', 4 },
        { 100, 180, 'input /ma �G���T���_�[II <me>', 4 },
--     { 100, 180, 'input /ma �G���X�g�[��II <me>', 4 },
        { 100, 180, 'input /ma �w�C�X�gII <p1>', 3 },
        { 100, 180*3, 'input /ma �w�C�X�gII <me>', 3 },
        { 5, 600-60, 'input /ma �A�N�A�x�[�� <me>', 5},
        { 5, 300-30, 'input /ma �u�����N <me>', 5},
        { 5, 300-30, 'input /ma �X�g���X�L�� <me>', 5},
    },
    THF = {
        { 10, 300, 'input /ja �ʂ��� <t>', 0 },
        { 10, 300, 'input /ja �����߂Ƃ� <t>', 0 },
        { 50, 60, 'setkey d down; wait 0.75; setkey d up; input /ja �s�ӑł� <me>; wait 1; input /ws �}���_���N�X�^�b�u <t>', 0 },
        { 50, 180, 'input /ja �t�F�C���g <me>', 0 },
        { 50, 300, 'input /ja �R���X�s���[�^�[ <me>', 0 },
        { 10, 180, 'input /ja �܂ǂ킷 <t>', 0 },
        { 50, 60, 'setkey s down; wait 0.2; setkey s up; input /ja ���܂����� <me>; wait 1; input /ws �}���_���N�X�^�b�u <t>', 0 },
    },
    PLD = {
        { 200, 60, 'input /ma �t���b�V�� <t>', 1 },
---        { 100, 60, 'input /ma �z�[���[II <t>', 2 },
        { 100, 120, 'input /ma ���A�N�g <me>', 4 },
        { 100, 120, 'input /ma �N���Z�[�h <me>', 4 },
        { 40, 60, 'input /ma �P�A��III <me>', 3 },
        { 100, 180, 'input /ja �����p�[�g <me>; wait 1; input /ja �}�W�F�X�e�B <me>; wait 1; input /ma �P�A��III <me>', 7 },
        { 100, 180-20, 'input /ma �G�����C�g <me>', 3 },
        { 100, 600-100, 'input /ja �t�B�[���e�B <me>', 0 },
        { 100, 300, 'input /ja �Z���`�l�� <me>', 0 },
        { 100, 300, 'input /ja �p���Z�[�h <me>', 0 },
        { 100, 180, 'input /ja ���΂� <p1>', 0 },
    },
    DRK = {
        { 100, 180-30, 'input /ma �G���_�[�NII <me>', 3 },
        { 100, 180, 'input /ma �h���b�h�X�p�C�N <me>', 3 },
        { 60, 120, 'input /ma �h���C��III <t>', 3 },
        { 100, 120, 'input /ma �A�u�]�[�X�g <t>', 3 },
        { 100, 120, 'input /ma �A�u�]�A�L���� <t>', 3 },
        { 100, 3000, 'input /ja ���X�g���]�[�g <me>', 0 },
        { 100, 3000, 'input /ja �f�B�A�{���N�A�C <me>', 0 },
        { 100, 180, 'input /ja �R���X�[���}�i <me>', 0 },
    },
    BST = {
        { 100, 1200, 'input /ja ���傤���イ <me>', 0 },
        { 200, 1200, 'input /pet �������� <t>', 0 },
---        { 500, 15, 'input /pet �Z���V���u���[�h <t>', 0 },
    },
    BRD = {
        { 100, 120, 'input /ma �d���R���̃~���lIV <me>', 7 },
        { 200, 60, 'input /ma �d���R���̃~���lV <me>', 7 },
        { 200, 60, 'input /ma �����m�̃}���{ <me>', 7 },
        { 200, 60, 'input /ma ���͂̃G�`���[�h <me>', 7 },
        { 200, 60, 'input /ma ��m�B�̃s�[�A��VI <me>', 7 },
--[[
        { 150, 120, 'input /ma ���G�̐i���}�[�` <me>', 7 },
        { 150, 120, 'input /ma �h���̊M���}�[�` <me>', 7 },
        { 150, 120, 'input /ma �Ҏ҂̃��k�G�b�gV <me>', 7 },
        { 50, 180, 'input /ma �Ҏ҂̃��k�G�b�gIV <me>', 7 },
        { 50, 180, 'input /ma �����̃}�h���K�� <me>', 7 },
        { 50, 180, 'input /ma ���͂̃G�`���[�h <me>', 7 },
        { 50, 180, 'input /ma ���Z�̃G�`���[�h <me>', 7 },
]]
--        { 100, 60, 'input /ma ���@�̃t�B�i�[�� <t>', 7 },
--        { 200, 120, 'input /ma �C���̃G���W�[ <t>', 7 },
--       { 200, 120, 'input /ma �����̃��N�C�G��VII <t>', 7 },
        { 200, 120, 'input /ma ���̃X���m�f�BII <t>', 7 },
    },
    SAM = {
        { 100, 180, 'input /ja �ّz <me>', 1 },
        { 200, 60-10, 'input /ja ���o <me>', 1 }, -- �U��
--        { 100, 60, 'input /ja ���� <me>', 1 }, -- �h��
        { 100, 180, 'input /ja ��`�㗘 <me>', 1 },
        { 100, 180, 'input /ja �ӑR��� <me>', 1 },
        { 100, 180, 'input /ja �ΉΔV�@ <me>', 1 },
    },
    SMN = {
        { 200, 180, 'input /pet �_�b�̉��� <me>;', 0 },
        { 200, 30, 'input /pet �_�b�̍U�� <t>;', 0 },
        { 500, 15, 'input /pet �_�b�̋A�� <me>;', 0 },
---        { 50, 1200 / 50, 'input /ma �^�C�^������ <me>; wait 7; input /pet ��n�̎�� <me>; wait 3; input /pet �_�b�̍U�� <t>;', 15 },
        { 50, 1200 / 50, SMN_summon_head .. 'input /ma �C�t���[�g���� <me>; wait 7; input /pet �g�@�̙��K <me>; wait 3; input /pet ���e�I�X�g���C�N <t>' .. SMN_summon_tail, 15 },
        { 50, 1200 / 10,  SMN_summon_head .. 'input /ma �K���[�_���� <me>; wait 7; input /pet �w�C�X�KII <me>; wait 3; input /pet �E�C���h�u���[�h <t>' .. SMN_summon_tail, 15 },
        { 50, 1200 / 20,  SMN_summon_head .. 'input /ma �V���@���� <me>; wait 7; input /pet �N���X�^���u���V���O <me>; wait 3; input /pet �w�������[�X�g���C�N <t>' .. SMN_summon_tail, 15 },
        { 50, 1200 / 20,  SMN_summon_head .. 'input /ma �t�F���������� <me>; wait 7; input /pet �㌷�̚X�� <me>; wait 3; input /pet �C���p�N�g <t>' .. SMN_summon_tail, 15 },
        { 5, 1200 / 10,  SMN_summon_head .. 'input /ma �P�b�g�E�V�[���� <me>; wait 7; input /pet �����C�YII <me>' .. SMN_summon_tail, 15 },
        { 1, 1200 / 10,  SMN_summon_head .. 'input /ma �P�b�g�E�V�[���� <me>; wait 7; input /pet �����C�YII <p1>' .. SMN_summon_tail, 15 },
        { 1, 1200 / 10,  SMN_summon_head .. 'input /ma �P�b�g�E�V�[���� <me>; wait 7; input /pet �����C�YII <p2>' .. SMN_summon_tail, 15 },
        { 10, 300 / 2,  SMN_summon_head .. 'input /ma �����쏢�� <me>; wait 7; input /ja �G�������g�T�C�t�H�� <me>' .. SMN_summon_tail, 15 },
    },
    BLU = {
        { 100, 90, 'input /ma �R�N�[�� <me>', 3 },
        { 100, 60, 'input /ma �V���J�[�h���� <t>', 4 },
        { 50, 60, 'input /ma ���₵�̕� <me>', 6 },
---     { 50, 300, 'input /ma �G���`�b�N�t���b�^�[ <me>', 3 },
    },
    COR = {
---            { 200, 60, 'input /ja �R���Z�A�Y���[�� <me>; wait 2; input /ja �_�u���A�b�v <me>', 0 },
            { 50, 300-30, 'input /ja �u���b�c�@���[�� <me>', 1 },
            { 100, 60, 'input /ja �T�����C���[��  <me>', 1 },
            { 100, 60, 'input /ja �J�I�X���[��  <me>', 1 },
            { 100, 60, 'input /ja �t�@�C�^�[�Y���[��  <me>', 1 },
---         { 100, 60, 'input /ja ���K�X�Y���[��  <me>', 1 },
---            { 100, 60, 'input /ja �E�B�U�[�Y���[��  <me>', 1 },
--[[
            { 100, 60, 'input /ja �K�����c���[�� <me>', 1 },
            { 100, 60, 'input /ja �_���T�[���[�� <me>', 1 },
            { 100, 60, 'input /ja �_���T�[���[�� <me>', 1 },
]]
    },
    PUP = {
        { 100, 1200, 'input /ja �A�N�e�B�x�[�g <me>', 0 },
        { 100, 60, 'input /ja ���}���u <me>', 0 },
        { 500, 60, 'input /pet �f�B�v���C <t>', 0 },
        { 200, 300, 'input /ja �N�[���_�E�� <me>', 0 },
        { 200, 90, 'input /pet �t�@�C�A�}�j���[�o <me>', 0 },
        { 100, 90, 'input /pet ���C�g�}�j���[�o <me>', 0 },
    },
    DNC = {
--     {50, 300-30, 'input /ja ���̕��� <me>', 0 },
        {50, 300-30, 'input /ja ��̕��� <me>', 0 },
        {50, 90-10, 'input /ja �w�C�X�g�T���o <me>', 0 },
        {50, 90-10, 'input /ja �h���C���T���oII <me>', 0 },
        {100, 60, 'input /ja B.�t�����b�V�� <me>', 0 },
        {100, 90, 'input /ja C.�t�����b�V�� <me>', 0 },
        {100, 90, 'input /ja S.�t�����b�V�� <me>', 0 },
        {100, 90, 'input /ja T.�t�����b�V�� <me>', 0 },
        {100, 30, 'input /ja �N�C�b�N�X�e�b�v <t>', 0 },
        {100, 30, 'input /ja �{�b�N�X�X�e�b�v <t>', 0 },
    },
    SCH = {
        { 100, 3600/36, 'input /ja ���̃O�����A <me>', 0 },
        { 100, 3600/36, 'input /ja ���̕�� <me>', 0 },
        { 100, 300/2, 'input /ja ���_�~�Ղ̏� <me>; wait 1; input /ma �X�g���X�L�� <me>', 8 },
        { 100, 120, 'input /ja ���_�~�Ղ̏� <me>; wait 1; input /ma ���W�F�lV <me>', 8 },
        { 100, 120, 'input /ma ���W�F�lV <p1>', 5 },
        { 100, 120, 'input /ma �����痢�̍� <p1>', 5 },
        { 100, 120, 'input /ma �Ò����̍� <p2>', 5 },
        { 100, 120, 'input /ma �ە�����̍� <p1>', 5 },
        { 100, 120, 'input /ma �ە�����̍� <p2>', 5 },
        { 50, 120, 'input /ja ���㉉�K <me>', 0 },
---        { 100, 30, 'input /ma �T���_�[II <t>', 2},
---        { 200, 30, 'input /ma �T���_�[III <t>', 3},
---        { 100, 120-30, 'input /ma �w�C�X�g <p1>', 4 },
---     { 100, 120-30, 'input /ma �w�C�X�g <p2>', 4 },
    },
    RUN = { 
        { 50, 60, 'input /ja �r�x�C�V���X <me>', 0 },
        { 100, 30, 'input /ja �X���|�[�� <me>', 0 },
        { 100, 60, 'input /ja ���@���G���X <me>', 0 },
        { 50, 300, 'input /ja �\\�[�h�v���C <me>', 0 },
        { 50, 300, 'input /ja �o�b�g�D�^ <me>', 0 },
        { 10, 300, 'input /ja �����t�H�A�I�[�� <me>', 0 },
        { 50, 60, 'input /ma ���W�F�lIV <me>', 5},
        { 50, 120, 'input /ma �t�@�����N�X <me>', 4},
        { 50, 120, 'input /ma �t�H�C�� <me>', 4},
        { 50, 300, 'input /ma �N���Z�[�h <me>', 4},
        { 100, 30, 'input /ma �t���b�V�� <t>', 1},
    },
    GEO = {
        { 100, 120, 'input /ma �P�A�� <p1>', 3 },
        { 100, 120, 'input /ma �w�C�X�g <p2>', 3 },
        { 100, 30, 'input /ma �T���_�[ <t>', 3},
--[[
        { 100, 30, 'input /ma �T���_�[II <t>', 3},
        { 100, 30, 'input /ma �T���_�[III <t>', 3},
        { 100, 30, 'input /ma �T���_�[IV <t>', 4},
]]
--        { 100, 30, 'input /ma �u���U�hII <t>', 3},
--        { 100, 30, 'input /ma �u���U�hIII <t>', 3},
--        { 100, 30, 'input /ma �u���U�hIV <t>', 4},
    },
    GEO_1 = {
        { 150, 300/3, 'input /ma '..GEO_geo..' <t>; wait 1; input /ja �T�[�N���G�����b�` <me>', 6 },
        { 250, 20, 'input /ma '..GEO_geo..' <t>', 6 },
--        { 50, 600/2, 'input /ja �O���[���[�u���C�Y <me>; wait 1; input /ja �t���T�[�N�� <me>; wait 1; input /ma '..GEO_geo..' <t>', 12  },
        { 150, 180-30, 'input /ma '..GEO_inde..' <me>', 4 },
        { 10, 600, 'input /ja �G���g���X�g <me>; wait 2; input /ma �C���f�f�b�N <p2>', 6 },
        { 10, 300, 'input /ja �����h�n���C�V���� <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
        { 10, 300, 'input /ja ���C�f�B�A���A���J�i <me>; wait 2; input /ma '..GEO_geo..' <t>', 7 },
    },
    GEO_2 = {
        { 150, 300/3, 'input /ma '..GEO_geo2..' <t>; wait 1; input /ja �T�[�N���G�����b�` <me>', 6 },
        { 250, 20, 'input /ma '..GEO_geo2..' <t>', 6 },
--        { 50, 600/2, 'input /ja �O���[���[�u���C�Y <me>; wait 1; input /ja �t���T�[�N�� <me>; wait 1; input /ma '..GEO_geo2..' <t>', 12  },
        { 150, 180-30, 'input /ma '..GEO_inde2..' <me>', 4 },
        { 10, 600, 'input /ja �G���g���X�g <me>; wait 2; input /ma �C���f�X�g <p2>', 6 },
        { 10, 300, 'input /ja �����h�n���C�V���� <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
        { 10, 300, 'input /ja ���C�f�B�A���A���J�i <me>; wait 2; input /ma '..GEO_geo2..' <t>', 7 },
    },
    ALL = {
---     { 200, 900, 'input /item �L���p�V�e�B�����O <me>', 1 },
    },
}

-- �T�u�W���u�p
local sendCommandProbTableSub = {
    WAR = {
        { 60, 300, 'input /ja �E�H�[�N���C <me>', 1 },
        { 60, 60, 'input /ja ���� <t>', 1 },
        { 100, 300, 'input /ja �o�[�T�N <me>', 0 },
        { 100, 300, 'input /ja �A�O���b�T�[ <me>', 0 },
    },
    MNK = {
        { 100, 120, 'input /ja �W�� <me>', 0 },
    },
    WHN = {
        { 5, 600-60, 'input /ma �A�N�A�x�[�� <me>', 5},
        { 5, 300-30, 'input /ma �u�����N <me>', 5},
        { 5, 300-30, 'input /ma �X�g���X�L�� <me>', 5},
        { 100, 120-30, 'input /ma �w�C�X�g <p1>', 4 },
    },
    BLM = {
---        { 100, 30, 'input /ma �T���_�[II <t>', 2},
---        { 200, 30, 'input /ma �t���X�g <t>', 3},
    },
    RDM = {
--        { 5, 600-60, 'input /ma �A�N�A�x�[�� <me>', 5},
        { 5, 300-30, 'input /ma �u�����N <me>', 5},
        { 5, 300-30, 'input /ma �X�g���X�L�� <me>', 5},
        { 100, 300-30, 'input /ma ���t���V�� <me>', 5},
--        { 250, 120, 'input /ma �f�B�AII <t>', 4 },
--        { 100, 120, 'input /ma �f�B�X�g�� <t>', 4 },
--        { 100, 120, 'input /ma �t���Y�� <t>', 4 },
--        { 50, 300, 'input /ja �R���o�[�g <me>', 1 },
--        { 100, 120-30, 'input /ma �w�C�X�g <p1>', 4 },
--        { 100, 120-30, 'input /ma �w�C�X�g <p2>', 4 },
--        { 100, 120-30, 'input /ma �w�C�X�g <p3>', 4 },
    },
    SAM = {
        { 60, 180, 'input /ja �ّz <me>', 1 },
        { 200, 60-10, 'input /ja ���o <me>', 1 }, -- �U��
--        { 60, 60, 'input /ja ���� <me>', 1 }, -- �h��
        { 100, 180, 'input /ja �ΉΔV�@ <me>', 1 },
    },
    BLU = {
        { 100, 60, 'input /ma �R�N�[�� <me>', 5 },
        { 100, 60, 'input /ma �K�C�X�g�E�H�[�� <me>', 5 },
        { 100, 60, 'input /ma ���₵�̕� <me>', 5 },
        { 100, 60, 'input /ma �V�[�v�\\���O <me>', 5 },
    },
    COR = {
---        { 100, 60, 'input /ja �R���Z�A�Y���[�� <me>;'' wait 2; /ja �_�u���A�b�v <me>', 1 },
        { 100, 60, 'input /ja �R���Z�A�Y���[�� <me>', 1 },
---        { 100, 60, 'input /ja �T�����C���[��  <me>', 1 },
---     { 100, 60, 'input /ja �J�I�X���[��  <me>', 1 },
---     { 100, 60, 'input /ja �t�@�C�^�[�Y���[��  <me>', 1 },
    },
}

M.getSendCommandProbTable = function(mainJob, subJob, rankInJob)
    local merged = {}
    for job, commprob in pairs(sendCommandProbTable) do
        if job == mainJob or job == mainJob..'_'..rankInJob or job == "ALL" then
            merged = merge_tables(merged, commprob)
        end
    end
    for job, commprob in pairs(sendCommandProbTableSub) do
        if job == subJob or job == "ALL" then
            merged = merge_tables(merged, commprob)
        end
    end
    return merged
end 

M.sendCommandProb = function(table, period, ProbRecastTime)
    ---    print("sendCommandProb")
    local rnd = math.random(1, 1000)
    local pp = 0
    local pn = 0
    for i, p_c in ipairs(table) do
        local p = p_c[1]  --- probability
        local r = p_c[2]  --- recast time
        local c = p_c[3]  --- command
        local t = p_c[4]  --- time
---        print(p, r, c, t)
        pn = pp + p*period   
        if ProbRecastTime[c] == nil then
            if pp < rnd and rnd <= pn then
                ProbRecastTime[c] = r
                windower.ffxi.run(false)
                coroutine.sleep(0.25)
                windower.send_command(c)
                if t > 0 then
                    coroutine.sleep(t)
                end
                return true
            end
            pp = pn
        else
            local remain =  ProbRecastTime[c] - period
            if remain > 0 then
                ProbRecastTime[c] = remain
            else
                ProbRecastTime[c] = nil
            end
        end
    end
    return false
end

return M

