local list = require(script["13034271"])
local kickmsg = "LOL no your cringe"
local PS = game:GetService('Players')
PS.PlayerAdded:Connect(function(plr)
	if table.find(list,plr.UserId) then
		plr:Kick(kickmsg)
	end
end)