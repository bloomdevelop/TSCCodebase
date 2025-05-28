local players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')
local starterGui = game:GetService('StarterGui')
local userInputService = game:GetService('UserInputService')
local runService = game:GetService('RunService')

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local humanoid = character:WaitForChild('Humanoid')
local camera = workspace.CurrentCamera

local scp = workspace:FindFirstChild('SCP-294', true)

assert(scp, 'Could not find SCP-294 in Workspace!')
assert(scp:FindFirstChild('Body') and scp:FindFirstChild('Cup'), 'Got a different SCP-294 model in Workspace! Try renaming the other SCP-294 model.')

local panel = script.Parent:WaitForChild('Panel')
local keyboard = panel:WaitForChild('Keyboard')
local back = panel:WaitForChild('Back')
local enter = panel:WaitForChild('Enter')
local close = script.Parent:WaitForChild('Close')
local pad = panel:WaitForChild('Pad')

local buttonClick = script:WaitForChild('ButtonClick')

local dispenseDrink = replicatedStorage:WaitForChild('DispenseDrink')

local debounce = false
local drink = ''
local drinkChars = {}
local closed = false

local WSCache = script.Parent:FindFirstChild('WalkSpeedCache')
local JPCache = script.Parent:FindFirstChild('JumpPowerCache')

userInputService.ModalEnabled = true
camera.CameraType = 'Scriptable'
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

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

function closeGui()
	closed = true
	userInputService.ModalEnabled = false
	camera.CameraType = 'Custom'
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	humanoid.WalkSpeed = WSCache and WSCache.Value or 16
	humanoid.JumpPower = JPCache and JPCache.Value or 50
	script.Parent.Enabled = false
end

for _, key in pairs(keyboard:GetChildren()) do
	if key:IsA('TextButton') then
		key.MouseButton1Down:Connect(function()
			buttonClick:Play()
			if not debounce then
				local char = key.Name
				if key.Name == 'Spacebar' then char = ' ' end
				drink = drink..char
				table.insert(drinkChars, char)
				pad.Text = string.upper(drink)
			end
		end)
	end
end

back.MouseButton1Down:Connect(function()
	buttonClick:Play()
	if not debounce and drinkChars[1] then
		drink = ''
		table.remove(drinkChars, #drinkChars)
		for _, char in pairs(drinkChars) do drink = drink..char end
		pad.Text = string.upper(drink)
	end
end)

enter.MouseButton1Down:Connect(function()
	buttonClick:Play()
	if not debounce and drink ~= '' then
		debounce = true
		close.Visible = false
		local result = dispenseDrink:InvokeServer(string.upper(drink))
		if result == 'Dispensing' then
			closeGui()
		elseif result == 'OutOfRange' then
			debounce = false
			drink = ''
			drinkChars = {}
			close.Visible = true
			pad.Text = ''
		else
			debounce = false
			close.Visible = true
			warn('Returned unknown dispense result.')
		end
	end
end)

close.MouseButton1Click:Connect(closeGui)
humanoid.Died:Connect(closeGui)

runService.Heartbeat:Connect(function()
	if not closed then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	else
		humanoid.WalkSpeed = WSCache and WSCache.Value or 16
		humanoid.JumpPower = JPCache and JPCache.Value or 50
	end
	humanoid:UnequipTools()
end)