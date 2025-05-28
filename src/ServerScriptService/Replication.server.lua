local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local RemotesFolder = ReplicatedStorage.Remotes
local ModulesFolder = ReplicatedStorage.Modules

local DoorToolInfoDir = require(ModulesFolder.DoorTools)

--CLEARANCE TREE
local function makeClientClearanceTree()
	local newClearanceTree = ServerStorage.CLEARANCE_TREE:Clone()
	for i,folder in pairs(newClearanceTree:GetChildren()) do
		for i,tool in pairs(folder:GetChildren()) do
			local val = Instance.new("BoolValue")
			val.Name = tool.Name
			val.Parent = folder

			tool:Destroy()
		end
	end

	newClearanceTree.Parent = ReplicatedStorage
end

makeClientClearanceTree()

--RADIO
ReplicatedStorage.RadioEvents.ServerRadioEvent.OnServerEvent:Connect(function(plr,msg,freq,encryp)
	--if plr.PlayerGui:FindFirstChild("Radio") then -- this wont work because Server cannot get the gui that the player has
	ReplicatedStorage.RadioEvents.ClientRadioEvent:FireAllClients(plr.Name,game.Chat:FilterStringAsync(msg,plr,plr),freq,encryp)
	--end
end)

--DOORS
local doorTagName = "DoorInteractable"
local cabinetTagName = "MinesweeperCabinet"

local interactRange = 20
local maxDoorHits = 6

local function checkClearance(plr, requiredClearance)
	local char = plr.Character

	if char then
		local inventory = plr.Backpack:GetChildren()
		local heldTool = char:FindFirstChildOfClass("Tool")
		if heldTool then
			table.insert(inventory, heldTool)
		end

		for i,tool in ipairs(inventory) do
			if tool.Name == "Omni-Card" then return true end
		end

		if tonumber(requiredClearance) ~= nil then
			-- Clearance level check
			if requiredClearance == 0 then
				-- This isn't clearance locked
				return true
			end

			local clearanceFolder = ServerStorage.CLEARANCE_TREE:FindFirstChild(tostring(requiredClearance))
			if clearanceFolder == nil then
				-- This clearance level doesn't exist
				return false
			end

			for i,tool in ipairs(inventory) do
				if clearanceFolder:FindFirstChild(tool.Name) then
					return true
				end
			end
		else
			-- Checking for a specific card/tool
			for i,tool in pairs(inventory) do
				if tool.Name == requiredClearance then
					return true
				end
			end
		end
	end

	return false
end

local function checkClearanceForDoor(plr, door)
	local clearance = door.ClearanceLevel

	local ors = {}
	local ands = {}

	for i,v in pairs(clearance:GetChildren()) do
		if v.Name == "or" then
			table.insert(ors, v)
		elseif v.Name == "and" then
			table.insert(ands, v)
		end
	end

	local clearanceAllowed = false
	if checkClearance(plr, clearance.Value) == true then
		clearanceAllowed = true
	else
		-- Regular clearance level won't cut it, check if the player has any of the alternatives
		for i,v in pairs(ors) do
			if checkClearance(plr, v.Value) == true then
				clearanceAllowed = true
				break
			end
		end
	end

	if clearanceAllowed == true then
		for i,v in pairs(ands) do
			if checkClearance(plr, v.Value) == false then
				-- Disqualify clearance for not meeting all "and" requirements
				clearanceAllowed = false
				break
			end
		end
	end

	return clearanceAllowed, clearance.Value, ands
end

local function getDoorTool(plr)
	local heldTool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
	if heldTool then
		local toolInfo = DoorToolInfoDir[heldTool.Name]
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

function doorIsWithinInteractRange(plr, door, range)
	local char = plr.Character
	if char == nil then return false end

	local root = char:FindFirstChild("HumanoidRootPart")
	if root == nil then return false end

	local hum = char:FindFirstChild("Humanoid")
	if hum == nil then return false end

	if hum.Health == 0 then
		--  I know it makes no sense to do the health check here but shut up it works
		-- 	~steven
		return false
	end

	range = range or interactRange

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
			if distance <= range then
				return true
			end
		end
	end

	return false
end

