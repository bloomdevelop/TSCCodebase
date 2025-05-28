local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')

local AcidEffect = script.AcidEffect

local Cache = {}

TweenService:Create(script.Parent,TweenInfo.new(10,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position = script.Parent.Position + Vector3.new(0,0.3,0)}):Play()

local function len(t)
	local n = 0
	for _ in pairs(t) do n += 1 end
return n end

-- For the loop
local Initialized = false
local function InitializeLoop()
	if Initialized then return end
	Initialized = true
	while len(Cache) > 0 do
		for _, character in next, Cache do
			if character:FindFirstChild("Infected") then
				character.Humanoid.Health -= 45
				character.Humanoid.WalkSpeed -= 0.1
				character.Humanoid.JumpPower -= 0.5
			else
				character.Humanoid.Health -= 2
				character.Humanoid.WalkSpeed -= 0.01
				character.Humanoid.JumpPower -= 0.05
			end
		end
		task.wait(0.1)
	end
	Initialized = false
end

local function IsHumanoidRootPart(part)
	return(part.Name == "HumanoidRootPart" and part.Parent:IsA("Model"))
end

script.Parent.Touched:Connect(function(part)
	if not (IsHumanoidRootPart(part) or Cache[part.Parent.Name]) then return end
	Cache[part.Parent.Name] = part.Parent
	
	local ExistingPart = part:FindFirstChild("AcidEffect")
	if not ExistingPart then
		local NewAcid = AcidEffect:Clone()
		NewAcid.Parent = part; NewAcid.Enabled = true
	end
	InitializeLoop()
end)

script.Parent.TouchEnded:Connect(function(part)
	if not (IsHumanoidRootPart(part) and Cache[part.Parent.Name]) then return end
	Cache[part.Parent.Name] = nil
end)