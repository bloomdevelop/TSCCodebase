-- // Steven_Scripts, 2022

local cas = game:GetService("ContextActionService")
local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")
local tws = game:GetService("TweenService")
local rs = game:GetService("RunService")

local remotesFolder = rst.Remotes
local modulesFolder = rst.Modules

local doorToolInfoDir = require(modulesFolder.DoorTools)

--[[
local InteractableList = {}
for i,descendant in pairs(workspace:GetDescendants())do
	if descendant.Name == "Interactable" then
		table.insert(InteractableList,descendant.Parent)
	end
end
]]

local tagName = "DoorInteractable"

local doors = {}
for i,door in pairs(cs:GetTagged(tagName)) do
	doors[i] = door
end

cs:GetInstanceAddedSignal(tagName):Connect(function(door)
	table.insert(doors, door)
end)

local UI = script.Parent

local interactFrame = UI.InteractFrame
local secondaryInteractFrame = UI.SecondaryInteractFrame

local interactRange = 10

local plr = game.Players.LocalPlayer

local char = nil
local root = nil

local frameCooldown = false 

local function onCharacterAdded(newChar)
	char = newChar
	char:WaitForChild("Humanoid", 30)
	root = char:WaitForChild("HumanoidRootPart", 30)
end

plr.CharacterAdded:Connect(onCharacterAdded)

function getClosestDoor()
	if root ~= nil then
		local closestDistance = 10
		local closestDoor

		for i,door in pairs(doors)do
			if door:IsDescendantOf(workspace) then
				local buttons = {}

				local moreDoorButtons = door:FindFirstChild("MoreDoorButtons")

				if moreDoorButtons then
					for i,button in pairs(moreDoorButtons:GetChildren()) do
						buttons[i] = button
					end
				else
					buttons[1] = door.PrimaryPart
				end

				for i,button in pairs(buttons) do
					local distance = (button.CFrame.Position - root.CFrame.Position).Magnitude
					if distance <= interactRange and distance <= closestDistance then
						closestDoor = door
						closestDistance = distance
					end
				end
			end	
		end

		return closestDoor
	end
end

local function getInventory()
	local inventory = plr.Backpack:GetChildren()
	local heldTool = char:FindFirstChildOfClass("Tool")
	if heldTool then
		table.insert(inventory, heldTool)
	end

	return inventory, heldTool
end

local function onDoorStateChanged(door, animationSpeed)
	if door.PrimaryPart == nil then
		-- Door isn't loaded in, don't worry about it
		return
	end

	local tweenTime = door:FindFirstChild("TweenSpeed") and door.TweenSpeed.Value or 0.5

	local closed = door.Closed.Value

	local easingStyle = door:FindFirstChild("EasingStyle") and Enum.EasingStyle[door.EasingStyle.Value] or Enum.EasingStyle.Quad
	if door.Closed.Value then
		local tween = tws:Create(door.LDoor.PrimaryPart,TweenInfo.new(tweenTime/animationSpeed,easingStyle),{CFrame = door.LDoorClosed.CFrame})
		tween:Play()
		game.Debris:AddItem(tween, tweenTime+1)

		if door:FindFirstChild("RDoor") then
			local tween = tws:Create(door.RDoor.PrimaryPart,TweenInfo.new(tweenTime/animationSpeed,easingStyle),{CFrame = door.RDoorClosed.CFrame})
			tween:Play()
			game.Debris:AddItem(tween, tweenTime+1)
		end
	else
		local tween = tws:Create(door.LDoor.PrimaryPart,TweenInfo.new(tweenTime/animationSpeed,easingStyle),{CFrame = door.LDoorOpen.CFrame})
		tween:Play()
		game.Debris:AddItem(tween, tweenTime+1)

		if door:FindFirstChild("RDoor") then
			local tween = tws:Create(door.RDoor.PrimaryPart,TweenInfo.new(tweenTime/animationSpeed,easingStyle),{CFrame = door.RDoorOpen.CFrame})
			tween:Play()
			game.Debris:AddItem(tween, tweenTime+1)
		end
	end
end

local function getDoorTool()
	local heldTool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
	if heldTool then
		local toolInfo = doorToolInfoDir[heldTool.Name]
		if toolInfo ~= nil then
			return heldTool, toolInfo
		end
	end

	return nil, nil
end

