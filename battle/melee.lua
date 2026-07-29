local M = {}

local utils = require 'utils'
local control = require 'control'
local command = require 'command'

local io_chat = require 'io/chat'
local io_net = require 'io/net'

local acinspect = require 'inspect'
local actask = require 'task'

local acmob = require 'mob'
local get_mob_position = acmob.get_mob_position

-- 敵から離れているか。M.tick 内の return で true のまま次の tick へ持ち越す
local is_far = false

local acprob = require 'prob'
local send_command_prob = acprob.send_command_prob
local get_send_command_prob_table = acprob.get_send_command_prob_table

local ac_move = require 'ac/move'
local turn_to_target = ac_move.turn_to_target

local ac_party = require 'ac/party'
local iam_leader = ac_party.iam_leader

local pull = require 'pull'
local ws = require 'ws'
local pstatus = require 'player_status'

M.so_long_to_get_fight_count = 0
--- 戦闘中。リーダー、メンバー共通。
function M.tick(player, me, mob)
    -- print("battle/melee.tick")
    local mob = windower.ffxi.get_mob_by_target("t")
    -- 戦闘モードだけどタゲが外れる(稀に発生)
    -- もしくは殴れる距離なのに敵が赤字に変わらない
    if mob == nil or (mob.distance < (mob.model_scale * 1.5) and mob.status == pstatus.IDLE) then
	if control.debug then
	    io_chat.printf("M.so_long_to_get_fight_count:%d/7",
			   M.so_long_to_get_fight_count)
	end
	if M.so_long_to_get_fight_count < 7 then
	    M.so_long_to_get_fight_count = M.so_long_to_get_fight_count  + 1
	else
	    command.send('input /attack off')  -- 一旦諦める
	    io_chat.noticef("M.so_long_to_get_fight_count:%d/7",
			    M.so_long_to_get_fight_count)
	    M.so_long_to_get_fight_count = 0
	end
	return
    end
    M.so_long_to_get_fight_count = 0
    local player = windower.ffxi.get_player()
    local main_job = player.main_job
    local sub_job = player.sub_job
---    print("XXX", preferred_enemy_list)
    -- 中断してでも優先する敵
    local condition = {
	range = control.enemy_range,
	prefer_mobs = acmob.more_attractive_enemy_list,
	name_match = control.enemy_filter,
    }
    local prefer_mob = acmob.search_nearest_mob(pull.base_pos, condition)
    ---    print("prefereMob", prefer_mob)
    if not utils.table.contains(acmob.more_attractive_enemy_list, mob.name) and prefer_mob ~= nil and mob.name ~= prefer_mob.name then
	--        print("prefer_mob:", mob.name)
        if iam_leader() then
            io_net.target_by_mob(prefer_mob)
            coroutine.sleep(1)
            command.send('input /attack <t>')
        else
            --- リーダー(p1)が戦闘している敵に切り替える
            command.send('input /assist <p1>')
        end
    end
 ---   if not player or not player.target_index then
 ---       return
 ---   end
    --- サポ白はPLなので、ずっとインビジ
    local sub_job = player.sub_job
    if false and sub_job == "WHM" then
        if math.random(1, 100) <= 1 then
---            command.send('input /ma インビジ <me>')
---            coroutine.sleep(2)
        end
        return 
    end
    local enemy_pos = {}
    local me_pos = {}
    get_mob_position(enemy_pos, "t")
    get_mob_position(me_pos, "me")
    --- 戦闘してない？
    if enemy_pos.x == nil then
        print("if enemy_pos.x == nil")
        return
    end
    local dx = enemy_pos.x - me_pos.x
    local dy = enemy_pos.y - me_pos.y
    local dist =  math.sqrt(dx*dx + dy*dy)
    local enemy_space = 1
    if control.enemy_space == control.ENEMY_SPACE_NEAR then
	enemy_space = 2
    elseif control.enemy_space ==  control.ENEMY_SPACE_MAGIC then
	enemy_space = 4
    elseif control.enemy_space ==  control.ENEMY_SPACE_MANUAL then
	enemy_space = 99999
    end
    if iam_leader() then
	if dist > enemy_space then
	    is_far = true
	end
    end
    if is_far then
        --　戦闘中でないときは、WSやMAを自粛。フェイスが動かないので。
        if dist / mob.model_size > enemy_space or player.status == pstatus.IDLE then
            windower.ffxi.run(dx, dy)
            -- 向きが悪くて戦闘が開始しない問題への対策
            -- command.send('setkey numpad5 down; wait 0.05; setkey numpad5 up')
            return
        elseif not control.calm then
	    send_command_prob({
                { 150, 0, 'setkey a down; wait 0.05; setkey a up', 0 }, -- 左
                { 150, 0, 'setkey d down; wait 0.05; setkey d up', 0 }, -- 右
                { 150, 0, 'setkey a down; wait 0.1; setkey a up', 0 }, 
                { 150, 0, 'setkey d down; wait 0.1; setkey d up', 0 },
                { 200, 0, 'setkey a down; wait 0.15; setkey a up', 0 },
                { 200, 0, 'setkey d down; wait 0.15; setkey d up', 0 },
                { 200, 0, 'setkey a down; wait 0.2; setkey a up', 0 },
                { 200, 0, 'setkey d down; wait 0.2; setkey d up', 0 },
                { 300, 0, 'setkey a down; wait 0.25; setkey a up', 0 },
                { 300, 0, 'setkey d down; wait 0.25; setkey d up', 0 },
                { 500, 0, 'setkey s down; wait 0.01; setkey s up', 0 }, -- 後ろ
         }, 1.0, acprob.prob_recast_time)
	    --- 一回だけなので 1 を入れる。
	else
	    windower.ffxi.run(false)
        end
    end
    --- 止まって戦闘開始
    is_far = false
    windower.ffxi.run(false)
    --- atan2 のままだと右を向くので、90度の補正
