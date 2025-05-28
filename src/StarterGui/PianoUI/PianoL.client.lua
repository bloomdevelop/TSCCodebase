-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local cs = game:GetService("CollectionService")

local remotesFolder

local plr = game.Players.LocalPlayer

local animationTracks = {}

-- BPM, animation name
local playAnimations = {
	{50, "BPM50"},
	{100, "BPM100"},
	{150, "BPM150"},
	{200, "BPM200"}
}

local currentPlayAnimation = nil -- String representing the name of the current playing animation

local pianoSongs

local animationsFolder = script.Animations

local ui = script.Parent

local main = ui.Main

local beatSetter = main.BeatSetter

-- The closer it is to the first index, the more recent it is
local recentBeats = {}
local maxBeats = 9

local bpm = 0

-- Further means more recent here
-- I know it's inconsistent but shut up at least it works
local allBeats = {}

local songNameList = {}
local selectedSongIndex = 1

local playing = false
local autoplaying = false

local songInfo = nil
local currentPiano = nil

local function getPauses(timestamps, reverse)
	local pauses = {}
	
	-- First beat's pause isn't calculated due to having nothing to compare it to
	for i=2,#timestamps do
		local timestamp = timestamps[i]
		
		local pause
		if reverse then
			pause = timestamps[i] - timestamps[i-1]
		else
			pause = timestamps[i-1] - timestamps[i]
		end

		pauses[i-1] = pause
	end
	
	return pauses
end

local function getAveragePause(timestamps, reverse)
	local averagePause = 0
	
	if #timestamps == 1 then
		-- We literally can't calculate this you dolt
		return 0
	end
	
	local pauses = getPauses(timestamps, reverse)
	
	for i,pause in pairs(pauses) do
		averagePause = averagePause+pause
	end
	averagePause = averagePause/#pauses
	
	return averagePause, pauses
end

local function updatePlayingAnimation()
	local newAnimation = nil
	
	if bpm > 0 then
		local song = currentPiano.Piano.Keys.Song
		
		local closestDistance = 1000000000
		
		local newAnimationBPM = 0
		for i,animationInfo in pairs(playAnimations) do
			local distance = math.abs(animationInfo[1] - bpm)
			if distance < closestDistance then
				closestDistance = distance
				
				newAnimationBPM = animationInfo[1]
				newAnimation = animationInfo[2]
			else
				-- This table is sorted from lowest to highest.
				-- It'll only get further away from here.
				break
			end
		end
		
		local animationSpeed
		if song.PlaybackLoudness < 10 then
			animationSpeed = 0.05
		else
			animationSpeed = bpm/newAnimationBPM
		end
		
		if newAnimation ~= currentPlayAnimation then
			if currentPlayAnimation ~= nil then
				animationTracks[currentPlayAnimation]:Stop(0.5)
			end
			animationTracks[newAnimation]:Play(0.5, 1, animationSpeed)
		else
			animationTracks[currentPlayAnimation]:AdjustSpeed(animationSpeed)
		end
	else
		if currentPlayAnimation ~= nil then
			animationTracks[currentPlayAnimation]:Stop()
		end
	end
	
	currentPlayAnimation = newAnimation
end

local function stopPlaying()
	recentBeats = {}
	bpm = 0
	
	allBeats = {}
	
	playing = false
	autoplaying = false
	
	main.Start.Visible = false
	main.Autoplay.Visible = true
	main.SongSelection.Visible = true
	
	main.BPM.Text = ""
	
	updatePlayingAnimation()
	remotesFolder.Piano.Stop:FireServer()
end

local function startPlaying()
	playing = true

	main.Start.Visible = false
	main.Autoplay.Visible = false
	main.SongSelection.Visible = false
	main.Results.Visible = false
	
	updatePlayingAnimation()
	remotesFolder.Piano.Start:FireServer()
end

local function showResults()
	local mean, pauses = getAveragePause(allBeats, true)
	
	local variance = 0
	for i,pause in pairs(pauses) do
		local deviation = (pause - mean)^2
		variance = variance+deviation
	end
	variance = variance/#pauses
	
	local standardDeviation = math.sqrt(variance)
	
	main.Results.SongPlayed.Text = "Song played: "..songNameList[selectedSongIndex]
	main.Results.BPM.Text = "Average BPM: "..math.round((60/mean)*10)/10
	main.Results.Deviation.Text = "Beat deviation: "..(math.round(standardDeviation*1000)/1000).."s"
	main.Results.Visible = true
end

local function onSongEnded()
	showResults()
	stopPlaying()
end

