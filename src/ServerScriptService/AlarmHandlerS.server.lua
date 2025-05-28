-- // Steven_Scripts, 2022

local tws = game:GetService("TweenService")

local mainFolder = workspace.AlarmSystem

local statesFolder = mainFolder.States
local switchFolder = mainFolder.Switches
local speakerFolder = mainFolder.Speakers
local readersFolder = mainFolder.KeycardReaders
local screensFolder = mainFolder.LogScreens

local soundsFolder = script.Sounds

local locked = true

local switchLists = {}

local function checkClearance(plr, requiredClearance, exception)
	local char = plr.Character

	if char then
		local inventory = plr.Backpack:GetChildren()
		local heldTool = char:FindFirstChildOfClass("Tool")
		if heldTool then
			table.insert(inventory, heldTool)
		end

		for i,tool in pairs(inventory) do 
			if tool and (game.ServerStorage.CLEARANCE_TREE:FindFirstChild(tostring(requiredClearance)):FindFirstChild(tool.Name) or tool.Name == exception) then
				return true
			end
		end
	end

	return false
end

local function prepareSwitches()
	for i,switch in pairs(switchFolder:GetChildren()) do
		local switchList = switchLists[switch.Name]
		if switchList == nil then
			switchList = {}
			switchLists[switch.Name] = switchList
		end
		
		table.insert(switchList, switch)
		-- that's a heck of a tongue twister
		
		local cooldown = false
		
		local boolValue = statesFolder[switch.Name]

		local handle = switch.Handle
		local primary = handle.Primary
		
		local hitbox = switch.Hitbox
		
		local downTween = tws:Create(primary,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = handle.Off.CFrame})
		local upTween = tws:Create(primary,TweenInfo.new(0.3,Enum.EasingStyle.Back),{CFrame = handle.On.CFrame})
		
		local maxActivationDistance = 5
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = maxActivationDistance
		clickDetector.Parent = hitbox
		
		local pullDownSound = soundsFolder.PullDown:Clone()
		local pullUpSound = soundsFolder.PullUp:Clone()
		
		pullDownSound.Parent = primary
		pullUpSound.Parent = primary
		
		clickDetector.MouseClick:Connect(function(plr)
			if locked == true or cooldown == true then return end
			if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health ~= 0 and plr.Character:FindFirstChild("HumanoidRootPart") then else return end
			
			local root = plr.Character.HumanoidRootPart
			if (root.Position - hitbox.Position).Magnitude <= maxActivationDistance+5 then
				cooldown = true
				
				clickDetector.MaxActivationDistance = 0
				
				boolValue.Value = not boolValue.Value
				
				if boolValue.Value == true then
					pullDownSound:Play()
					downTween:Play()
				else
					pullUpSound:Play()
					upTween:Play()
				end
				
				task.wait(1)
				
				clickDetector.MaxActivationDistance = maxActivationDistance
				
				cooldown = false
			end
		end)
	end
end

local logs = {}
local maxLogEntries = 14

local function prepareScreens()
	for i,screen in pairs(screensFolder:GetChildren()) do
		local screenPart = screen.Screen
		local ui = script.LogScreenGui:Clone()
		ui.Parent = screenPart
	end
end

local function logAction(text)
	local index = #logs+1
	if index > maxLogEntries then
		-- We need to make room at the end of the list
		-- Remove oldest entry and move each entry after that back by one to fill the space

		-- Handle the internal data first
		table.remove(logs, 1)
		-- That was easy

		-- Then the UI
		for i,screen in pairs(screensFolder:GetChildren()) do
			local ui = screen.Screen.LogScreenGui
			local frame = ui.Frame
			for _,label in pairs(frame:GetChildren()) do
				if label:IsA("TextLabel") then
					local layoutOrder = label.LayoutOrder

					if layoutOrder > 1 then
						label.LayoutOrder = label.LayoutOrder-1
						label.Name = label.LayoutOrder
					else
						label:Destroy()
					end
				end
			end
		end

		-- And we're good
		index = #logs+1
	end

	-- Add entry
	local label = script.LogEntry:Clone()
	label.LayoutOrder = index
	label.Name = index

	local timestamp = workspace.DistributedGameTime
	
	label.Text = os.date("%X", timestamp).." - "..text

	local entry = {Timestamp = timestamp, Text = text}

	logs[index] = entry

	-- Add to all screens
	for i,screen in pairs(screensFolder:GetChildren()) do
		local ui = screen.Screen.LogScreenGui
		local frame = ui.Frame

		label:Clone().Parent = frame
	end
