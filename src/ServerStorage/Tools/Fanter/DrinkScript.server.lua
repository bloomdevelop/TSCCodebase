local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local equipped = false
local cooldown = false

local DrinkAnimation = Instance.new("Animation")
DrinkAnimation.AnimationId = "rbxassetid://7807528525"

Tool.Activated:Connect(function()
	if not equipped or cooldown then return end
	cooldown = true

	local Track:AnimationTrack = Tool.Parent:WaitForChild("Humanoid"):LoadAnimation(DrinkAnimation)
	Track:Play()
	Handle:WaitForChild("DrinkSound"):Play()
	Track.Stopped:Wait()

	cooldown = false
end)

Tool.Equipped:Connect(function()
	equipped = true
	Handle:WaitForChild("OpenSound"):Play()
end)

Tool.Unequipped:Connect(function()
	equipped = false
end)