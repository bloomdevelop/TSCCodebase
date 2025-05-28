function Intialize(character)
	for i, child in pairs(script:GetChildren()) do
		if child.className == "Script" or child.className == "LocalScript" then
			local c = child:Clone()
			c.Parent = character
			c.Disabled = false
		end
	end
end

function Apply(obj)
	if obj.className == "Humanoid" then -- Bunnies targeted
		Intialize(obj.Parent)
	end
	for i, child in pairs(obj:GetChildren()) do
		Apply(child)
	end
end

Apply(workspace)
workspace.ChildAdded:connect(Apply)

-- Hello, it's Valkeron. Here's a script to stop the bunnies from getting their carrots.