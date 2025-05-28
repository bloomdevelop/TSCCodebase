local runService = game:GetService('RunService')

local frame = script.Parent:WaitForChild('Frame')

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

while frame.BackgroundTransparency > 0 do
	frame.BackgroundTransparency = frame.BackgroundTransparency - wait()
end