local M = {}

M.MELEE = 1
M.AVILITY = 2
M.MAGIC = 3
M.RANGE = 4

M.pullTable = {
    [M.MELEE]   = require 'pull/melee',
    [M.ABILITY] = require 'pull/ability',
    [M.MAGIC]   = require 'pull/magic',
    [M.RANGE]   = require 'pull/range',
}

return M
