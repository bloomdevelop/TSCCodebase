local tool = script.Parent

local plr = game.Players.LocalPlayer

local animations = {}

local equippedOnce = false
local raised = false

tool.Equipped:Connect(function()
	if equippedOnce == false then
		local char = plr.Character
		if char then
			equippedOnce = true
			local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
			
			for i,animation in pairs(tool.Animations:GetChildren()) do
				animations[animation.Name] = animator:LoadAnimation(animation)
			end
		end
	end
	
	animations.Idle:Play()
end)

tool.Unequipped:Connect(function()
	animations.Idle:Stop()
	
	if raised == true then
		raised = false 
		animations.Raised:Stop(.15)
	end
end)

tool.Activated:Connect(function()
	raised = not raised
	
	if raised == true then
		animations.Raised:Play(.15)
	else
		animations.Raised:Stop(.15)
	end
end)