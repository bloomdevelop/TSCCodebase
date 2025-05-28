-- // Steven_Scripts, 2022

local reader = script.Parent
local primary = reader.PrimaryPart
local light = reader.Light

local lockValue = reader.Parent.ControlsLocked

local lockedLightColor = Color3.new(.5, .4, .4)
local unlockedLightColor = Color3.new(0.1, .8, 1)

local prompt = Instance.new("ProximityPrompt")
prompt.ObjectText = "Lockdown Controls"
prompt.ActionText = "Unlock"
prompt.MaxActivationDistance = 5
prompt.Style = Enum.ProximityPromptStyle.Custom

prompt.Parent = primary

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

local function lock()
	lockValue.Value = true
	light.Color = lockedLightColor
	
	primary.Lock:Play()
	prompt.ActionText = "Unlock"
end

local function unlock()
	lockValue.Value = false
	reader.Light.Color = unlockedLightColor
	
	primary.Lock:Play()
	prompt.ActionText = "Lock"

	---- Auto lock after 20s
	for i=1, 15 do
		task.wait(1)
		if lockValue.Value == false then
			primary.Tick:Play()
		else
			break
		end
	end
	for i=1, 10 do
		task.wait(0.5)
		if lockValue.Value == false then
			primary.Tick:Play()
		else
			break
		end
	end

	if lockValue.Value == false then
		---- Auto lock triggered
		lock()
	end
end

local cooldown = false
prompt.Triggered:Connect(function(plr)
	if cooldown == true then return end

	prompt.MaxActivationDistance = 0

	if checkClearance(plr, 4, "SECURITY-CARD") == true then
		primary.ReaderAccept:Play()
		light.Color = Color3.new(0, 1, 0)

		primary.Lock:Play()

		coroutine.wrap(function()
			if lockValue.Value == true then
				unlock()
			else
				lock()
			end
		end)()

		task.wait(1)
	else
		primary.ReaderDeny:Play()
		light.Color = Color3.new(1, 0, 0)

		task.wait(1)
	end

	if lockValue.Value == true then
		light.Color = lockedLightColor
	else
		light.Color = unlockedLightColor
	end

	cooldown = false
	prompt.MaxActivationDistance = 5
end)