--    local dir = math.atan2(dx, dy) - 3.14/2
--    windower.ffxi.turn(dir)
    turn_to_target("t")
---    if player.vitals.tp >= math.random(1100, 1200) then
    --- PLD はタゲ取り.RNG はエヴィ用。"BLM", "SMN", "SCH"はミルキル
    -- local tp100_jobs = {-"RNG", "BLM", "SMN", "SCH"}
    local tp100_jobs = {}
    --- WAR はスチサイ用。DNC はダンス用？
    local tp_jobs = {"DNC"}
--    local tp_min = 1200
--    local tp_max = 1500
    local tp_min = 2000
    local tp_max = 2500
    if utils.table.contains(tp100_jobs, player.main_job) then
        tp_min = 1050
        tp_max = 1150
    elseif utils.table.contains(tp_jobs, player.main_job) then
        tp_min = 2000
        tp_max = 2300
    end
    local ws_request = false
    local now = os.time()
    -- 連携になるよう 3秒あける。MB を邪魔しないよう 連携から 10秒あける。
    if player.vitals.tp >= 1000 and
	(acinspect.ws_time + 2) < now and (acinspect.sc_time + 10) < now then
	ws_request = true
    end
    if player.vitals.tp >= 2000 and
	(acinspect.ws_time + 1) < now and (acinspect.sc_time + 10) < now then
	-- TP:2000 超えは少しピーキーにする。
	ws_request = true
    end
--    if player.vitals.tp >= 2500 and (acinspect.sc_time + 10) < now then
	-- print("(now - sc_time):"..(now - acinspect.sc_time), acinspect.sc_time)
--	ws_request = true
--    end
    -- ドメインベーションはTP1000即撃ち
    if player.vitals.tp >= 1000 and utils.table.contains(acmob.domain_enemy_list, mob.name) then
	ws_request = true
    end
    if control.wstp ~= nil and control.wstp ~= -1 and control.wstp <= player.vitals.tp then
	ws_request = true
    end
    if ws_request == true then
	local params = { level = actask.PRIORITY_HIGH}
	actask.set_task_ex("//ws exec", params)
	return
    else
        if player.item_level > 99 then
            local commprob = get_send_command_prob_table(main_job, sub_job, 1)
--            io_chat.print(commprob)
            --send_command_prob(commprob, settings.Period, acprob.prob_recast_time)
	    send_command_prob(commprob, control.period, acprob.prob_recast_time)
        end
    end
---    if math.random(1, 100) <= 1 then
    --- 戦闘ターゲットがたまに外れる対策。とりあえずの方法。
    if iam_leader() or control.puller then
        if math.random(1, 10) <= 1 then
            command.send('input /attack <t>')
        end
    end
    --- たまに左や右にずれる。前や後にも。
    if not control.calm then
	send_command_prob({
		{ 10, 10, 'setkey a down; wait 0.1; setkey a up', 0 }, -- left
		{ 10, 10, 'setkey d down; wait 0.1; setkey d up', 0 }, -- right
		{ 20, 10, 'setkey w down; wait 0.1; setkey w up', 0 }, -- forward
		{ 20, 10, 'setkey s down; wait 0.1; setkey s up', 0 }, -- back
			}, control.period, acprob.prob_recast_time)
    end
    if control.point_cheer then  --- アンバス：マンドラ
        send_command_prob({
            { 200, 1, 'input /point <t>', 1 },
            { 100, 1, 'input /cheer <p1>', 1 },
            { 100, 1, 'input /cheer <p2>', 1 },
            { 100, 1, 'input /clap <p1>', 1 },
            { 100, 1, 'input /clap <p2>', 1 },
        }, control.period, acprob.prob_recast_time)
    end  
end

return M
