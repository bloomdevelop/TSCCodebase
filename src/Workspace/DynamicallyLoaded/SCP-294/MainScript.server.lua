local players = game:GetService('Players')
local serverStorage = game:GetService('ServerStorage')
local runService = game:GetService('RunService')

local body = script.Parent:WaitForChild('Body')
local pad = script.Parent:WaitForChild('Pad')
local cup = script.Parent:WaitForChild('Cup')
local usePrompt = body:WaitForChild('UseAttachment'):WaitForChild('ProximityPrompt')
local cupPrompt = body:WaitForChild('CupAttachment'):WaitForChild('ProximityPrompt')

local gui = serverStorage:WaitForChild('SCP294Gui')
local resetter = script.Parent:WaitForChild('Resetter')

local maxUses = script.Parent:GetAttribute('MaxUses')

local enabled = true
local timesUsed = script.Parent:WaitForChild('TimesUsed')
local user = script.Parent:WaitForChild('User')
local dispensing = script.Parent:WaitForChild('Dispensing')

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

usePrompt.Triggered:Connect(function(player)
	if not player.PlayerGui:FindFirstChild(gui.Name) and enabled and timesUsed.Value < maxUses and user.Value == '' then
		local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
		if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			user.Value = player.Name
			usePrompt.Enabled = false
			local newGui = gui:Clone()
			local WSCache = Instance.new('NumberValue')
			WSCache.Value = humanoid.WalkSpeed
			WSCache.Name = 'WalkSpeedCache'
			WSCache.Parent = newGui
			local JPCache = Instance.new('NumberValue')
			JPCache.Value = humanoid.JumpPower
			JPCache.Name = 'JumpPowerCache'
			JPCache.Parent = newGui
			newGui.Parent = player.PlayerGui
		end
	end
end)

resetter.Event:Connect(function()
	if enabled and timesUsed.Value < maxUses and not dispensing.Value and cup.Handle.Transparency >= 1 then
		if body.OutOfRange.Playing then body.OutOfRange.Ended:wait() end
		pad.SurfaceGui.Input.Text = ''
		if user.Value == '' then usePrompt.Enabled = true end
	end
end)

timesUsed.Changed:Connect(function()
	if enabled then
		if timesUsed.Value < maxUses then
			usePrompt.Enabled = true
		else --Render SCP-294 unusable for 3 minutes if the use limit is reached
			enabled = false
			timesUsed.Value = 0
			usePrompt.Enabled = false
			coroutine.wrap(function()
				wait(180)
				enabled = true
				usePrompt.Enabled = true
			end)()
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	if player.Name == user.Value then
		user.Value = ''
		resetter:Fire()
	end
end)