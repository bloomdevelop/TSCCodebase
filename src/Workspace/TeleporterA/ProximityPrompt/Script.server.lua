local TeleporterB = workspace.TeleporterB
local ProximityPrompt = script.Parent
local Bindables = game.ServerStorage.Bindables

ProximityPrompt.Triggered:Connect(function(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	Bindables.Anticheat.AuthorizeTeleport:Fire(player, TeleporterB.CFrame)
end)