end

local lockedLightColor = Color3.new(.5, .4, .4)
local unlockedLightColor = Color3.new(0.1, .8, 1)

local function lock()
	locked = true
	for i,reader in pairs(readersFolder:GetChildren()) do
		local primary = reader.PrimaryPart
		
		reader.Light.Color = lockedLightColor
		
		primary.Lock:Play()
		primary.ProximityPrompt.ActionText = "Unlock"
	end
end

local function unlock()
	locked = false
	for i,reader in pairs(readersFolder:GetChildren()) do
		local primary = reader.PrimaryPart
		
		reader.Light.Color = unlockedLightColor
		
		primary.Lock:Play()
		primary.ProximityPrompt.ActionText = "Lock"
	end
	
	---- Auto lock after 20s
	for i=1, 15 do
		task.wait(1)
		if locked == false then
			for i,reader in pairs(readersFolder:GetChildren()) do
				reader.PrimaryPart.Tick:Play()
			end
		else
			break
		end
	end
	for i=1, 10 do
		task.wait(0.5)
		if locked == false then
			for i,reader in pairs(readersFolder:GetChildren()) do
				reader.PrimaryPart.Tick:Play()
			end
		else
			break
		end
	end

	if locked == false then
		---- Auto lock triggered
		logAction("System idled for 20s; auto-lock triggered")
		lock()
	end
end

local function prepareReaders()
	for i,reader in pairs(readersFolder:GetChildren()) do
		local primary = reader.PrimaryPart
		
		local light = reader.Light
		
		light.Color = lockedLightColor
		
		local acceptSound = soundsFolder.ReaderAccept:Clone()
		local denySound = soundsFolder.ReaderDeny:Clone()
		local tickSound = soundsFolder.Tick:Clone()
		local lockSound = soundsFolder.Lock:Clone()
		
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = "Alarm Controls"
		prompt.ActionText = "Unlock"
		prompt.MaxActivationDistance = 5
		prompt.Style = Enum.ProximityPromptStyle.Custom
		
		acceptSound.Parent = primary
		denySound.Parent = primary
		tickSound.Parent = primary
		lockSound.Parent = primary
		
		prompt.Parent = primary
		
		local cooldown = false
		prompt.Triggered:Connect(function(plr)
			if cooldown == true then return end
			
			prompt.MaxActivationDistance = 0
			
			if checkClearance(plr, 4, "SECURITY-CARD") == true then
				acceptSound:Play()
				light.Color = Color3.new(0, 1, 0)
				
				lockSound:Play()
				
				coroutine.wrap(function()
					if locked == true then
						logAction("Controls unlocked by "..plr.Name.." ("..reader.Name..")")
						unlock()
					else
						logAction("Controls locked by "..plr.Name.." ("..reader.Name..")")
						lock()
					end
				end)()
				
				task.wait(1)
			else
				denySound:Play()
				light.Color = Color3.new(1, 0, 0)
				
				task.wait(1)
			end
			
			if locked == true then
				light.Color = lockedLightColor
			else
				light.Color = unlockedLightColor
			end
			
			cooldown = false
			prompt.MaxActivationDistance = 5
		end)
	end
end

local function onAlarmStateChanged(boolValue)	
	if boolValue.Value == true then
		---- Alarm turned on
		-- logAction(boolValue.Name.." alarm enabled")
		
		local switchList = switchLists[boolValue.Name]
		for i,switch in pairs(switchList) do
			switch.Light.BrickColor = BrickColor.new("Persimmon")
		end
	else
		---- Alarm turned off
		-- logAction(boolValue.Name.." alarm disabled")
		
		local switchList = switchLists[boolValue.Name]
		for i,switch in pairs(switchList) do
			switch.Light.BrickColor = BrickColor.new("Medium Medium stone grey")
		end
	end
end

---- Initializing
for i,boolValue in pairs(statesFolder:GetChildren()) do
	boolValue:GetPropertyChangedSignal("Value"):Connect(function()
		onAlarmStateChanged(boolValue)
	end)
end

prepareScreens()
prepareReaders()
prepareSwitches()