
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DataStore2 = require(Modules.DataStore2)
DataStore2.Combine("DATA", "Credits")
Players.PlayerAdded:Connect(function(player: Player)
	local CreditDatastore = DataStore2("Credits", player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local CreditValue = Instance.new("IntValue")
	CreditValue.Name = "Cash" -- Why
	CreditValue.Value = CreditDatastore:Get(0)
	CreditValue.Parent = leaderstats

	leaderstats.Parent = player

	local function updateCredit(data)
		ReplicatedStorage:WaitForChild("Remotes").UpdateCredits:FireClient(player, data)
	end

	CreditValue:GetPropertyChangedSignal("Value"):Connect(function()
		CreditDatastore:Set(CreditValue.Value)
	end)

	updateCredit({CreditValue.Value, true})
	CreditDatastore:OnUpdate(updateCredit)

	task.spawn(function() -- Passive Income
		while task.wait(40) do
			if player.Parent == nil then break end -- Player left, We quit
			CreditValue.Value += 10
		end
	end)

	task.spawn(function() -- Autosave
		while task.wait(60) do
			if player.Parent == nil then break end -- Player left, We quit
			CreditDatastore:Save()
		end
	end)
end)