local weld: Weld? = nil
local track: AnimationTrack? = nil
local anim = script.Parent.Animation

script.Parent.ChildAdded:Connect(function(inst: Instance)
	if inst.Name == 'SeatWeld' then
		weld = inst
		track = ((weld.Part1.Parent:FindFirstChild('Humanoid') :: Humanoid) :: any):LoadAnimation(anim)
		track:Play()
	end
end)

script.Parent.ChildRemoved:Connect(function(inst: Instance)
	if inst.Name == 'SeatWeld' then
		if track then
			track:Stop()
			track:Destroy()
		end
	end
end)