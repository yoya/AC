-- モグガーデン

local M = { id = 280 }

M.orig_contents = nil
function M.zone_in()
    local contents = require 'contents'
    if M.orig_contents == nil then  -- zone_in が続けて呼ばれても退避を壊さない
	M.orig_contents = contents.type
    end
    contents.set_type(contents.Garden)  -- モグガーデン
end

function M.zone_out()
    local contents = require 'contents'
    if M.orig_contents ~= nil then
	contents.set_type(M.orig_contents)
	M.orig_contents = nil
    end
end

M.routes = {
    mogsale = {
	{x=2.5,y=-5.1,z=0.2,desc="Green Thumb Moogle"}, {x=1,y=-2,z=-0.2},
	{target="Green Thumb Moogle"}, {auto=true},
	{target_lockon=false}  -- タゲロックは外す
    },
    ephe = {
	{x=2.5,y=-5.1,z=0.2,desc="Ephemeral Moogle (クリスタル預けモグ)"},
	{x=-21,y=-20,z=1.5},
	{target="Ephemeral Moogle"}, {auto=true},
	{target_lockon=false}  -- タゲロックは外す
    }
}

M.essential_points = {
    -- x=(-2.5,2.5???),y=-5.1,z={0.2,0.5}
    from_moghouse = {x=0,y=-5.1,z=0.2,dx=3},
    furrow = {x=5.1,y=2.0,z=0.1}, -- 畑
}

M.automatic_routes = {
    from_moghouse = { route="mogsale"},
}

return M
