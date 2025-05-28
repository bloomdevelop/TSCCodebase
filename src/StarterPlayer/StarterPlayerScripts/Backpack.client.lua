game:GetService("ReplicatedStorage").Remotes.Backpack.OnClientEvent:Connect(function(value)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,value)
end)