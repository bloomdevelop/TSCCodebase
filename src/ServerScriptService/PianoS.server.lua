-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")

local remotesFolder

local pianoSongs

local function getCurrentPiano(plr)
	local char = plr.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			local seat = hum.SeatPart
			if seat then
				local piano = seat.Parent.Parent
				if table.find(cs:GetTags(piano), "PianoInteractable") ~= nil then
					return piano
				end
			end
		end
	end
end

local function onSongSelectRequest(plr, songName)
	local piano = getCurrentPiano(plr)
	if piano then
		local songInfo = pianoSongs[songName]
		if songInfo then
			piano:SetAttribute("SelectedSong", songName)
			
			piano.Piano.Keys.Song.SoundId = "rbxassetid://"..songInfo.Audio
			
			piano.Piano.SheetMusic.FlipSound:Play()
			piano.Piano.SheetMusic.Decal.Texture = "rbxassetid://"..songInfo.Sheet
		end
	end
end

local function onStartSongRequest(plr)
	local piano = getCurrentPiano(plr)
	if piano then
		local songName = piano:GetAttribute("SelectedSong")
		local songInfo = pianoSongs[songName]
		
		piano.Piano.Keys.Song:Play()
	end
end

local function onStopSongRequest(plr)
	local piano = getCurrentPiano(plr)
	if piano then
		piano.Piano.Keys.Song:Stop()
	end
end

local function onAdjustSpeedRequest(plr, playbackSpeed)
	local piano = getCurrentPiano(plr)
	if piano then
		playbackSpeed = math.clamp(playbackSpeed, 0.1, 3)
		piano.Piano.Keys.Song.PlaybackSpeed = playbackSpeed
	end
end

remotesFolder = rst:WaitForChild("Remotes")

remotesFolder.Piano.Stop.OnServerEvent:Connect(onStopSongRequest)
remotesFolder.Piano.Start.OnServerEvent:Connect(onStartSongRequest)
remotesFolder.Piano.SelectSong.OnServerEvent:Connect(onSongSelectRequest)
remotesFolder.Piano.AdjustSpeed.OnServerEvent:Connect(onAdjustSpeedRequest)

local modulesFolder = rst:WaitForChild("Modules")
pianoSongs = require(modulesFolder:WaitForChild("PianoSongs"))

for i,piano in pairs(cs:GetTagged("PianoInteractable")) do
	local seat = piano.Bench.Seat
	
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = seat.Occupant
		if occupant == nil then
			piano.Piano.Keys.Song:Stop()
		end
	end)
end