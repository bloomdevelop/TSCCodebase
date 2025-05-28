local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage:FindFirstChild('Remotes')
local RagdollBindable: BindableEvent = Remotes.RagdollNetwork

local downedPlayers = {}

local function down(player, state, duration)
	if state and downedPlayers[player] == nil then
		local t = tick()
		downedPlayers[player] = t
		RagdollBindable:Fire(player, "SetState", true)
		task.wait(duration)
		if downedPlayers[player] ~= nil and downedPlayers[player] == t then
			RagdollBindable:Fire(player, "SetState", false)
			downedPlayers[player] = nil
		end
	elseif not state then
		RagdollBindable:Fire(player, "SetState")
		downedPlayers[player] = nil
	end
end



game.ReplicatedStorage.Events.DownPlayer.Event:Connect(down)