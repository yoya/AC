local acpos = require 'pos'
local aczone = require 'zone'

local M = {}

local prevPos = nil
local prevZone = nil

function incoming_handler()
    local pos = acpos.currentPos()
    local zone = windower.ffxi.get_info().zone
    if prevPos == nil or pos == nil then
        return
    end
    if prevZone ~= zone or acpos.distance(pos, prevPos) > 100 then
        print("incoming_handler", currentPos, prevPos)
        aczone.warp_handler(prevZone, prevPos, zone, pos)
    end
    prevZone = zone
    prevPos = pos
end
M.incoming_handler = incoming_handler

return M
