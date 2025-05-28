local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DownPlayer = ReplicatedStorage.Events.DownPlayer
local FaintPart = script.Parent

FaintPart.Touched:Connect(function(hit)
	local Character = FaintPart.Parent
	DownPlayer:Fire(player,true,15)
end)
