-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local HayperScript = ServerScriptService:WaitForChild("Hayper's Scripts")
local WebhookHandler = require(HayperScript:WaitForChild("WebhookHandler"))

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	
	service.Events.CommandRan:Connect(function(plr, data)
		if RunService:IsStudio() then return end
		--if plr.Team.Name == "Facility Personnel" then
		--	plr.Team = Teams:FindFirstChild('Off Duty')
		--end
		local Level = server.Admin.LevelToListName(data.PlayerData.Level)
		WebhookHandler.queueMessage(string.format("%s/%s (%s) > %s", plr.Name, plr.UserId, Level or "Guest", data.Message))
	end)
end