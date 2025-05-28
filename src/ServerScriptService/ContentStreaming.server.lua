local rst = game:GetService("ReplicatedStorage")
local RunService = game:GetService('RunService')

local remotesFolder = rst:WaitForChild("Remotes")
local contentStreamingRemotes = remotesFolder:WaitForChild("ContentStreaming")

local requestStreamAroundEvent = contentStreamingRemotes:WaitForChild("RequestStreamAround")
local requestReplicationFocusChangeEvent = contentStreamingRemotes:WaitForChild("RequestReplicationFocusChange")

local Cooldown = {}

requestStreamAroundEvent.OnServerEvent:Connect(function(player : Player, position : Vector3)
	Cooldown[player] = (Cooldown[player] ~= nil) and Cooldown[player] + 1 or 1
	if Cooldown[player] > 10 then
		-- player:Kick("\n\nUnexpected Client Behaviour [1006]\n\nToo many requests.")
		
		-- This triggers a false positive when a player is rapidly switching teams in the menu. ~Steven
		return
	elseif Cooldown[player] > 5 then
		return
	end
	player:RequestStreamAroundAsync(position)
	requestStreamAroundEvent:FireClient(player)
end)

requestReplicationFocusChangeEvent.OnServerEvent:Connect(function(player : Player, replicationFocus : any)
	Cooldown[player] = (Cooldown[player] ~= nil) and Cooldown[player] + 1 or 1
	if Cooldown[player] > 5 then
		return
	end
	
	player.ReplicationFocus = replicationFocus
end)

-- COOLDOWN HANDLING
local currentBeat = 0
RunService.Heartbeat:Connect(function(dt)
	if currentBeat < 5 then
		currentBeat = 0
		for p, i in next, Cooldown do
			if i > 0 then
				Cooldown[p] -= 1
			end
		end
	else
		currentBeat += dt
	end
end)