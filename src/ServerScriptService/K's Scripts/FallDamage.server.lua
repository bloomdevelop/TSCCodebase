local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IsInfected = require(ReplicatedStorage:WaitForChild("InfectedCheckModule"))

local DamageReduction = 50 --what to reduce the damage by
local DamageDampening = 2 --what to divde the damage by

local MaterialDampeningDictionary = {
	-- Soft enough to break your fall
	[Enum.Material.Fabric] = 8,
	[Enum.Material.Sand] = 8,

	-- Soft enough to usually break your fall
	[Enum.Material.Grass] = 4,
	[Enum.Material.Mud] = 4,
	[Enum.Material.Snow] = 4,

	-- Eh, it's better than landing on concrete
	[Enum.Material.Wood] = 2,
	[Enum.Material.WoodPlanks] = 2,
	[Enum.Material.LeafyGrass] = 2,
}

local function InitializeFD(chr)
	local Humanoid = chr:WaitForChild("Humanoid")
	local Head = chr:WaitForChild("Head")

	local RayParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = {chr}

	Humanoid.StateChanged:Connect(function(old, new)
		if not (old == Enum.HumanoidStateType.Freefall and (new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.Climbing)) then return end -- Make sure the player just landed
		local FallVelocity = -chr.HumanoidRootPart.Velocity.Y
		local LatexDamageReduction = 0
		if IsInfected(game.Players:GetPlayerFromCharacter(chr)) then
			LatexDamageReduction = 50
		end
		if FallVelocity <= (DamageReduction + LatexDamageReduction) then return elseif FallVelocity >= 100 then FallVelocity *= 2 end

		local DownwardsRaycastResult = workspace:Raycast(Head.Position, Vector3.new(0, -60, 0), RayParams)
		local MaterialDampening
		if DownwardsRaycastResult then
			MaterialDampening = MaterialDampeningDictionary[DownwardsRaycastResult.Material]
			if MaterialDampening == nil then
				MaterialDampening = 1
			end
		else
			MaterialDampening = 1
		end
		local HealthDampening = Humanoid.MaxHealth / 100

		local Damage = math.clamp((((FallVelocity-DamageReduction)/DamageDampening/MaterialDampening)*HealthDampening),0,999999999)
		
		if not IsInfected(game.Players:GetPlayerFromCharacter(chr)) then
			if Damage >= 50 and Random.new(1,10) == 1 then
				local player = game:GetService("Players"):GetPlayerFromCharacter(chr)
				local injuriesFolder = player.Injuries

				local injuryName = "BrokenLeg"

				if injuriesFolder:FindFirstChild(injuryName) ~= nil then
					-- Player already has this injury.
					return
				end

				local injurySound = script.Injury:Clone()
				injurySound.Parent = chr.HumanoidRootPart
				injurySound:Play()

				game.Debris:AddItem(injurySound, 4)

				local injuryValue = Instance.new("NumberValue")
				injuryValue.Value = 15*60
				injuryValue.Name = injuryName
				injuryValue.Parent = injuriesFolder
			end
		end
		
		Humanoid:TakeDamage(Damage)
	end)
end

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(InitializeFD)
	InitializeFD(plr.Character or plr.CharacterAdded:Wait())
end)