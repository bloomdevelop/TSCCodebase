-- // Steven_Scripts, 2022

-- Note: Region boxes DO NOT account for orientation.
-- They will be treated as if they are always at an
-- orientation of 0, 0, 0.

local tws = game:GetService("TweenService")
local rst = game:GetService("ReplicatedStorage")
local ss = game:GetService("SoundService")

local lighting = game:GetService('Lighting')

lighting.Brightness = 0
lighting.ClockTime = 24
lighting.GeographicLatitude = 5
lighting.EnvironmentDiffuseScale = 0
lighting.EnvironmentSpecularScale = 1
lighting.GlobalShadows = true
lighting.ColorShift_Top = Color3.new(0,0,0)
lighting.ColorShift_Bottom = Color3.new(0,0,0)
lighting.Ambient = Color3.fromRGB(20, 20, 20)
lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30)

local inside = lighting.Inside
local outside = lighting.Outside

local plr = game.Players.LocalPlayer

local cam = workspace.CurrentCamera

local soundStorage = ss.SoundStorage

local infectedCheck = require(rst.InfectedCheckModule)

local populatedAmount = 10

local spookiness = 0
local maxSpookiness = 3

local modulesFolder = rst.Modules

local regionInfoDir = require(modulesFolder.RegionInfo)
local defaultRegionInfo = {
	Spookiness = 0,
	AmbientReverb = Enum.ReverbType.Hallway
}

local regionsFolder = rst.Regions

local regionBoxesDir = {}
for i,regionPart in pairs(regionsFolder:GetChildren()) do
	local regionBoxes = regionBoxesDir[regionPart.Name]
	if not regionBoxes then
		regionBoxes = {}
		regionBoxesDir[regionPart.Name] = regionBoxes
	end

	table.insert(regionBoxes, 
		{
			regionPart.Position - regionPart.Size/2, -- Min
			regionPart.Position + regionPart.Size/2 -- Max
		}
	)
end

local currentRegionName = nil
local currentRegionInfo = defaultRegionInfo

local currentRegionValue = Instance.new("StringValue")
currentRegionValue.Name = "CurrentRegion"
currentRegionValue.Parent = plr

local rng = Random.new()

local function getArmedLevel()
	local inventory = plr.Backpack:GetChildren()
	local heldTool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")

	if heldTool then table.insert(inventory, heldTool) end

	local armedLevel = 0
	-- 0 = Unarmed
	-- 1 = Armed with melee
	-- 2 = Armed with firearm

	for i,tool in pairs(inventory) do
		if tool.Name ~= "Fists" then
			local gunData = tool:FindFirstChild("GunData") and require(tool.GunData)
			if gunData then
				local isMelee = gunData.Charge ~= nil
				if isMelee and armedLevel == 0 then
					armedLevel = 1
				else
					armedLevel = 2
					-- Can't get any higher
					break
				end
			end
		end
	end

	return armedLevel
end

local function getHealth()
	local char = plr.Character
	if char then
		return char:WaitForChild("Humanoid").Health
	else
		return 100
	end
end

local function updateSpookiness()
	local newSpookiness = maxSpookiness

	-- Survivors and infected
	local survivors = 0
	local infected = 0
	for i,checkingPlr in pairs(game.Players:GetPlayers()) do
		if checkingPlr ~= plr then
			local checkingChar = checkingPlr.Character

			if checkingChar then
				local checkingRoot = checkingChar:FindFirstChild("HumanoidRootPart")

				if checkingRoot and (checkingRoot.Position - cam.CFrame.Position).Magnitude < 500 then
					if infectedCheck(checkingPlr) == false then
						survivors = survivors+1
					else
						infected = infected+1
					end
				end
			end
		end
	end

	local loneliness = 1 - ((survivors-infected)/populatedAmount)
	loneliness = math.clamp(loneliness, 0, 1)
	newSpookiness = newSpookiness*loneliness

	-- Armed status
	local armedLevel = getArmedLevel()
	if armedLevel == 0 then
		-- Unarmed. More spooky.
		newSpookiness = newSpookiness + 0.7
	elseif armedLevel == 2 then
		-- Armed with gun. Less spooky.
		newSpookiness = newSpookiness - 0.7
	end

	-- Health
	local health = getHealth()

	if health < 50 then
		-- Injured. More spooky.
		newSpookiness = newSpookiness + 0.7
	elseif health > 200 then
		-- Increased health. Less spooky.
		newSpookiness = newSpookiness - 0.7
	end

	-- Region
	local regionModifier = currentRegionInfo.Spookiness
	newSpookiness = newSpookiness + regionModifier

	-- Clamp and round to nearest integer
	newSpookiness = math.clamp(newSpookiness, 0, maxSpookiness)
	newSpookiness = math.floor(newSpookiness)

	-- Set
	spookiness = newSpookiness
