part = script.Parent

part.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and not hit.Parent:FindFirstChild('FullImmunity') and hit.Parent:FindFirstChild("Infected") and hit.Parent:FindFirstChild("Color") and hit.Parent:FindFirstChild("Infectionmet") and hit.Parent:FindFirstChild("Infected").Value == false then
		local dmg = 10

		if hit.Parent:FindFirstChild('SemiImmunity') ~= nil then
			dmg *= 0.5
		elseif hit.Parent:FindFirstChild('Immunity') ~= nil then
			dmg *= 0.2
		end
		
		if 0 >= dmg then return end
		
		hit.Parent:FindFirstChild("Infectionmet").Value += dmg
		hit.Parent:FindFirstChild("Color").Value = part.Color
	end
end)