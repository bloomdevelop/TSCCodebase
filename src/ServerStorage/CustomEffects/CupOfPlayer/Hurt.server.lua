local players = game:GetService('Players')
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

for i = 1,5,1 do
	humanoid.Health = humanoid.Health - 2
	wait(1)
end
script:Destroy()