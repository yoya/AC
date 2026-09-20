-- 連携(SkillChain)役。主に前衛

local M = {
    role_ws_1 = false,
    role_ws_2 = false,
    time_ws_1 = 0,
    time_ws_2 = 0,
}

local command = require 'command'
local asinspect = require 'inspect'

function M.setRoleWS1(b)
    M.role_ws_1 = b
end

function M.setRoleWS2(b)
    M.role_ws_2 = b
end

function M.getTimeWS1()
    return M.time_ws_1
end

function M.haveRoleWS1(b)
    return M.role_ws_1
end

function M.haveRoleWS2(b)
    return M.role_ws_2
end

return M
