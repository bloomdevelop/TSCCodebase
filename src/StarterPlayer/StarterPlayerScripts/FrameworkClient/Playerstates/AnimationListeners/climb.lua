return function(framework, humanoid: Humanoid, track: AnimationTrack, param: string)
	if humanoid.Parent and humanoid.Parent:FindFirstChild('Torso') then
		local m: RaycastResult = framework.Modules.Raycaster:Cast(humanoid.Parent.Torso.Position, humanoid.Parent.Torso.CFrame:ToWorldSpace(CFrame.new(0, 0, -2)).Position - humanoid.Parent.Torso.Position)
		local l: RaycastResult = framework.Modules.Raycaster:Cast(humanoid.Parent.Torso.Position, humanoid.Parent.Torso.CFrame:ToWorldSpace(CFrame.new(0.75, 0, -2)).Position - humanoid.Parent.Torso.Position)
		local r: RaycastResult = framework.Modules.Raycaster:Cast(humanoid.Parent.Torso.Position, humanoid.Parent.Torso.CFrame:ToWorldSpace(CFrame.new(-0.75, 0, -2)).Position - humanoid.Parent.Torso.Position)
		if m ~= nil or l ~= nil or r ~= nil then
			local r = m or l or r
			local f = r and framework.Services.ReplicatedStorage.Assets.Audio.Climb:GetChildren()
			local s: Sound = f[math.random(1, #f)]:Clone()
			s.Parent = humanoid.Parent.Torso;
			s.PlaybackSpeed += (math.random(98, 102) / 100) - 1
			s.Volume = s.Volume
			s:Play()
			framework.Services.Debris:AddItem(s, s.TimeLength + 0.1)
		end
	end
end