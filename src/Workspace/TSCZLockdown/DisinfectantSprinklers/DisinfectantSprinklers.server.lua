-- // Steven_Scripts, 2022

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Folder = script.Parent

local Lever = Folder.Lever
local LeverPrimary = Lever.Primary

local LeverOnPos = Lever.ONpos.CFrame
local LeverOffPos = Lever.OFFpos.CFrame

local ControlsLocked = Folder.Parent.ControlsLocked

local CellBlockADoor = workspace.TSCZLockdown.ADoor

local Sprinklers = Folder.Sprinklers:GetChildren()
local SprinklerRegions = Folder.SprinklerRegions:GetChildren()

local LeverOnTween = TweenService:Create(LeverPrimary, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {["CFrame"] = LeverOnPos})
local LeverOffTween = TweenService:Create(LeverPrimary, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {["CFrame"] = LeverOffPos})

local ClickDetector = LeverPrimary.ClickDetector

local MaxActivationDistance = ClickDetector.MaxActivationDistance

local PullSound = LeverPrimary.PullSound

local Cooldown = false
local SprinklersActive = false
local UnderLockdown = false

local InfectedCheck = require(ReplicatedStorage.InfectedCheckModule)

local function checkSprinklerRegions()
	local Params = OverlapParams.new()

	local FilterDescendantsInstances = CollectionService:GetTagged("Puddle")
	for i,Player in pairs(game.Players:GetPlayers()) do
		if Player.Character ~= nil then
			local Root = Player.Character:FindFirstChild("HumanoidRootPart")
			table.insert(FilterDescendantsInstances, Root)
		end
	end

	Params.FilterDescendantsInstances = FilterDescendantsInstances
	Params.FilterType = Enum.RaycastFilterType.Whitelist

	for i,RegionPart in pairs(SprinklerRegions) do
		local PartsInRegion = workspace:GetPartsInPart(RegionPart, Params)
		for i,HitPart in pairs(PartsInRegion) do
			if HitPart.Name == "HumanoidRootPart"then
				-- Is a character
				local Character = HitPart.Parent
				local Player = game.Players:GetPlayerFromCharacter(Character)

				local IsInfected = InfectedCheck(Player)

				if IsInfected then
					-- Deal damage
					Character.Humanoid.Health = Character.Humanoid.Health - 50
				else
					local LatexValues = Character:WaitForChild("LatexValues")
					if LatexValues.InfectionLevel.Value > 0 then
						LatexValues.InfectionLevel.Value -= 5
					end
					LatexValues = nil
				end
			else
				-- Is a puddle
				-- Just remove it
				HitPart:Destroy()
			end
		end
	end
end

local function activateSprinklers()
	SprinklersActive = true

	for i,Model in pairs(Sprinklers) do
		Model.Emitter.Particles.Enabled = true
	end

	for i,RegionPart in pairs(SprinklerRegions) do
		RegionPart.Running:Play()
		RegionPart.Valve:Play()
	end

	coroutine.wrap(function()
		while SprinklersActive do
			task.wait(.1)
			checkSprinklerRegions()
		end
	end)()
end

local function deactivateSprinklers()
	SprinklersActive = false

	for i,Model in pairs(Sprinklers) do
		Model.Emitter.Particles.Enabled = false
	end

	for i,RegionPart in pairs(SprinklerRegions) do
		RegionPart.Running:Stop()
		RegionPart.Valve:Play()
	end
end

local function playerIsInRange(Player : Player)
	local Character = Player.Character
	if not Character then return false end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if not Root then return false end

	local Distance = (Root.Position - LeverPrimary.Position).Magnitude
	if Distance < MaxActivationDistance+5 then
		return true
	else
		return false
	end
end

local function onClicked(Player : Player)
	if Cooldown == true or ControlsLocked.Value == true then return end
	if playerIsInRange(Player) == false then return end
	if UnderLockdown == false then return end

	Cooldown = true

	ClickDetector.MaxActivationDistance = 0

	PullSound.TimePosition = 0.5
	PullSound:Play()

	if SprinklersActive == false then
		LeverOnTween:Play()
		activateSprinklers()
	else
		LeverOffTween:Play()
		deactivateSprinklers()
	end

	task.wait(0.3)

	ClickDetector.MaxActivationDistance = MaxActivationDistance

	Cooldown = false
end

local function onLockdownStatusChanged()
	if UnderLockdown == false and SprinklersActive == true then
		LeverOffTween:Play()
		deactivateSprinklers()
	end
end

local function onDoorAChildAdded(Child : Instance)
	if Child.Name == "Lockdown" then
		UnderLockdown = true
		onLockdownStatusChanged()
	end
end

local function onDoorAChildRemoved(Child : Instance)
	if Child.Name == "Lockdown" then
		UnderLockdown = false
		onLockdownStatusChanged()
	end
end

ClickDetector.MouseClick:connect(onClicked)

CellBlockADoor.ChildAdded:Connect(onDoorAChildAdded)
CellBlockADoor.ChildRemoved:Connect(onDoorAChildRemoved)