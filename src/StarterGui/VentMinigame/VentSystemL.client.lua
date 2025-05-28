-- // Steven_Scripts, 2022

local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tws = game:GetService("TweenService")
local pps = game:GetService("ProximityPromptService")
local rst = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")

local modulesFolder = rst.Modules
local remotesFolder = rst.Remotes

local infectedCheck = require(rst.InfectedCheckModule)
local ventTools = require(modulesFolder.VentTools)

local plr = game.Players.LocalPlayer
local animTrack = nil

local ui = script.Parent
local frame = ui.Frame

local marker = frame.Marker
local green = frame.Green

local direction = 1

local difficulty = 1
local timeMultiplier = 1
local progress = 0

local minStress = 0.05
local maxStress = 0.9

local shake = 0

local stress = minStress

local mouseXPos = 0

local drilling = false
local holding = false
local inRange = false
local cooldown = false

local currentVent = nil

local rng = Random.new()

local function hasTool(plr, toolName)
	local char = plr.Character
	if char then
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			if tool.Name == toolName then
				return true
			end
		end
	end

	if plr.Backpack:FindFirstChild(toolName) then
		return true
	end

	return false
end

local function getModifiers()
	local highestPriority = 0
	local selectedToolName, selectedInfo
	for toolName, info in pairs(ventTools) do
		if hasTool(plr, toolName) then
			if info.Priority > highestPriority then
				selectedToolName = toolName
				selectedInfo = info
			end
		end
	end
	if selectedToolName then
		return selectedToolName, selectedInfo
	end

	-- Has no vent tool
	return "None", {
		SpeedMultiplier = 1,
		DecayMultiplier = 1,
		AreaMoveSpeedMultiplier = 1,
		FailPenalty = -0.1,
		FailCooldown = 3,
	}
end

local originalFrameColor = frame.BackgroundColor3
local function startDrilling()
	if drilling == false then
		ui.Drilling:Play()
		frame.BackgroundColor3 = Color3.new(0.4, 0.1, 0.1)
		drilling = true
	end
end

local function stopDrilling()
	if drilling == true then
		ui.Drilling:Stop()
		frame.BackgroundColor3 = originalFrameColor
		drilling = false
	end
end

local function selectVent(prompt)
	progress = 0
	stress = minStress

	if prompt == nil then
		-- Cancel
		remotesFolder.Vents.Interaction:FireServer(nil)

		animTrack:Stop()

		stopDrilling()
		frame.Visible = false
		currentVent = nil
	else
		local vent = prompt.Parent
		local primaryPart = vent.PrimaryPart

		animTrack:Play()

		remotesFolder.Vents.Interaction:FireServer(vent)

		difficulty = vent:GetAttribute("Difficulty")
		timeMultiplier = vent:GetAttribute("TimeMultiplier")
		currentVent = vent

		frame.Visible = true
	end
end

local function win()
	-- yay
	remotesFolder.Vents.Open:FireServer(currentVent)

	stopDrilling()
	selectVent(nil)
end

local function changeProgress(increment)
	progress = progress+increment
	progress = math.clamp(progress, 0, 1)

	frame.Progress.Fill.Size = UDim2.new(progress, 0, 1, 0)

	if progress == 1 then
		progress = 0
		win()
	end
end

local originalGreenColor = green.BackgroundColor3
local greenTween = tws:Create(green, TweenInfo.new(.5), {BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)})
local function fail()	
	-- oh no
	cooldown = true

	remotesFolder.Vents.Fail:FireServer(currentVent)

	stopDrilling()
	
	local toolName, modifiers = getModifiers()
	
	changeProgress(modifiers.FailPenalty)

	green.BackgroundColor3 = Color3.new(1, 0, 0)
	greenTween:Play()

	for i=6,0,-.1 do
		task.wait()
		shake = i
	end
	
	task.wait(modifiers.FailCooldown)

	cooldown = false
end

pps.PromptTriggered:Connect(function(prompt)
	if table.find(cs:GetTags(prompt.Parent), "VentInteractable") ~= nil then
		-- Yep, this is a vent
		if currentVent == nil then
			-- Wait, make sure we're not dead
			local char = plr.Character
			if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
				-- Okay, we're good
				selectVent(prompt)
			end
		end
	end
end)

