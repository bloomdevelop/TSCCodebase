local character = script.Parent

local Torso = character:WaitForChild("Torso", 60)

if Torso ~= nil then
	local s = Instance.new('Sound')
	s.RollOffMinDistance = 1
	s.RollOffMaxDistance = 100
	s.Volume = 1
	s.SoundId = "rbxassetid://9727414740"
	s.Parent = Torso
	local l = Instance.new('PointLight')
	l.Parent = Torso
	l.Range = 4
	l.Brightness = 20
	l.Shadows = true
	l.Enabled = true
	s:Play()
	task.wait(5)
	s.Ended:Connect(function()
		s:Destroy()
		l:Destroy()
		script:Destroy()
	end)
	
	return
end
script:Destroy()