local function beat()
	if currentPiano == nil then return end
	
	if #recentBeats == maxBeats then
		-- Remove oldest
		recentBeats[maxBeats] = nil
	end
	
	-- Shift all beats one index forward
	local newBeats = {}
	for i=1,#recentBeats do
		local timestamp = recentBeats[i]
		newBeats[i+1] = timestamp
	end
	
	-- Add beat
	local timestamp = os.clock()
	newBeats[1] = timestamp
	recentBeats = newBeats
	
	-- Record if playing
	if playing == true then
		table.insert(allBeats, timestamp)
	end
	
	local averagePause, _ = getAveragePause(recentBeats)
	
	if averagePause > 0 then
		local song = currentPiano.Piano.Keys.Song
		
		bpm = math.round(60/averagePause)
		
		if bpm > 500 then
			main.BPM.Text = "GEEZ, RELAX"
		else
			main.BPM.Text = bpm.." BPM"
		end
		
		-- Regular playback speed * (Player's BPM/Intended BPM)
		local playbackSpeed = songInfo.PlaybackSpeed * bpm/songInfo.BPM
		
		-- Don't change if the speed change is less than 0.1
		if math.abs(song.PlaybackSpeed-playbackSpeed) > 0.1 then
			remotesFolder.Piano.AdjustSpeed:FireServer(playbackSpeed)
		end
		
		if playing == true then
			if song.IsPaused == true or song.IsPlaying == false then
				remotesFolder.Piano.Start:FireServer()
			end
		else
			if #recentBeats == maxBeats then
				main.Start.Visible = true
				main.Autoplay.Visible = false
			end
		end
	else
		bpm = 0
	end
	
	coroutine.wrap(function()
		task.wait(2)
		if recentBeats[1] == timestamp then
			-- Player still hasn't inputted a new beat. Stop playing.
			stopPlaying()
		end
	end)()
	
	---- Animations
	if playing == true then
		updatePlayingAnimation()
	end
	
	---- Fancy visuals
	local fill = beatSetter.Fill:Clone()
	fill.BackgroundTransparency = 0
	fill.Parent = beatSetter
	
	script.Beat:Play()
	
	for i=0,1,.1 do
		task.wait()
		fill.BackgroundTransparency = i
		fill.Size = UDim2.new(1+i/1.5, 0, 1+i/1.5, 0)
	end
	fill:Destroy()
end

local function onInputBegan(inputObject, processed)
	if processed then return end
	
	if playing == false and #recentBeats == maxBeats and inputObject.KeyCode == Enum.KeyCode.F then
		startPlaying()
	elseif inputObject.KeyCode == Enum.KeyCode.E and autoplaying == false then
		beat()
	end
end

local function selectSong(songName, songIndex)
	if playing == true then
		stopPlaying()
	end
	
	if songIndex == nil then
		songIndex = table.find(songNameList, songName)
	end
	selectedSongIndex = songIndex
	
	main.SongSelection.SongName.Text = songName
	
	songInfo = pianoSongs[songName]
	
	remotesFolder.Piano.SelectSong:FireServer(songName)
end

local function selectNextSong()
	selectedSongIndex = selectedSongIndex+1
	if selectedSongIndex > #songNameList then
		selectedSongIndex = 1
	end
	
	selectSong(songNameList[selectedSongIndex], selectedSongIndex)
end

local function selectPreviousSong()
	selectedSongIndex = selectedSongIndex-1
	if selectedSongIndex < 1 then
		selectedSongIndex = #songNameList
	end
	
	selectSong(songNameList[selectedSongIndex], selectedSongIndex)
end

local endedConnection
local function selectPiano(model)
	if endedConnection then endedConnection:Disconnect() end
	currentPiano = model
	
	if model == nil then
		-- Cancel
		animationTracks.Idle:Stop()
		
		main.Visible = false
		if playing then stopPlaying() end
	else
		animationTracks.Idle:Play()
		
		main.Visible = true
		main.SongSelection.Visible = true
		
		selectSong(model:GetAttribute("SelectedSong"))
		
		endedConnection = currentPiano.Piano.Keys.Song.Ended:Connect(onSongEnded)
	end
end

local function characterAdded(char)
	local hum = char:WaitForChild("Humanoid")
	
	animationTracks = {}
	for i,animation in pairs(animationsFolder:GetChildren()) do
		local track = hum.Animator:LoadAnimation(animation)
		animationTracks[animation.Name] = track
	end
	
	hum.Died:Connect(function()
		selectPiano(nil)
	end)
	
	hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
		local seat = hum.SeatPart
		
		if seat and table.find(cs:GetTags(seat.Parent.Parent), "PianoInteractable") ~= nil then
			local piano = seat.Parent.Parent
			selectPiano(piano)
		else
			selectPiano(nil)
		end
	end)
end

local function autoplay()
	if playing == true then return end
	
	autoplaying = true
	
	startPlaying()
	remotesFolder.Piano.AdjustSpeed:FireServer(songInfo.PlaybackSpeed)
	
	main.Visible = false
end

local modulesFolder = rst:WaitForChild("Modules")
pianoSongs = require(modulesFolder:WaitForChild("PianoSongs"))

local index = 0
for songName,_ in pairs(pianoSongs) do
	index = index+1
	songNameList[index] = songName
end

remotesFolder = rst:WaitForChild("Remotes")

beatSetter.MouseButton1Down:Connect(beat)
main.Start.Activated:Connect(startPlaying)
main.Autoplay.Activated:Connect(autoplay)

main.SongSelection.Next.Activated:Connect(selectNextSong)
main.SongSelection.Previous.Activated:Connect(selectPreviousSong)

uis.InputBegan:Connect(onInputBegan)

plr.CharacterAdded:Connect(characterAdded)
if plr.Character ~= nil then
	characterAdded(plr.Character)
end