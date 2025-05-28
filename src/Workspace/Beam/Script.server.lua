function onCollide(part) 
	local humanoid = part.Parent:FindFirstChild("Humanoid") 
	if (humanoid ~= nil) then	-- if a humanoid exists, then
		humanoid.Health = 0	-- damage the humanoid
	else
		local model = part:FindFirstAncestorWhichIsA("Model")
		if model then
			if model:FindFirstChild("Humanoid") then
				model:FindFirstChild("Humanoid").Health = 0
			end
		end
	end 
end

script.Parent.Touched:connect(onCollide)
