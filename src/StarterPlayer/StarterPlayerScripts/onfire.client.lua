game.ReplicatedStorage.ssos.OnClientEvent:Connect(function(plr, sound)
	if plr ~= game.Players.LocalPlayer then
		sound:Play()
		sound.Ended:Wait()
	end
end)