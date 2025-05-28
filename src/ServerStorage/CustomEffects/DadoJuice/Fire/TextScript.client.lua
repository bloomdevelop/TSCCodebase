local runService = game:GetService('RunService')

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

wait(3)
runService.Heartbeat:Connect(function(deltaTime)
	if script.Parent.TextTransparency < 1 then
		script.Parent.TextTransparency = script.Parent.TextTransparency + deltaTime
		script.Parent.TextStrokeTransparency = script.Parent.TextTransparency
	end
end)