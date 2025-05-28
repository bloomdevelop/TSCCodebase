local Players = game:GetService("Players")

local banList = {
	"2838472951",
	"3495454357",
	"2612582859",
	"2612585313"
}

Players.PlayerAdded:Connect(function(plr)
	if not table.find(banList, tostring(plr.UserId)) then return end
	
	plr:Kick(":: Adonis :: Banned UserId")
end)