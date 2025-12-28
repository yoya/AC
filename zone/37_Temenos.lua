-- テメナス

local M = { id = 37 }

M.routes = {
    ope = {
	-- x=(580,582),y=4.5
	{x=581,y=4.5,z=0.6,dx=3}, {x=583,y=62,z=0.6},
	{target="Temenos Operator"}, {a="touch"}
    }
}

M.essentialPoints = {
    entrance = {x=582,y=4.5,z=0.6},
}

M.automatic_routes = {
    entrance = { route="ope" },
}

return M
