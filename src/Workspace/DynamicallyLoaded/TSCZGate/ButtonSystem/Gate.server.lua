-- // Steven_Scripts, 2022

local tws = game:GetService("TweenService")

local buttonSystem = script.Parent
local alarmPart = buttonSystem.AlarmPart
local gate = buttonSystem.Parent
local door = gate.SlidingMetalDoor

local reader = buttonSystem.KeycardReader
local readerPrimary = reader.PrimaryPart

local prompt = readerPrimary.ProximityPrompt

local doorPrimary = gate.SlidingMetalDoor.Primary

local closedPos = door.ClosePos
local openPos = door.OpenPos

local doorCloseTween = tws:Create(doorPrimary,TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),{CFrame = closedPos.CFrame})
local doorOpenTween = tws:Create(doorPrimary,TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),{CFrame = openPos.CFrame})

local closed = false
local cooldown = false

local function checkClearance(plr, requiredClearance)
	local char = plr.Character

	if char then
		local inventory = plr.Backpack:GetChildren()
		local heldTool = char:FindFirstChildOfClass("Tool")
		if heldTool then
			table.insert(inventory, heldTool)
		end

		for i,tool in pairs(inventory) do 
			if tool and game.ServerStorage.CLEARANCE_TREE:FindFirstChild(tostring(requiredClearance)):FindFirstChild(tool.Name) then
				return true
			end
		end
	end

	return false
end

local function onPromptTriggered(plr)
	if cooldown == true then return end
	
	local char = plr.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		
		if hum and hum.Health > 0 then
			cooldown = true
			
			prompt.MaxActivationDistance = 0
			
			if checkClearance(plr, 2) == true then
				reader.Light.Color = Color3.new(0, 1, 0)
				readerPrimary.ReaderAccept:Play()
				task.wait(.1)
				reader.Light.Color = Color3.new(1, 1, 1)
				
				------------------
				doorPrimary.Part.SlidingDoor:Play()
				
				closed = not closed
				if closed == true then
					prompt.ActionText = "Open"
					
					alarmPart.Alarm:Play()
					doorCloseTween:Play()
				else
					prompt.ActionText = "Close"
					
					doorPrimary.Part.Start:Play()
					doorOpenTween:Play()
				end
				
				task.wait(8)
				
				alarmPart.Alarm:Stop()
			else
				reader.Light.Color = Color3.new(1, 0, 0)
				readerPrimary.ReaderDeny:Play()
				task.wait(.1)
				reader.Light.Color = Color3.new(1, 1, 1)
			end
			
			prompt.MaxActivationDistance = 5
			
			cooldown = false
		end
	end
end

prompt.Triggered:Connect(onPromptTriggered)