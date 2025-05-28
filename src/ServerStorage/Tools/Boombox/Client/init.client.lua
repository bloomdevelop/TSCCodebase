local Player = game:GetService("Players").LocalPlayer

local Draggable = require(script:WaitForChild("Draggable"))

local Tool = script.Parent
local DataRemote = Tool:WaitForChild("Data")
local GUI = Tool:WaitForChild("BoomboxGUI")

local Main = GUI:WaitForChild("Main")
Draggable(Main)

local min, max = math.min, math.max

DataRemote.OnClientInvoke = function(data)
	if data.IsPlaying ~= nil then
		Main.Toggle.Text = data.IsPlaying and "Stop" or "Play"
	end
	if data.IsLooping ~= nil then
		Main.Loop.Text = data.IsLooping and "Unloop" or "Loop"
	end
	if data.Volume ~= nil then
		Main.VolumeAdjust.Text = data.Volume or "1.5"
	end
	if data.SoundId ~= nil then
		Main.AudioID.Text = data.SoundId or ""
	end
	
	Main.LastOwner.Text = data.LastOwner and ("Last Owner: " .. data.LastOwner) or ""
end

Main:WaitForChild("VolumeAdjust").FocusLost:Connect(function()
	DataRemote:InvokeServer({
		Action = "Volume",
		Value = max(min(1.5, tonumber(Main.VolumeAdjust.Text) or 0.1), 0.1)
	})
end)

Main:WaitForChild("AudioID"):GetPropertyChangedSignal("Text"):Connect(function()	
	DataRemote:InvokeServer({
		Action = "AudioId",
		Value = Main.AudioID.Text
	})
end)

Main:WaitForChild("Toggle").Activated:Connect(function()
	local data = DataRemote:InvokeServer({
		Action = "Toggle"
	})

	if not data then return end
	Main.Toggle.Text = data.IsPlaying and "Stop" or "Play"
end)

Main:WaitForChild("Loop").Activated:Connect(function()
	local data = DataRemote:InvokeServer({
		Action = "Loop"
	})

	if not data then return end
	Main.Loop.Text = data.IsLooping and "Unloop" or "Loop"
end)

Main:WaitForChild("Mount").Activated:Connect(function()
	local data = DataRemote:InvokeServer({
		Action = "Mount"
	})

	if not data then return end
	Main.Mount.Text = data.IsMounting and "Unmount" or "Mount"
end)