local function changeDoorState(door, animationSpeed, playSound)
	animationSpeed = animationSpeed or 1

	door.Closed.Value = not door.Closed.Value

	RemotesFolder.Doors.DoorStateChanged:FireAllClients(door, animationSpeed)

	local TweenSpeed = door:FindFirstChild("TweenSpeed") and door.TweenSpeed.Value or 0.5

	local OnCooldown = Instance.new("BoolValue")
	OnCooldown.Name = "OnCooldown"
	OnCooldown.Value = true
	OnCooldown.Parent = door

	local hitsLeft = door:FindFirstChild("HitsLeft")
	if hitsLeft then
		hitsLeft.Value = maxDoorHits
	end

	if playSound then
		door.PrimaryPart.OpenSound:Play()
		if door.PrimaryPart:FindFirstChild("Impact") then
			door.PrimaryPart.Impact:Play()
		end
	end

	if door.Closed.Value then
		-- Close door
		task.wait(TweenSpeed/animationSpeed * 1.1)

		door.LDoor.PrimaryPart.CFrame = door.LDoorClosed.CFrame
		if door:FindFirstChild("RDoor") then
			door.RDoor.PrimaryPart.CFrame = door.RDoorClosed.CFrame
		end
	else
		-- Open door

		-- Turn off alarm if there's one playing
		if door.PrimaryPart:FindFirstChild("Alarm") ~= nil then
			door.PrimaryPart.Alarm:Destroy()
		end

		task.wait(TweenSpeed/animationSpeed * 1.1)

		door.LDoor.PrimaryPart.CFrame = door.LDoorOpen.CFrame
		if door:FindFirstChild("RDoor") then
			door.RDoor.PrimaryPart.CFrame = door.RDoorOpen.CFrame
		end
	end

	OnCooldown:Destroy()
end

ReplicatedStorage.CameraFunction.OnServerInvoke = function()
	local cameraTable = {}
	for i,v in pairs(workspace.SecCameras:GetChildren())do
		table.insert(cameraTable, v.Base.CFrame)
	end
	return cameraTable
end

RemotesFolder.Doors.InteractEvent.OnServerInvoke = function(plr, door)
	if door and door:FindFirstChild("OnCooldown") == nil and doorIsWithinInteractRange(plr, door) then
		if door:FindFirstChild("Jammed") then
			return {
				Success = false,
				Type = "Jammed"
			}
			--elseif false and door:FindFirstChild("LockOnLockdown") then -- TODO: Implement a logic to check if lockdown is in
		elseif door:FindFirstChild("Lockdown") then
			return {
				Success = false,
				Type = "Lockdown"
			}
		else
			local haveClearance, clearanceLevel, andClearances = checkClearanceForDoor(plr, door)

			if not haveClearance then
				task.spawn(function()
					local sound = script.AccessDenied:Clone()
					sound.Parent = door.PrimaryPart
					sound:Play()
					sound.Ended:Wait()
					sound:Destroy()
				end)

				local cl = tonumber(clearanceLevel)

				local noPrefix

				local formatArgs
				if #andClearances > 0 then
					formatArgs = {andClearances[1].Value}
					noPrefix = true
				elseif cl ~= nil then
					formatArgs = {cl}
				end

				return {
					Success = false,
					Type = "NoClearance",
					FormatArgs = formatArgs,
					NoPrefix = noPrefix
				}
			else
				changeDoorState(door, 1, true)
				return {
					Success = true
				}
			end
		end
	end
end

local RNG = Random.new()

