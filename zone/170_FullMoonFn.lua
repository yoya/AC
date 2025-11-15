-- 満月の泉

local M = { id = 170 }

M.routes = {
    circle = {
	{x=-259,y=-325.7,z=4.1},{x=-261,y=-312}, {x=-258,y=-300,d=1},
	{x=-258,y=-286,d=1}, {x=-261,y=-273}, {x=-272,y=-263},
	{x=-292,y=-260,z=12}, {x=-300,y=-260,z=9.5}, {a="f8touch"}
    },
    fenrir = {
	{x=383.1,y=-420,z=47.5}, {x=352,y=-419}, {x=344,y=-408},
	{x=340,y=-396}, {x=340,y=-377,z=48},
    },
}

M.essentialPoints = {
    entrance = {x=-259,y=-325.7,z=4.1},
    bc_in = {x=383.1,y=-420,z=47.5},
}

M.automatic_routes = {
    entrance = { route="circle" },
    bc_in = { route="fenrir" },
}

return M
