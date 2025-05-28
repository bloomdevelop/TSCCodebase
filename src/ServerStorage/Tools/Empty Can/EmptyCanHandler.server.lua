local tool = script.Parent
local handle = tool.Handle

local holdAnim = tool:WaitForChild("HoldAnim")
local char
local anim

local db = false

tool.Activated:Connect(function()
	if db == false then
		db = true
		local c = handle:Clone()
		handle.Mesh.Transparency = 1
		c.CanCollide = true
		c.Parent = game.Workspace

		c:ApplyImpulse(c.CFrame.LookVector * 20)
		c.Fire:Play()
		c.CleanUp.Disabled = false
		wait(6)
		handle.Mesh.Transparency = 0
		db = false
	end
end)

tool.Equipped:Connect(function()
	char = tool.Parent
	if char:FindFirstChild("Humanoid") then
		anim = char.Humanoid:LoadAnimation(holdAnim)
		anim:Play()
	end
end)

tool.Unequipped:Connect(function()
	if anim then
		anim:Stop()
	end
end)