local debris = game:GetService('Debris')
local runService = game:GetService('RunService')

local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local function wait(waitTime: number)
	local deltaTime = 0

	if waitTime and waitTime > 0 then
		while deltaTime < waitTime do
			deltaTime = deltaTime + runService.Heartbeat:wait()
		end
	else
		deltaTime = deltaTime + runService.Heartbeat:wait()
	end
	return deltaTime
end

humanoid.Died:Connect(function() script:Destroy() end)

if not humanoid:FindFirstChild('5hEnergy') then
	local check = Instance.new('Model')
	check.Name = '5hEnergy'
	check.Parent = humanoid
	debris:AddItem(check, 180)
	script:Destroy()
else --If the player drank a 5-Hour Energy within 3 minutes of first drinking
	wait(math.random(20, 50))
	humanoid:TakeDamage(math.huge)
	script:Destroy()
end