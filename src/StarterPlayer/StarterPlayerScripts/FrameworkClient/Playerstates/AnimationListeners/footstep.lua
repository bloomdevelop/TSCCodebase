
local StepVars = {
	["Plastic"] = "Plastic",
	["Wood"] = "Wood",
	["Slate"] = "Concrete",
	["Concrete"] = "Concrete",
	["CorrodedMetal"] = "Diamond",
	["DiamondPlate"] = "Diamond",
	["Foil"] = "Tile",
	["Grass"] = "Grass",
	["Ice"] = "Ice",
	["Marble"] = "Pebble",
	["Granite"] = "Pebble",
	["Brick"] = "Brick",
	["Pebble"] = "Pebble",
	["Sand"] = "Sand",
	["Fabric"] = "Fabric",
	["SmoothPlastic"] = "Plastic",
	["Metal"] = "Diamond",
	["WoodPlanks"] = "Wood",
	["Cobblestone"] = "Cobblestone",
	["Air"] = "Concrete",
	["Water"] = "Water",
	["Rock"] = "Concrete",
	["Glacier"] = "Concrete",
	["Snow"] = "Snow",
	["Sandstone"] = "Concrete",
	["Mud"] = "Dust",
	["Basalt"] = "Concrete",
	["Ground"] = "Dust",
	["CrackedLava"] = "Concrete",
	["Neon"] = "Plastic",
	["Glass"] = "Glass",
	["Asphalt"] = "Concrete",
	["LeafyGrass"] = "Grass",
	["Salt"] = "Concrete",
	["Limestone"] = "Concrete",
	["Pavement"] = "Concrete",
	["ForceField"] = "Tile",
	["Gravel"] = "Gravel",
	["Dust"] = "Dust"
}

return function(framework, humanoid: Humanoid, track: AnimationTrack, param: string)
	if humanoid.Parent and humanoid.Parent:FindFirstChild('Torso') and humanoid.Parent:FindFirstChild('HumanoidRootPart') then
		local m: RaycastResult = framework.Modules.Raycaster:Cast(humanoid.Parent.HumanoidRootPart.Position, humanoid.Parent.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, -4, 0)).Position - humanoid.Parent.HumanoidRootPart.Position)
		local l: RaycastResult = framework.Modules.Raycaster:Cast(humanoid.Parent.HumanoidRootPart.Position, humanoid.Parent.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0.75, -4, 0)).Position - humanoid.Parent.HumanoidRootPart.Position)
		local r: RaycastResult = framework.Modules.Raycaster:Cast(humanoid.Parent.HumanoidRootPart.Position, humanoid.Parent.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(-0.75, -4, 0)).Position - humanoid.Parent.HumanoidRootPart.Position)
		if m ~= nil or l ~= nil or r ~= nil then
			local r = m or l or r
			local v = (StepVars[r.Instance.Name] or StepVars[r.Material.Name]) or "Concrete"
			local f = framework.Services.SoundService.Footsteps[v]:GetChildren()
			local s: Sound = f[math.random(1, #f)]:Clone()
			s.Parent = humanoid.Parent.Torso;
			s.PlaybackSpeed += (math.random(98, 102) / 100) - 1
			s.Volume = s.Volume * tonumber(param)
			s:Play()
			framework.Services.Debris:AddItem(s, s.TimeLength + 0.1)
		end
	end
end