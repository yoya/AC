--- ���̃t�@�C���� SJIS �ۑ�
--- zone �֌W

local M = {}

local utils = require 'autoutils'
local printChat = utils.printChat

local autopos = require 'autopos'
local currentPos = autopos.currentPos
local turnTo = autopos.turnTo
local lookForward = autopos.lookForward

function zone_change_handler()
    coroutine.sleep(3)
    local zone = windower.ffxi.get_info().zone
    local me_pos = autopos.currentPos()
    if me_pos == nil then
        print("failed currentPos for me_pos")
        return ;
    end
    local round_x = math.round(me_pos.x, 3)
    local round_y = math.round(me_pos.y, 3)
    local round_z = math.round(me_pos.z, 3)
    print("zone:"..zone.." x="..round_x.." y="..round_y.." z="..round_z)
---    local east_adoulin_hp_pos = {-50.5, -92, 0} �����܂Ŋ܂߂�
    local east_adoulin_hp2_pos = {-51.5, -96, 0}
---local east_adoulin_hp2_pos = {-57.8, -130, 0}
    local jeuno_garden_hp_pos = {36.0, 8.8}
    if zone == 257 then
--        print("���A�h�D�����Ȃ�")
        local dx = me_pos.x - east_adoulin_hp2_pos[1]
        local dy = me_pos.y - east_adoulin_hp2_pos[2]
        local dist = math.sqrt(dx*dx + dy+dy)
--        print("dist: "..dist)
        if dist < 10 then
            printChat("���A�h�D���� Home Point #2 (M)")
            coroutine.sleep(10)
            local me_pos2 = autopos.currentPos()
            local dx2 = me_pos.x - me_pos2.x
            local dy2 = me_pos.y - me_pos2.y
            local dist2 = math.sqrt(dx2*dx2 + dy2+dy2)
            if dist2 < 0.5 then
                turnTo({x=-58, y=-131}) --- ���O�n�E�X��
                lookForward()
                coroutine.sleep(2)
                windower.ffxi.run(true)
            else
                print("dist >= 0.5")
            end
        end   
    elseif zone == 246 then
--        printChat("�W���m��Ȃ�")
        local dx = me_pos.x - jeuno_garden_hp_pos[1]
        local dy = me_pos.y - jeuno_garden_hp_pos[2]
        local dist = math.sqrt(dx*dx + dy+dy)
        print("dist: "..dist)
        if dist < 10 then
--            printChat("�W���m�� Home Point #1 (E)")
            coroutine.sleep(2)
            turnTo({x=-54.5, y=0}) --- ���A�q���ƃV�F�~�̊�
            lookForward()
            coroutine.sleep(3)
            windower.ffxi.run(true)
        end
    --- �\�����O����(120),�U���J�o�[�h(112)
    ---  ���W���[������(51)�A�[�I�����ΎR(61)�A�J�_�[�o�̕���(79)�A�{�X�f�B��(111)�A
    --- ���A�g���X��(124), ���A���e�p(114), ���A���e�p(125)�A �o�^���A(105)
    --- �r�r�L�[�p(4)�A�}���~�A(266)
    -- �ߋ��������x���[�k�n(84)
    --- �P�C�U�b�N�Ð��(261)�A���b�Z�̎���(260), �����}�[��n(265),�����V�A�X��(263)
    --- ��U�O���B���[�N�X�̎ז�   261, 260, 265, 263, 266
--    elseif S{120, 112, 51, 61, 79, 111, 124, 114, 125, 105, 4, 84}:contains(zone) then
--        printChat("5�b��� /mount ���v�g��")
--        coroutine.sleep(5) --- 10��ok
--        windower.send_command('input /mount ���v�g��; wait 1; input /follow <p1>')
    elseif zone == 70 then
        printChat("�`���R�{�T�[�L�b�g�Ȃ�")
        coroutine.sleep(2)
---        turnToPos(-320, -475, -335.4, -473.2)
        local tx = -335.4
---        local ty = -474.5  --- 475 > x < 473.5 
        local ty = -473.5  --- 475 > x < 473.5 
        turnTo({tx, ty})
        lookForward()
        coroutine.sleep(2)
        windower.ffxi.run(tx - me_pos.x, ty - me_pos.y)
        lookForward()
    elseif zone == 142 then  --- ���O�z�g�ԓ��A��
        windower.ffxi.run(1, 0)  -- go to right
    elseif zone == 79 then  --- �J�_�[�o�̂������A�{���[�v
        windower.ffxi.run(-1, 0)  -- go to left
    elseif zone == 273 then -- �����[�̖�
        print("woh gate")
        coroutine.sleep(1)
        autopos.autoMoveTo(zone, "raive", false)
    end
end
M.zone_change_handler = zone_change_handler

function warp_handler(prevZone, prevPos, zone, pos)
    if prevPos == nil or pos == nil then
        print(prevPos, pos)
        return
    end
    print("warp_handler", prevZone, prevPos.x, prevPos.y, zone, pos.x, pos.y)
    if zone == 139 then -- �z�����[
        printChat("�z�����[�Ȃ�")
        local bcStartPos = {x=-316.3,y=-102.57}
        local dist = autopos.distance(pos, bcStartPos)
        printChat({"dist", dist})
        if dist < 10 then
            printChat("AMAN �g���[�u�J�n�ʒu")
            coroutine.sleep(2)
        end  
    end
end
M.warp_handler = warp_handler

return M
