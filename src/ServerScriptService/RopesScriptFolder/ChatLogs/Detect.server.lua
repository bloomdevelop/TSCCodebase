local TS = game:GetService('TextService')
local WHM = require(script.Parent.WebhookModule)

game.Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		local v1
		local v2
		local success, errorMessage = pcall(function()
			v1 = TS:FilterStringAsync(msg,plr.UserId)
			v2 = v1:GetNonChatStringForBroadcastAsync()
		end)
		if success then
			WHM.Request(plr.Name,plr.UserId,v2)
		elseif errorMessage then
			--print("Error filtering message:", errorMessage)
		end
	end)
end)