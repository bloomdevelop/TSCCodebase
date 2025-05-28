-- // Steven_Scripts, 2022
-- // Edited By FoxxoTrystan
-- // Shower

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Showers = workspace:WaitForChild("DisinfectantShower")

local function playerIsInRange(Player: Player, LevelPos: Vector3, MaxActivationDistance)
	local Character = Player.Character
	if not Character then return false end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if not Root then return false end

	local Distance = (Root.Position - LevelPos).Magnitude
	if Distance < MaxActivationDistance + 5 then
		return true
	else
		return false
	end
end

for _,Shower in pairs(Showers:GetChildren()) do
	local Lever = Shower.Lever
	local LeverPrimary = Lever.Primary

	local LeverOnPos = Lever.ONpos.CFrame
	local LeverOffPos = Lever.OFFpos.CFrame

	local Sprinkler = Shower.Sprinkler
	local SprinklerRegion = Shower.Region

	local LeverOnTween = TweenService:Create(LeverPrimary, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {["CFrame"] = LeverOnPos})
	local LeverOffTween = TweenService:Create(LeverPrimary, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {["CFrame"] = LeverOffPos})

	local ClickDetector = LeverPrimary.ClickDetector

	local MaxActivationDistance = ClickDetector.MaxActivationDistance

	local PullSound = LeverPrimary.PullSound

	local Cooldown = false
	local SprinklersActive = false

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

		local PartsInRegion = workspace:GetPartsInPart(SprinklerRegion, Params)
		for i,HitPart in pairs(PartsInRegion) do
			if HitPart.Name == "HumanoidRootPart"then
				local Character = HitPart.Parent
				local Player = game.Players:GetPlayerFromCharacter(Character)
				if (Player) then
					local IsInfected = InfectedCheck(Player)

					if IsInfected then
						Character.Humanoid.Health = Character.Humanoid.Health - 50
					else
						local LatexValues = Character:WaitForChild("LatexValues")
						if LatexValues.InfectionLevel.Value > 0 then
							LatexValues.InfectionLevel.Value -= 5
						end
						LatexValues = nil
					end
				end
			else
				HitPart:Destroy()
			end
		end
	end

	local function activateSprinklers()
		SprinklersActive = true

		Sprinkler.Emitter.Particles.Enabled = true

		SprinklerRegion.Running:Play()
		SprinklerRegion.Valve:Play()

		coroutine.wrap(function()
			while SprinklersActive do
				task.wait(.1)
				checkSprinklerRegions()
			end
		end)()
	end

	local function deactivateSprinklers()
		SprinklersActive = false

		Sprinkler.Emitter.Particles.Enabled = false

		SprinklerRegion.Running:Stop()
		SprinklerRegion.Valve:Play()
	end

	local function onClicked(Player : Player)
		if Cooldown == true then return end
		if playerIsInRange(Player, LeverPrimary.Position, MaxActivationDistance) == false then return end

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

	ClickDetector.MouseClick:connect(onClicked)
end
