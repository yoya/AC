local autopos = require 'autopos'
local autozone = require 'autozone'

local M = {}

local prevPos = nil
local prevZone = nil

function incoming_handler()
    local pos = autopos.currentPos()
    local zone = windower.ffxi.get_info().zone
    if prevPos == nil or pos == nil then
        return
    end
    if prevZone ~= zone or autopos.distance(pos, prevPos) > 100 then
        print("incoming_handler", currentPos, prevPos)
        autozone.warp_handler(prevZone, prevPos, zone, pos)
    end
    prevZone = zone
    prevPos = pos
end
M.incoming_handler = incoming_handler

return M
