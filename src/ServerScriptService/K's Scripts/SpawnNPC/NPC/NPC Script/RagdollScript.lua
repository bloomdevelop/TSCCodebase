local function ragdoll(wrapper, model) -- runs in a coroutine
	local Humanoid = model:FindFirstChild("Humanoid")
	game:GetService("CollectionService"):AddTag(model,"Ragdolled")
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("Motor6D") then
			local a0, a1 = Instance.new("Attachment",v.Part0), Instance.new("Attachment",v.Part1)
			a0.Name = "TemporaryAttachment"
			a1.Name = "TemporaryAttachment"
			a0.CFrame = v.C0
			a1.CFrame = v.C1
			local b = Instance.new("BallSocketConstraint")
			b.Attachment0 = a0
			b.Attachment1 = a1
			b.Parent = v.Part0
			v.Enabled = false
		end
	end
	
	Humanoid.PlatformStand = true
	-- return a function that continues this function, and waits until it is called
	coroutine.yield(wrapper)

	-- unragdoll by readding the Motor6Ds
	-- if there were no Motor6Ds, then this does nothing
	-- because the restore* tables would have nothing in them
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("Motor6D") then 
			v.Enabled = true
		elseif v:IsA("BallSocketConstraint") or v.Name == "TemporaryAttachment" then
			v:Destroy()
		end
	end
	Humanoid.PlatformStand = false
	game:GetService("CollectionService"):RemoveTag(model,"Ragdolled")
end

return function(model)
	local wrapper = coroutine.wrap(ragdoll)
	return wrapper(wrapper, model)
end