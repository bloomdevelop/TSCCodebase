local runService = game:GetService('RunService')

local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

runService.Heartbeat:Connect(function()
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.PlatformStand = true
	humanoid:UnequipTools()
end)