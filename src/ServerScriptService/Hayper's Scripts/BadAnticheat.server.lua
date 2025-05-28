local WebhookHandler = require(script.Parent:WaitForChild("WebhookHandler"))

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

RunService.Stepped:Connect(function(t, dt)
	for _,plr in next, Players:GetPlayers() do
		if not plr.Character then continue end
		
		if not plr.Character:FindFirstChild("Torso") then continue end
		if not plr.Character:FindFirstChild("HumanoidRootPart") then continue end

		--if not plr.Character:FindFirstChild("HumanoidRootPart") then
		--	local logStr = string.format("%s doesn't have... HumanoidRootPart..?", plr.Name)
		--	warn(logStr)

		--	--plr:Kick(":: Adonis :: Adonis_10043")

		--	WebhookHandler.queueMessage(logStr, "Button")
		--else
		if plr.Character.HumanoidRootPart.Position.Y > 1000 then
			local pos = plr.Character.HumanoidRootPart.Position

			local logStr = string.format("%s tries to set their HumanoidRootPart's Y Position to %s", plr.Name, pos.Y)
			warn(logStr)

			plr.Character.HumanoidRootPart.Position = Vector3.new(pos.X, -math.abs(pos.Y), pos.Z)

			--plr:Kick(":: Adonis :: Adonis_10043")
			WebhookHandler.queueMessage(logStr, "Button")
		end

		if plr.Character.Torso.Position.Y > 1000 then
			local pos = plr.Character.Torso.Position

			local logStr = string.format("%s tries to set their Torso's Y Position to %s", plr.Name, pos.Y)
			warn(logStr)

			plr.Character.Torso.Position = Vector3.new(pos.X, -math.abs(pos.Y), pos.Z)

			--plr:Kick(":: Adonis :: Adonis_10043")
			WebhookHandler.queueMessage(logStr, "Button")
			continue
		end
	end
end)