local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local RANGE = 5
local COOLDOWN = 11

local PARemote = ReplicatedStorage:WaitForChild("PAEvent")

local onCooldown

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if onCooldown then return end
		if not player.Character then return end
		if not player.Character:FindFirstChild("HumanoidRootPart") then return end

		local PASystems = workspace.PASystems:GetChildren()		

		local selected_pa: Model
		for _, pa in ipairs(PASystems) do
			if not pa:IsA("Model") then continue end
			if not pa.PrimaryPart then continue end
			if player:DistanceFromCharacter(pa.PrimaryPart.Position) > RANGE then continue end
			selected_pa = pa
		end

		if not selected_pa then return end

		local success, filteredMessage: TextFilterResult = pcall(function()
			return TextService:FilterStringAsync(message, player.UserId)
		end)

		if not success then return end

		onCooldown = true

		for _, pa in ipairs(PASystems) do
			pa.PAmodel.DumbLightScriptIgnore.BrickColor = BrickColor.new("Terra Cotta")
		end

		(selected_pa :: any).PApart.Pickup:Play();
		(selected_pa :: any).PApart.Talkie:Play();
		task.wait(0.2)

		for _, pl: Player in ipairs(Players:GetPlayers()) do
			local success, messageToSend = pcall(function()
				return filteredMessage:GetChatForUserAsync(pl.UserId)
			end)

			if not success then continue end

			PARemote:FireClient(pl, player, messageToSend)
		end

		task.delay(COOLDOWN, function()
			onCooldown = nil

			for _, pa in ipairs(PASystems) do
				pa.PAmodel.DumbLightScriptIgnore.BrickColor = BrickColor.new("Ghost grey")
			end
		end)
	end)
end)
