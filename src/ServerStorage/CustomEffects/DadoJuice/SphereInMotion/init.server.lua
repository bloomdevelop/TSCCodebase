local players = game:GetService('Players')
local tweenService = game:GetService('TweenService')
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

wait(45)
showText(player, 'You feel nervous.')
wait(15)
showText(player, 'Your body is feeling jittery.')
wait(180)
local connection = runService.Heartbeat:Connect(function()
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 5
	humanoid.Jump = true	
end)
local info = TweenInfo.new(30, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local bodyVelocity = Instance.new('BodyVelocity')
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = root
tweenService:Create(bodyVelocity, info, {Velocity = Vector3.new(0, 250, 0)}):Play()
wait(60)
humanoid:TakeDamage(math.huge)