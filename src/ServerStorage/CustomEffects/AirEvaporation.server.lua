local runService = game:GetService('RunService')

local tool = script.Parent
local character
local humanoid

local activated = false

if not tool:IsA('Tool') then script:Destroy() end

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

tool.Equipped:Connect(function()
	character = tool.Parent
	humanoid = character:WaitForChild('Humanoid')
	
	if not activated and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		activated = true
		coroutine.wrap(function()
			wait(4)
			if tool.Name ~= 'Empty Cup' then
				humanoid:TakeDamage(35)
				if tool:FindFirstChild('Liquid') then tool.Liquid:Destroy() end
				tool.Name = 'Empty Cup'
				script:Destroy()
			end
		end)()
	end
end)

tool:GetPropertyChangedSignal('Name'):Connect(function()
	if tool.Name == 'Empty Cup' then script:Destroy() end
end)