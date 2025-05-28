local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local RunService = game:GetService("RunService")
local Players = game:GetService('Players')

Players.PlayerAdded:Connect(function(p)
	if game.PrivateServerId == "" or game.PrivateServerOwnerId ~= 0 then return end --Not reserved server

	local TeleportData = p:GetJoinData().TeleportData or {}
	if not TeleportData.fromUpdate then return end -- Not here because update

	local UI = ReplicatedStorage.SUpdateUI:Clone()
	UI.DisplayOrder = 2147483647
	UI.Parent = p.PlayerGui

	task.wait(15) -- Give roblox some time to update
	repeat
		TeleportService:Teleport(game.PlaceId, p, nil, ReplicatedStorage.SUpdateUI:Clone())
		task.wait(1)
	until not game.Players:FindFirstChild(p.Name)
end)

function shutdown()
	if RunService:IsStudio() then return end

	for _, p in next, Players:GetPlayers() :: {[number]: Player} do
		local UI = ReplicatedStorage.UpdateUI:Clone()
		UI.Enable.Disabled = false
		UI.Parent = p.PlayerGui
	end

	task.wait(1)

	if game.PrivateServerId ~= "" then
		local kickMessage = "\nGame updated\n- - - -\nCannot connect to new server"
		for _, p: Player in next, Players:GetPlayers() do
			p:Kick(kickMessage)
		end

		Players.PlayerAdded:Connect(function(p)
			p:Kick(kickMessage)
		end)
	else
		local reservedCode = TeleportService:ReserveServer(game.PlaceId)

		local function teleport(p: Player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedCode, {p}, nil, {fromUpdate = true}, ReplicatedStorage.SUpdateUI:Clone())
		end

		task.spawn(function()
			repeat
				for _, p in next, Players:GetPlayers() :: {[number]: Player} do
					teleport(p)
				end
				task.wait(1)
			until #Players:GetPlayers() == 0
		end)

		Players.PlayerAdded:Connect(function(p)
			teleport(p)
		end)
	end
end

game:BindToClose(shutdown)
--ReplicatedStorage.StartShutdown.OnInvoke = shutdown