local function canUseDoorTool(toolInfo, door : Model)
	local pass = true

	for valueName, requirements in pairs(toolInfo.Requirements) do
		local value = door:FindFirstChild(valueName)
		
		if typeof(requirements) == "table" then
			if requirements.Type == "Range" then
				if value.Value < requirements.Min or value.Value > requirements.Max then
					-- Doesn't meet requirements; out of range
					pass = false
					break
				end
			end
		else
			if requirements == true then
				if value == nil or value.Value == false then
					-- Doesn't meet requirements; required state is false
					pass = false
					break
				end
			elseif requirements == false then
				if value ~= nil and value.Value == true then
					-- Doesn't meet requirements; required state is true
					pass = false
					break
				end
			end
		end
	end

	-- Passed all checks
	return pass
end

local function interact(_,userInputState,input)
	if userInputState == Enum.UserInputState.Begin and frameCooldown == false then
		local door = getClosestDoor()
		if door and door:FindFirstChild("OnCooldown") == nil then
			script.Click:Play()

			interactFrame.Background.BackgroundTransparency = 0.5
			task.delay(0.1, function()
				interactFrame.Background.BackgroundTransparency = 0
			end)

			local response = remotesFolder.Doors.InteractEvent:InvokeServer(door)
			if not response then return end

			if not response or response.Success or response.Type == "Cooldown" then return end

			local InteractFrameText
			if response.Type == "NoClearance" then
				InteractFrameText = response.FormatArgs and (response.NoPrefix and "%s NEEDED" or "CLEARANCE L-%s NEEDED") or "NO CLEARANCE"
			elseif response.Type == "Jammed" then
				InteractFrameText = "JAMMED"
			elseif response.Type == "Lockdown" then
				InteractFrameText = "LOCKDOWN"
			else
				InteractFrameText = "This shouldn't appear, Contact the devs"
				response.FormatArgs = nil
				warn(string.format("Response type %s is not coded in.", response.Type))
			end

			interactFrame.TextLabel.Text = not response.FormatArgs and InteractFrameText or
				string.format(InteractFrameText, table.unpack(response.FormatArgs))
			
			frameCooldown = true
			task.delay(1, function()
				frameCooldown = false
			end)
		end
	end
end

local function secondaryInteract(_,userInputState,input)
	if userInputState == Enum.UserInputState.Begin and frameCooldown == false and secondaryInteractFrame.Visible == true then
		local door = getClosestDoor()
		if door and door:FindFirstChild("OnCooldown") == nil then
			script.Click:Play()

			secondaryInteractFrame.Background.BackgroundTransparency = 0.5
			task.delay(0.1, function()
				secondaryInteractFrame.Background.BackgroundTransparency = 0
			end)

			remotesFolder.Doors.SecondaryInteractEvent:FireServer(door)
		end
	end
end

cas:BindAction("Interact", interact, false, Enum.KeyCode.Q)
cas:BindAction("SecondaryInteract", secondaryInteract, false, Enum.KeyCode.F)

remotesFolder.Doors.DoorStateChanged.OnClientEvent:Connect(onDoorStateChanged)

interactFrame.TextButton.MouseButton1Down:Connect(function()
	interact(nil, Enum.UserInputState.Begin)
end)

secondaryInteractFrame.TextButton.MouseButton1Down:Connect(function()
	secondaryInteract(nil, Enum.UserInputState.Begin)
end)

repeat
	local closestDoor = getClosestDoor()

	if closestDoor ~= nil and closestDoor:FindFirstChild("OnCooldown") == nil then
		interactFrame.Visible = true

		-- Check eligibility for secondary interaction
		secondaryInteractFrame.Visible = false

		local heldTool, toolInfo = getDoorTool()
		if heldTool then
			if canUseDoorTool(toolInfo, closestDoor) then
				secondaryInteractFrame.TextLabel.Text = "[F] "..toolInfo.ActionName
				secondaryInteractFrame.Visible = true
			end
		end

		if not frameCooldown then
			interactFrame.TextLabel.Text = (closestDoor:FindFirstChild("Jammed") and "JAMMED") or
				(closestDoor:FindFirstChild("Lockdown") and "LOCKDOWN") or
				(closestDoor.Closed.Value and "[Q] OPEN" or "[Q] CLOSE")
		end
	else
		interactFrame.Visible = false
		secondaryInteractFrame.Visible = false
	end

	task.wait(1/30)
until false