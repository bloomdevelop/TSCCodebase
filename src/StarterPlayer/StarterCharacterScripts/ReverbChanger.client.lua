local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
overlapParams = OverlapParams.new() 
overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
overlapParams.FilterDescendantsInstances = {character}
overlapParams.MaxParts = 1

local soundfieldsfolder = game.Workspace.SoundFields
for i,v in pairs(soundfieldsfolder:GetDescendants()) do
	if v:IsA("Part") then v.CFrame = Vector3.new(0,-2000,0)
	end
end



while character and character.Parent ~= nil do
	local reverb = "Hallway"
	for i,hitbox in pairs(workspace.SoundFields:GetChildren())do

		local intersecting = workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size,overlapParams)
		if #intersecting > 0 then
			reverb = hitbox.Name
			break
		end
	end
	game.SoundService.AmbientReverb = Enum.ReverbType[reverb]
	wait(1)
end