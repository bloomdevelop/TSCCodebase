-- // Steven_Scripts, 2022

local ss = game:GetService("SoundService")
local cs = game:GetService("CollectionService")

local soundStorage = ss.SoundStorage

local plr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera

local mainFolder, statesFolder, speakersFolder

local soundLists = {}

local maxSoundSources = 3

local function moveSound(sound : Sound, newParent, smoothTransition : boolean)
	if sound.IsPlaying == true and smoothTransition == true then
		-- Wait until it loops for a seamless transition
		sound.DidLoop:Wait()
	end
	
	sound.Parent = newParent
end

---- Sorts lowest to highest
local function getSortedTable(t, statName : string)
	local sortedTable = t

	local function swapPositions(index1, index2)
		local value1 = sortedTable[index1]
		local value2 = sortedTable[index2]

		sortedTable[index1] = value2
		sortedTable[index2] = value1
	end

	local lastValue = 0
	local loops = 0

	local sorted = false

	while sorted == false do
		loops = loops+1

		sorted = true
		local lastStat = 0
		for i,info in pairs(sortedTable) do
			local stat = info[statName]

			if i > 1 then
				if stat < lastStat then
					swapPositions(i-1, i)
					sorted = false
				end
			end

			lastStat = stat
		end

		if loops > 100 then
			break
		end
	end
	
	return sortedTable
end

local function prepareSoundLists()
	for i,sound in pairs(soundStorage.Enviroment:GetChildren()) do
		local soundList = {}
		
		for i=1,maxSoundSources do
			local newSound = sound:Clone()
			table.insert(soundList, newSound)
		end
		
		soundLists[sound.Name] = soundList
	end
end

local function updateSpeakers()
	local speakerDistances = {}
	
	---- Get list of all speakers within 2000 studs
	for i,speaker in pairs(speakersFolder:GetChildren()) do
		local speakerPart = speaker:FindFirstChild("SpeakerPart")
		if speakerPart then
			local distanceFromCamera = (cam.CFrame.Position - speakerPart.Position).Magnitude
			if distanceFromCamera < 2000 then
				table.insert(speakerDistances, {Speaker = speaker, Distance = distanceFromCamera})
			end
		end
	end
	
	---- Get closest speakers in the list, up to a count of maxSoundSources
	local sortedSpeakerDistances = getSortedTable(speakerDistances, "Distance")
	
	for i=1, maxSoundSources do
		local speakerInfo = sortedSpeakerDistances[i]
		
		if speakerInfo ~= nil then
			local speaker = speakerInfo.Speaker
			local speakerPart = speaker.SpeakerPart
			
			---- Move alarm sounds into new speaker
			for alarmName, soundList in pairs(soundLists) do
				local sound = soundList[i]
				coroutine.wrap(function()
					moveSound(sound, speakerPart, true)
				end)()
			end
		end
	end
end

local function updateEnvironmentSoundParts()
	local partDistances = {}

	---- Get list of all environment sound parts within 100 studs
	for i,part in pairs(cs:GetTagged("EnvironmentAmbiencePart")) do
		local distanceFromCamera = (cam.CFrame.Position - part.Position).Magnitude
		if distanceFromCamera < 100 then
			table.insert(partDistances, {Part = part, Distance = distanceFromCamera})
		end
	end

	---- Get closest parts in the list, up to a count of maxSoundSources
	local sortedSpeakerDistances = getSortedTable(partDistances, "Distance")

	for index=1, maxSoundSources do
		local partInfo = sortedSpeakerDistances[index]

		if partInfo ~= nil then
			local part = partInfo.Part
			
			-- Get sound
			local soundName = part.EnvironmentAmbience.Value
			local soundList = soundLists[soundName]
			
			-- Move sound into part
			local sound = soundList[index]
			moveSound(sound, part, false)
			
			-- Play sound
			sound:Play()
		end
	end
end

local function onAlarmStateChanged(boolValue)	
	local soundList = soundLists[boolValue.Name]
	
	if boolValue.Value == true then
		---- Alarm turned on
		for i,sound in pairs(soundList) do
			sound:Play()
		end
	else
		---- Alarm turned off
		for i,sound in pairs(soundList) do
			sound:Stop()
		end
	end
end

mainFolder = workspace:WaitForChild("AlarmSystem")

statesFolder = mainFolder:WaitForChild("States")
speakersFolder = mainFolder:WaitForChild("Speakers")

---- Initializing
prepareSoundLists()
updateSpeakers()
for i,boolValue in pairs(statesFolder:GetChildren()) do
	boolValue:GetPropertyChangedSignal("Value"):Connect(function()
		onAlarmStateChanged(boolValue)
	end)

	onAlarmStateChanged(boolValue)
end

while task.wait(3) do
	updateSpeakers()
	updateEnvironmentSoundParts()
end