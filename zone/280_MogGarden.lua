-- モグガーデン

local M = { id = 280 }

M.origContents = nil
function M.zone_in()
    local contents = require 'contents'
    M.origContents = contents.type
    contents.setType(contents.Garden)  -- モグガーデン
end

function M.zone_out()
    local contents = require 'contents'
    if M.origContents ~= nil then
	contents.setType(M.origContents)
    end
end

M.routes = {
    mogsale = {
	{x=2.5,y=-5.1,z=0.2}, {x=1,y=-2,z=-0.2},
	{target="Green Thumb Moogle"}, {auto=true},
	{target_lockon=false}  -- タゲロックは外す
    }
}

M.essentialPoints = {
    -- x=(-2.5,2.5???),y=-5.1,z={0.2,0.5}
    from_moghouse = {x=0,y=-5.1,z=0.2,dx=3},
    furrow = {x=5.1,y=2.0,z=0.1}, -- 畑
}

M.automatic_routes = {
    from_moghouse = { route="mogsale"},
}

return M
