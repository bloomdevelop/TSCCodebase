local debris = game:GetService('Debris')
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
			wait(3)
			if tool:FindFirstChild('Liquid') then
				for i = 1, 20 do
					local part = Instance.new('Part')
					part.Color = tool.Liquid.Color
					part.Material = tool.Liquid.Material
					part.Transparency = tool.Liquid.Transparency
					part.Reflectance = tool.Liquid.Reflectance
					part.Size = Vector3.new(0.3, 0.3, 0.3)
					part.CanCollide = false
					part.Anchored = false
					part.CFrame = tool.Liquid.CFrame
					part.Velocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					part.Name = 'Liquid'
					part.Parent = workspace
					debris:AddItem(part, 3)
				end
				tool.Liquid:Destroy()
			end
			tool.Name = 'Empty Cup'
			script:Destroy()
		end)()
	end
end)

tool:GetPropertyChangedSignal('Name'):Connect(function()
	if tool.Name == 'Empty Cup' then script:Destroy() end
end)