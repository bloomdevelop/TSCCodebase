for _,armour in pairs(script.Parent:GetChildren())do
	if armour:IsA("Accessory") and armour:FindFirstChild("Armour") then
		armour.Health.Value = armour:FindFirstChild("MaxHealth") and armour.MaxHealth.Value or 5
		armour.Handle.Transparency -= 1
		if armour.Handle:FindFirstChild("DisabledOnGunHit") then
			armour.Handle.DisabledOnGunHit.Name = "OnGunHit"
		end
		for _,part in pairs(armour.Handle:GetChildren())do
			if part:IsA("BasePart") then
				part.Transparency -= 1
			end
		end
	end
end