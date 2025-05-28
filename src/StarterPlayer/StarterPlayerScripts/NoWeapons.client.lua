local PlayersService = game:GetService('Players')

local player = PlayersService.LocalPlayer

function characterAdded(character: Model)
	local humanoid = character:FindFirstChildOfClass('Humanoid')
	if not humanoid then return end
	humanoid = humanoid :: Humanoid
	
	character.ChildAdded:Connect(function(inst: Instance)
		if not inst:IsA('Tool') or not character:GetAttribute('Ragdoll') or humanoid == nil then return end
		humanoid:UnequipTools()
	end)
end

player.CharacterAdded:Connect(characterAdded)

if player.Character then characterAdded(player.Character) end