end

local outdoorTween = tws:Create(lighting, TweenInfo.new(5), {
	Brightness = 3,
	ClockTime = 12.804,
	GeographicLatitude = 317,
	
	Ambient = Color3.new(0, 0, 0),
	OutdoorAmbient = Color3.new(0, 0, 0),
	
	EnvironmentSpecularScale = 0,
})

local indoorTween = tws:Create(lighting, TweenInfo.new(5), {
	Brightness = 0,
	ClockTime = 23.757,
	GeographicLatitude = 5,
	
	Ambient = Color3.fromRGB(20, 20, 20),
	OutdoorAmbient = Color3.fromRGB(30, 30, 30),
	
	EnvironmentSpecularScale = 1,
})

local function getAmbientSounds(ambientType)
	if currentRegionName ~= "Outdoors" then
		-- Indoors
		local possibleSounds = soundStorage.Ambience.Universal[ambientType]:GetChildren()

		local mainFolder = soundStorage.Ambience.SpookinessLevels[tostring(spookiness)][ambientType]
		for i,sound in pairs(mainFolder:GetChildren()) do
			table.insert(possibleSounds, sound)
		end

		if spookiness >= 1 then
			local genericFolder = soundStorage.Ambience.GenericSpooky[ambientType]
			for i,sound in pairs(genericFolder:GetChildren()) do
				table.insert(possibleSounds, sound)
			end
		end

		return possibleSounds
	else
		-- Outdoors
		local possibleSounds = soundStorage.Ambience.Outdoors[ambientType]:GetChildren()
		
		return possibleSounds
	end
end

local function checkForTSCZLockdown()
	local door = workspace.TSCZLockdown:FindFirstChild("ADoor")
	if door == nil then return false end

	return door:FindFirstChild("Lockdown") ~= nil
end

