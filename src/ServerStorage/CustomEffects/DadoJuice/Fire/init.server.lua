local players = game:GetService('Players')
local debris = game:GetService('Debris')
local runService = game:GetService('RunService')

local player = players:GetPlayerFromCharacter(script.Parent)
local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')
local root = character:WaitForChild('HumanoidRootPart')

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

function showText(player, message: string)
	assert(player and player:IsA('Player'))
	assert(script:FindFirstChild('TextScript'), 'Could not find TextScript!')

	if not player.PlayerGui:FindFirstChild('MessageGui') then
		local gui = Instance.new('ScreenGui')
		gui.DisplayOrder = 2
		gui.ResetOnSpawn = false
		gui.Name = 'MessageGui'
		gui.Parent = player.PlayerGui
		local text = Instance.new('TextLabel')
		text.Position = UDim2.new(0, 0, 0.8, 0)
		text.Size = UDim2.new(1, 0, 0.04, 0)
		text.BackgroundTransparency = 1
		text.Font = 'SourceSansSemibold'
		text.Text = message
		text.TextTransparency = 0
		text.TextStrokeTransparency = 0
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextScaled = true
		text.Parent = gui
		local scr = script.TextScript:Clone()
		scr.Parent = text
		scr.Disabled = false
		debris:AddItem(gui, 5)
	else
		player.PlayerGui.MessageGui:Destroy()
		showText(player, message)
	end
end

humanoid.Died:Connect(function() script:Destroy() end)

wait(60)
showText('Your body is getting hot.')
wait(120)
for _, part in pairs(character:GetChildren()) do
	if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' then
		local p1 = script.Primary:Clone()
		p1.Enabled = true
		p1.Parent = part
		local p2 = script.Secondary:Clone()
		p2.Enabled = true
		p2.Parent = part
		local p3 = script.Smoke:Clone()
		p3.Enabled = true
		p3.Parent = part
		local p4 = script.Sparks:Clone()
		p4.Enabled = true
		p4.Parent = part
	end
end
while true do
	wait(0.25)
	for _, p in pairs(workspace:GetChildren()) do
		if p:IsA('Model') then
			local humanoid = p:FindFirstChildOfClass('Humanoid')
			if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				local r = p:FindFirstChild('HumanoidRootPart')
				if r and (r.Position - root.Position).magnitude <= 5 then 
					humanoid:TakeDamage(10)
				end
			end
		end
	end
end