local toolFunctions = {
	["Battering Ram"] = function(plr : Player, door : Model, tool : Tool)
		local OnCooldown = Instance.new("BoolValue")
		OnCooldown.Name = "OnCooldown"
		OnCooldown.Value = true
		OnCooldown.Parent = door

		local hitsLeft = door:FindFirstChild("HitsLeft")
		if hitsLeft == nil then
			hitsLeft = Instance.new("IntValue")
			hitsLeft.Name = "HitsLeft"

			hitsLeft.Value = maxDoorHits

			hitsLeft.Parent = door
		end

		hitsLeft.Value = hitsLeft.Value - 1

		local bashSound
		if hitsLeft.Value > 0 then
			bashSound = script["Bash"..RNG:NextInteger(1, 2)]:Clone()
			bashSound.PlaybackSpeed = RNG:NextNumber(1.4, 1.6)
		else
			hitsLeft.Value = maxDoorHits

			bashSound = script.FinalBash:Clone()
			bashSound.TimePosition = 0.1

			changeDoorState(door, 4, false)
		end

		bashSound.Parent = door.LDoor.PrimaryPart
		bashSound:Play()
		game.Debris:AddItem(bashSound, bashSound.TimeLength/bashSound.PlaybackSpeed)

		task.wait(1.5)

		OnCooldown:Destroy()
	end,

	["Keycard Scrambler"] = function(plr : Player, door : Model, tool : Tool)
		local hackingPointer = plr:FindFirstChild("HackingDoor")
		if hackingPointer ~= nil then
			-- Player is already hacking a door
			return
		end

		-- Start hack
		hackingPointer = Instance.new("ObjectValue")
		hackingPointer.Name = "HackingDoor"
		hackingPointer.Value = door

		hackingPointer.Parent = plr

		local char = plr.Character
		local hum = char.Humanoid
		local root = char.HumanoidRootPart

		-- Notify client
		RemotesFolder.Doors.StartHack:FireClient(plr, door)

		while hackingPointer.Parent == plr do
			task.wait(.06666) -- 15 FPS
			if doorIsWithinInteractRange(plr, door, interactRange/2) == false or char:FindFirstChild("Keycard Scrambler") == nil then
				-- Cancel hack
				hackingPointer:Destroy()
				RemotesFolder.Doors.StopHack:FireClient(plr)
				break
			end
		end
	end,
}

RemotesFolder.Doors.SecondaryInteractEvent.OnServerEvent:Connect(function(plr, door)
	if door and door:FindFirstChild("OnCooldown") == nil and doorIsWithinInteractRange(plr, door) then
		local tool, toolInfo = getDoorTool(plr)
		if tool ~= nil and canUseDoorTool(toolInfo, door) then
			local f = toolFunctions[tool.Name]
			if f ~= nil then f(plr, door, tool) end
		end
	end
end)

RemotesFolder.Doors.StartHack.OnServerEvent:Connect(function(plr, door : Model)
	-- This should only ever be used with the arcade cabinets.
	local hackingPointer = plr:FindFirstChild("HackingDoor")
	
	if hackingPointer == nil then
		local doorTags = CollectionService:GetTags(door)
		if table.find(doorTags, cabinetTagName) then
			-- Since this is for practice, the client is trusted with handling a lot of things. All we need to do is record
			-- the arcade cabinet they're practicing with.
			hackingPointer = Instance.new("ObjectValue")
			hackingPointer.Name = "HackingDoor"
			hackingPointer.Value = door

			hackingPointer.Parent = plr
		end
	end
end)

RemotesFolder.Doors.StopHack.OnServerEvent:Connect(function(plr, won)
	local hackingPointer = plr:FindFirstChild("HackingDoor")
	if hackingPointer and hackingPointer.Value ~= nil then
		local door = hackingPointer.Value
		
		local doorTags = CollectionService:GetTags(door)
		
		if table.find(doorTags, doorTagName) then
			-- This is a real door
			local tool = plr.Character:FindFirstChild("Keycard Scrambler")
			if tool then
				if won == true then
					changeDoorState(door, 1, true)
				elseif won == false then
					local char = plr.Character
					local hum = char.Humanoid

					hum:TakeDamage(20)

					if tool.ActiveUpgrades.Silencer.Value == false then
						local alarmSound = script.Alarm:Clone()
						alarmSound.Parent = door.PrimaryPart
						alarmSound:Play()

						game.Debris:AddItem(alarmSound, alarmSound.TimeLength)
					end
				end
			end
		elseif table.find(doorTags, cabinetTagName) then
			-- This is a practice "door"
			local screen = door.Screen
			local neon = screen.Neon
			
			if won == true then
				neon.Color = Color3.new(0, 1, 0) -- Won
			elseif won == false then
				neon.Color = Color3.new(1, 0, 0) -- Lost
			else
				neon.Color = Color3.new(0.5, 0.5, 0.5) -- Cancelled game
			end
			neon.SurfaceLight.Color = neon.Color
			
			task.delay(.2, function()
				neon.Color = Color3.new(1, 1, 1)
				neon.SurfaceLight.Color = neon.Color
			end)
		end
		
		hackingPointer:Destroy()
	end
end)