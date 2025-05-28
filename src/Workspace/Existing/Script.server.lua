local rightCf = CFrame.Angles(0, math.rad(90), 0)
local leftCf = CFrame.Angles(0, math.rad(-180), 0)

script.Parent.ProximityPrompt.Triggered:Connect(function(player)
	script.Parent.ProximityPrompt.Enabled = false

	script.Parent.Song:Play()

	repeat
		script.Parent.CFrame*= rightCf
		task.wait(1)
		script.Parent.CFrame*= leftCf
		task.wait(1)
	until script.Parent.Song.TimePosition == script.Parent.Song.TimeLength

	script.Parent.ProximityPrompt.Enabled = true
end)