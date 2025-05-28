local camRemote = game.ReplicatedStorage.cam605
local camSeen = game.ReplicatedStorage.seencam605
camRemote.OnClientEvent:Connect(function(pos)

	local state = false
	local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pos)
	    if not onScreen then
		state = true
		camSeen:FireServer()

		end

end)