local originalFramePosition = frame.Position
rs.RenderStepped:Connect(function(timeSinceLastFrame)
	if currentVent ~= nil then
		-- are ya winning son
		local mouseLocation = uis:GetMouseLocation()
		mouseXPos = (mouseLocation.X - frame.AbsolutePosition.X)/frame.AbsoluteSize.X
		mouseXPos = math.clamp(mouseXPos, 0, 1)

		inRange = mouseXPos > green.Position.X.Scale and mouseXPos < green.Position.X.Scale+green.Size.X.Scale
		if inRange then
			marker.BackgroundColor3 = Color3.new(1, 1, 1)
			marker.Arrow.ImageColor3 = Color3.new(1, 1, 1)
		else
			marker.BackgroundColor3 = Color3.new(1, 0, 0)
			marker.Arrow.ImageColor3 = Color3.new(1, 0, 0)
			if drilling then
				fail()
			end
		end
		
		local toolName, modifiers = getModifiers()
		if toolName == "None" then
			frame.Tool.TextColor3 = Color3.new(1, 0, 0)
			if infectedCheck(plr) == true then
				frame.Tool.Text = "Using: Bare paws"
			else
				frame.Tool.Text = "Using: Bare hands"
			end
		else
			frame.Tool.TextColor3 = Color3.new(1, .9, 0)
			frame.Tool.Text = "Using: "..toolName
		end

		local progressIncrement = 0
		if drilling then
			-- Progressing
			progressIncrement = (.2*stress)/difficulty/timeMultiplier
			progressIncrement = progressIncrement*modifiers.SpeedMultiplier
		else
			-- Decaying
			progressIncrement = -.1/timeMultiplier
		end
		progressIncrement = progressIncrement * timeSinceLastFrame

		changeProgress(progressIncrement)

		-- Highlighted area movement
		local stressIncrement = 0
		if drilling then
			stressIncrement = 0.1
		else
			stressIncrement = -0.4
		end
		stressIncrement = stressIncrement*timeSinceLastFrame

		stress = math.clamp(stress+stressIncrement, minStress, maxStress)

		ui.Drilling.PlaybackSpeed = 0.5 + (stress-minStress)/maxStress*0.5

		local newGreenXSize = 1-stress

		local greenXPosMax = 1 - newGreenXSize
		local greenXPosMovement = stress * timeSinceLastFrame * direction
		greenXPosMovement = greenXPosMovement * modifiers.AreaMoveSpeedMultiplier

		local newGreenXPos = math.clamp(green.Position.X.Scale+greenXPosMovement, 0, greenXPosMax)
		if newGreenXPos == greenXPosMax or newGreenXPos == 0 then
			direction = -direction
		end

		green.Position = UDim2.new(newGreenXPos, 0, 0, 0)
		green.Size = UDim2.new(newGreenXSize, 0, 1, 0)
		frame.Marker.Position = UDim2.new(mouseXPos, 0, 0, 0)

		if not cooldown then
			green.BackgroundColor3 = Color3.fromHSV(.33333333-(0.3 * stress), 1, .7)
		end

		-- Shake
		if shake > 0 then
			frame.Position = UDim2.new(originalFramePosition.X.Scale, originalFramePosition.X.Offset + rng:NextNumber(-shake, shake), originalFramePosition.Y.Scale, originalFramePosition.Y.Offset + rng:NextNumber(-shake, shake))
		end
	end
end)

local function holdBegan()
	if currentVent == nil then return end
	holding = true
	if inRange and cooldown == false then startDrilling() end
end

local function holdEnded()
	holding = false
	stopDrilling()
end

local function onCharacterAdded(char)
	local root = char:FindFirstChild("HumanoidRootPart")
	local tries = 0
	if not root then
		repeat
			root = char:FindFirstChild("HumanoidRootPart")
			tries = tries+1
			task.wait(1)
		until root ~= nil or tries > 20
	end
	
	local hum = char:WaitForChild("Humanoid")
	local animator = hum:WaitForChild("Animator")
	animTrack = animator:LoadAnimation(script:WaitForChild("Animation"))
	
	hum.Died:Connect(function()
		selectVent(nil)
	end)
	
	while char.Parent ~= nil do
		if currentVent ~= nil then
			local distance = (currentVent.PrimaryPart.Position - root.Position).Magnitude
			if distance > 10 then
				selectVent(nil)
			end
		end
		task.wait(1)
	end
end

uis.TouchStarted:Connect(holdBegan)
uis.TouchEnded:Connect(holdEnded)

uis.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		holdBegan()
	end
end)

uis.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		holdEnded()
	end
end)

remotesFolder.Vents.Interaction.OnClientEvent:Connect(selectVent)

plr.CharacterAdded:Connect(onCharacterAdded)

if plr.Character then
	onCharacterAdded(plr.Character)
end