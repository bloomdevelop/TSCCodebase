local runService = game:GetService('RunService')

local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

humanoid.Died:Connect(function() script:Destroy() end)

wait(math.random(20, 35))
runService.Heartbeat:Connect(function(deltaTime)
	if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		humanoid:TakeDamage(10 * deltaTime)
	else
		script:Destroy()
	end
end)