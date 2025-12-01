-- コロロカの洞門

local M = { id = 173 }

M.routes = {
    -- from_Zeruhn
    junction = {  -- はじめの分岐点
	{x=461.1,y=160.6,z=-40.1}, {x=449,y=177}, {x=406,y=182},
	{x=390,y=177}, {x=383,y=168}, {x=379,y=153}, {x=369,y=143},
	{x=346,y=139}, {x=340,y=132,d=0.5}, {x=338,y=112}, {x=313,y=100},
    },
    stala = {  -- Stalagmite
	{r="junction"},
	{x=313,y=100}, {x=276,y=100}, {x=252,y=89},
	{x=167,y=83}, {x=81,y=76}, {x=53,y=75},
    }
    
}

M.essentialPoints = {
    from_Zeruhn = {x=461.1,y=160.6,z=-40.1}
}

M.automatic_routes = {
    from_Zeruhn = { route="junction" },  -- はじめの分岐点
}

return M
