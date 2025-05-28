local runService = game:GetService('RunService')
local debris = game:GetService('Debris')

local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local duration = script:WaitForChild('Duration')

humanoid.Died:Connect(function() script:Destroy() end)

runService.Heartbeat:Connect(function(deltaTime)
	if duration.Value > 0 then
		duration.Value = duration.Value - deltaTime
	else
		humanoid:TakeDamage(math.huge)
		script:Destroy()
	end
end)