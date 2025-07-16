local acpos = require 'pos'
local zone_change = require 'zone/change'

local M = {}

local prevPos = nil
local prevZone = nil

function incoming_handler()
    local pos = acpos.currentPos()
    local zone = windower.ffxi.get_info().zone
    local prevZone2 = prevZone
    local prevPos2 = prevPos
    prevZone = zone
    prevPos = pos
    if prevPos2 ~= nil and prevZone2 ~= nil then
	if prevZone2 ~= zone or acpos.distance(pos, prevPos2) > 100 then
	    zone_change.warp_handler(zone, pos, prevZone2, prevPos2)
	end
    end
end
M.incoming_handler = incoming_handler

return M
