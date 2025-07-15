local acpos = require 'pos'
local zone_change = require 'zone/change'

local M = {}

local prevPos = nil
local prevZone = nil

function incoming_handler()
    local pos = acpos.currentPos()
    local zone = windower.ffxi.get_info().zone
    if prevZone ~= zone or acpos.distance(pos, prevPos) > 100 then
        zone_change.warp_handler(zone, pos, prevZone, prevPos)
    end
    prevZone = zone
    prevPos = pos
end
M.incoming_handler = incoming_handler

return M
