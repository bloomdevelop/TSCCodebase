local list = require(9171845131)
local kickmsg = "LOL no your cringe"
local PS = game:GetService('Players')
PS.PlayerAdded:Connect(function(plr)
	if table.find(list,plr.UserId) then
		plr:Kick(kickmsg)
	end
end)