local function playAmbience()
	if currentRegionName ~= nil and string.sub(currentRegionName, 1, 4) == "TSCZ" and checkForTSCZLockdown() == true then
		-- TSCZ lockdown music is already playing
		return 30
	end
	
	local activeAmbientSounds = getAmbientSounds("Active")
	local passiveAmbientSounds = getAmbientSounds("Passive")

	local playPassive = rng:NextInteger(1, #activeAmbientSounds+#passiveAmbientSounds) > #activeAmbientSounds

	if playPassive then
		-- Play passive ambience
		local sound = passiveAmbientSounds[rng:NextInteger(1, #passiveAmbientSounds)]
		sound:Play()

		return sound.TimeLength / sound.PlaybackSpeed
	else
		-- Play active ambience
		local soundPart = Instance.new("Part")
		soundPart.Name = "AmbientSoundPart"

		soundPart.Archivable = false 

		soundPart.Anchored = true

		soundPart.CanCollide = false
		soundPart.CanTouch = false
		soundPart.CanQuery = false

		soundPart.Transparency = 1

		soundPart.CFrame = cam.CFrame + Vector3.new(rng:NextNumber(-100, 100), rng:NextNumber(-50, 50), rng:NextNumber(-100, 100))

		local sound = activeAmbientSounds[rng:NextInteger(1, #activeAmbientSounds)]:Clone()
		sound.Parent = soundPart

		soundPart.Parent = workspace

		sound:Play()

		game.Debris:AddItem(soundPart, sound.TimeLength / sound.PlaybackSpeed)

		return 0
	end
end

local function getPositionIsInBox(position, boxMin, boxMax)
	if (position.X > boxMin.X) and (position.Y > boxMin.Y) and (position.Z > boxMin.Z) and (position.X < boxMax.X) and (position.Y < boxMax.Y) and (position.Z < boxMax.Z) then -- dear lord
		return true
	else
		return false
	end
end

local function getPositionIsInRegion(position, regionName)
	local regionBoxes = regionBoxesDir[regionName]
	
	for i,regionBox in pairs(regionBoxes) do
		local isInBox = getPositionIsInBox(position, regionBox[1], regionBox[2])
		if isInBox then
			return true
		end
	end
	
	return false
end

local function updateRegion()
	local position = cam.CFrame.Position
	
	-- TSCZ lockdown music
	if currentRegionName ~= nil and string.sub(currentRegionName, 1, 4) == "TSCZ" and checkForTSCZLockdown() == true then
		if soundStorage.Music.TSCZLockdown.IsPlaying == false then
			soundStorage.Music.TSCZLockdown:Play()
		end
	else
		if soundStorage.Music.TSCZLockdown.IsPlaying == true then
			soundStorage.Music.TSCZLockdown:Stop()
		end
	end
	
	if currentRegionName ~= nil then
		-- Don't change regions if the player is still within the bounds
		-- of their current region; current region should take priority.
		local stillInSameRegion = getPositionIsInRegion(position, currentRegionName)
		if stillInSameRegion then return end
	end
	
	local newRegionName = nil
	
	for regionName,regionBoxes in pairs(regionBoxesDir) do
		if regionName ~= currentRegionName then
			local isInRegion = getPositionIsInRegion(position, regionName)
			if isInRegion then
				newRegionName = regionName
				break
			end
		end
	end

	if newRegionName == currentRegionName then
		-- Region hasn't changed.
		return
	end

	local newRegionInfo
	if newRegionName ~= nil then
		newRegionInfo = regionInfoDir[newRegionName]

		-- Set all empty values to defaults
		for property,value in pairs(defaultRegionInfo) do
			if newRegionInfo[property] == nil then
				newRegionInfo[property] = value
			end
		end
		
		-- Outdoor ambience
		if newRegionName == "Outdoors" then
			outdoorTween:Play()
			
			if lighting:FindFirstChild("InsideSky") then
				lighting.InsideAtmosphere.Parent = inside
				lighting.InsideSky.Parent = inside
			end
			
			for _,v in pairs(outside:GetChildren()) do
				v.Parent = lighting
			end
			
			for i,sound in pairs(script.OutsideAmbience:GetChildren()) do
				sound:Play()
			end
		else
			indoorTween:Play()
			
			if lighting:FindFirstChild("OutsideSky") ~= nil then
				lighting.OutsideAtmosphere.Parent = outside
				lighting.OutsideSky.Parent = outside
			end
			
			for _,v in pairs(inside:GetChildren()) do
				v.Parent = lighting
			end
			
			for i,sound in pairs(script.OutsideAmbience:GetChildren()) do
				sound:Stop()
			end
		end
	else
		-- Use defaults
		newRegionInfo = defaultRegionInfo
	end
	
	currentRegionName = newRegionName
	currentRegionInfo = newRegionInfo
	
	currentRegionValue.Value = newRegionName or ""

	ss.AmbientReverb = newRegionInfo.AmbientReverb
end

local nextAmbienceTime = os.time()
while true do
	task.wait(1)

	-- Update region
	updateRegion()

	if os.time() >= nextAmbienceTime then
		-- Play ambience
		updateSpookiness()

		local ambiencePause = playAmbience()

		-- Schedule next ambient sound
		nextAmbienceTime = os.time() + rng:NextNumber(5, 60*2) + ambiencePause
	end
end