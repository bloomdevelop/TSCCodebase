local Chat = game:GetService("Chat")
local WHM = require(game:GetService("ServerScriptService")["Hayper's Scripts"].WebhookHandler)

game:GetService("Players").PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		local Lmsg = string.lower(msg)

		if string.find(Lmsg,"owo") then
			WHM.queueMessage(string.format("%s/%s said OwO \"%s\"", plr.Name, plr.UserId, msg), "Nojustno")
		elseif string.find(Lmsg,"uwu") then
			WHM.queueMessage(string.format("%s/%s said UwU \"%s\"", plr.Name, plr.UserId, msg), "Nojustno")
		end
	end)
end)