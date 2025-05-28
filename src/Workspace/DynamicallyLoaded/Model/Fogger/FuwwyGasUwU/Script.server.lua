part = script.Parent
local infectedCheckModule = require(game.ReplicatedStorage.InfectedCheckModule)

part.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if player and not infectedCheckModule(player) and not character:FindFirstChild('FullImmunity') then
		local dmg = 10
		
		if character:FindFirstChild('SemiImmunity') ~= nil then
			dmg *= 0.5
		elseif character:FindFirstChild('Immunity') ~= nil then
			dmg *= 0.2
		end
		
		if 0 >= dmg then return end
		
		character.Infectionmet.Value += dmg
		character.Color.Value = part.Color
		if part:FindFirstChild("Type") then
			character.Type.Value = part.Type.Value
		end
	end
end)