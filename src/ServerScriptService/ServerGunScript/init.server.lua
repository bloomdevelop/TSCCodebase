local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local debris = game:GetService("Debris")
local gunAnimationStorage = game.ReplicatedStorage.GunAnimations

local clientModulesFolder = replicatedStorage.Modules
local remotesFolder = replicatedStorage.Remotes

local gunFireRemote = remotesFolder.Guns.GunFire
local gunHitRemote = remotesFolder.Guns.GunHit
local gunVisualizerRemote = remotesFolder.Guns.GunVisualizer
local toggleBlockRemote = remotesFolder.Guns.ToggleBlock

local injuryBucketMax = 80
local injuryBucketDecayRate = 2 -- Amount subtracted per second
local injuryChance = 20 -- 1 in injuryChance

local naturalHealTime = 15*60

local rng = Random.new()

local infectedCheckModule =  require(replicatedStorage.InfectedCheckModule)
local injuryData = require(clientModulesFolder.InjuryData)

for i,v in pairs(game.StarterPack:GetDescendants())do
	if v:IsA("ModuleScript") and v.Name == "GunData" and v:FindFirstChild("Mag") == nil then
		local gunData = require(v)
		if gunData.MagSize then			
			local mag = Instance.new("IntValue",v)
			mag.Name = "Mag"
			mag.Value = gunData.MagSize
		end
		if gunData.ReserveAmmo then
			local ammo = Instance.new("IntValue",v)
			ammo.Name = "ReserveAmmo"
			ammo.Value = gunData.ReserveAmmo
		end
	elseif v:IsA("ModuleScript") and v.Name == "GunData" then
		local gunData = require(v)
		if gunData.MagSize then
			v.Mag.Value = gunData.MagSize
		end
		if gunData.ReserveAmmo then
			v.ReserveAmmo.Value = gunData.ReserveAmmo
		end
	end
end

local function deepCopy(t)
	local tableCopy = {}
	for k, v in next, t do
		tableCopy[k] = type(v) == "table" and deepCopy(v) or v
	end
	return tableCopy
end

local function getGunHitModule(part)
	if (part) then
		local gunHitModule = part:FindFirstChild("OnGunHit")
		if gunHitModule == nil then
			gunHitModule = part.Parent:FindFirstChild("OnGunHit")
		end

		return gunHitModule
	end
	return false
end

local function raycast(rayOrigin,rayDirection,blacklist)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = blacklist
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	return raycastResult
end

local function checkBulletHit(gun, firePosition, endPosition)
	local gunData = require(gun.GunData)

	local triesLeft = 10
	--local pos = spread(gun,gunData,pos)
	local rayOrigin = firePosition
	local rayDirection = (endPosition - firePosition).Unit * gunData.Range
	local blacklist = {gun.Parent,workspace.GunEffects}

	local rayResult, onGunHit

	while triesLeft > 1 do
		triesLeft -= 1
		rayResult = raycast(rayOrigin,rayDirection,blacklist)

		if rayResult then
			rayOrigin = rayResult and rayResult.Position
			table.insert(blacklist,rayResult.Instance)
		end

		if rayResult == nil then
			break
		else
			local hitPart = rayResult.Instance

			onGunHit = hitPart:FindFirstChild("OnGunHit")
			if onGunHit == nil then
				onGunHit = hitPart.Parent:FindFirstChild("OnGunHit")
			end

			if (hitPart.CanCollide == true and hitPart.Transparency < 1) or hitPart.Name == "HITBOX" or hitPart.Parent:FindFirstChildOfClass("Humanoid") ~= nil or onGunHit ~= nil then
				break
			end
		end
	end

	if triesLeft > 1 then
		return rayResult
	else
		return nil
	end
end


local function getEntryFromWeightedChanceTable(chanceTable)
	local counter = 0

	for i,weightData in pairs(chanceTable) do
		local weight = weightData[2]

		counter = counter + weight
	end

	local chosenWeight = rng:NextInteger(0, counter)

	for i,weightData in pairs(chanceTable) do
		counter = counter - chanceTable[i][2]

		if chosenWeight >= counter then
			return chanceTable[i][1]
		end
	end
end

local function addInjury(player : Player, limb : BasePart)
	--print("ADDING INJURY BASED OFF OF "..limb.Name)
	if infectedCheckModule(player) then return end
	local injuriesFolder = player.Injuries

	local injuryChances = injuryData.Chances[limb.Name]
	local injuryName = getEntryFromWeightedChanceTable(injuryChances)

	if injuriesFolder:FindFirstChild(injuryName) ~= nil then
		-- Player already has this injury.
		return
	end

	local injurySound = script.Injury:Clone()
	injurySound.Parent = limb
	injurySound:Play()

	game.Debris:AddItem(injurySound, 4)

	local injuryValue = Instance.new("NumberValue")
	injuryValue.Value = naturalHealTime
	injuryValue.Name = injuryName
	injuryValue.Parent = injuriesFolder
end

local function updateInjuries(player)
	local character = player.Character
	if not character then return end
	local humanoid = character.Humanoid
	local defaultMaxHealth = humanoid:GetAttribute("DefaultMaxHealth")

	local painkillerMultiplier = 1
	if player:GetAttribute("PainkillerTimer") ~= nil then
		-- on painkillers (bloxy cola)
		painkillerMultiplier = 0.2
	end

	if defaultMaxHealth == nil then
		humanoid:SetAttribute("DefaultMaxHealth", humanoid.MaxHealth)
		defaultMaxHealth = humanoid.MaxHealth
	end

	local maxHealthPenalty = 0
	for i,injury in pairs(player.Injuries:GetChildren()) do
		maxHealthPenalty = maxHealthPenalty+10
		if injury.Name == "ArterialBleeding" then
			maxHealthPenalty = maxHealthPenalty+10
		end
	end

	maxHealthPenalty = maxHealthPenalty*painkillerMultiplier

	humanoid.MaxHealth = defaultMaxHealth - maxHealthPenalty
	if humanoid.Health > humanoid.MaxHealth then
		humanoid.Health = humanoid.MaxHealth
	end
end

local function breakBlock(targetPart, targetCharacter)
	local targetHumanoid = targetCharacter.Humanoid

	local blockBreakSound = script.BlockBreak:Clone()
	local blockBreakParticles = script.BlockBreakParticles:Clone()
	local disorientedParticles = script.Disoriented:Clone()

	blockBreakSound.Parent = targetPart
	blockBreakParticles.Parent = targetPart
	disorientedParticles.Parent = targetCharacter.Head

	blockBreakSound:Play()
	blockBreakParticles:Emit(20)
	disorientedParticles.Enabled = true

	-- Stagger animation
	local animator = targetHumanoid:FindFirstChild("Animator") or targetHumanoid
	local animation = animator:LoadAnimation(replicatedStorage.GunAnimations.Stagger)
	animation:Play(.1, 2)

	game.Debris:AddItem(animation, 3)

	game.Debris:AddItem(blockBreakSound, 2)
	game.Debris:AddItem(blockBreakParticles, 2)
	game.Debris:AddItem(disorientedParticles, 10)

	targetCharacter:SetAttribute("BlockCooldown", true)
	targetCharacter:SetAttribute("BlockingTimestamp", nil)

	task.delay(8, function()
		targetCharacter:SetAttribute("BlockCooldown", nil)
		disorientedParticles.Enabled = false
	end)
end

local function gunHasEffect(gunData, effectsCheckingFor)
	if gunData.Effects ~= nil then
		for i,effectName in pairs(gunData.Effects) do
			if table.find(effectsCheckingFor, effectName) ~= nil then
				return true
			end
		end
	end

	if gunData.Charge ~= nil then
		for i,effectsList in pairs(gunData.Charge.Effects) do
			for i,effectName in pairs(effectsList) do
				if table.find(effectsCheckingFor, effectName) ~= nil then
					return true
				end
			end
		end
	end

	return false
end

local function registerHit(playerWhoShot : Player, targetCharacter : Model, gun : Tool, gunData, hitPart : BasePart, charge : number, positionAtHit : Vector3, endPosition : Vector3, gunHitModule : ModuleScript)
	if gunData.Charge and charge > 0 then
		for i,v in pairs(gunData.Charge) do
			if typeof(v) == "table" then
				gunData[i] = v[charge]
			end
		end
	end

	local character = playerWhoShot.Character
	local root = character.HumanoidRootPart

	local targetPart = targetCharacter ~= nil and (targetCharacter:FindFirstChild("HumanoidRootPart") or (targetCharacter:IsA("Model") and targetCharacter.PrimaryPart or (targetCharacter:IsA("BasePart") and targetCharacter or nil))) or nil 
	local distance = targetPart ~= nil and (targetPart.Position - root.Position).Magnitude or 0

	local hitPlayer = game.Players:GetPlayerFromCharacter(targetCharacter)
	local damage = hitPart.Name == "Head" and gunData.Damage*gunData.HeadshotMultiplier or gunData.Damage --headshotMultplier

	if gunData.DropoffStart and distance <= gunData.DropoffStart then
		local range = gunData.Range-gunData.DropoffStart
		local dropoff = math.clamp(range-distance/range,0,1)
		damage = damage * dropoff
	end

	if hitPlayer then
		local Infected = infectedCheckModule(hitPlayer)
		if Infected then
			local Resistance = false
			if gunData.InfectedMultiplier then
				damage *= gunData.InfectedMultiplier
				if gunData.InfectedMultiplier >= 1 then
					Resistance = true
				end
			else
				Resistance = true
			end

			if Resistance then
				--// Latex Resistance
				if gunData.Charge ~= nil then
					local isSharp = gunHasEffect(gunData, {"Bleed"})
					if isSharp == false then
						damage = math.floor(1.85 * damage) --// Blunt melee resistance // -15%
					else
						damage = math.floor(0.95 * damage) --// Sharp melee resistance // +5%
					end
				else
					damage = math.floor(0.9 * damage) --// Bullet resistance // +10%
				end
			end
			Resistance = nil

			if gunData.Effects then
				if table.find(gunData.Effects, "Ignite") then
					local LatexType = targetCharacter:FindFirstChild("LatexValues"):FindFirstChild("LatexType")
					if (LatexType) then
						if LatexType.Value == "FireFox" then
							damage = 0
						end
					end
				end
			end
		end
	end
	local blocked = false
	if gunData.Charge ~= nil then
		-- This is a melee. Check to see if the target is a person and is blocking.
		local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
		if targetHumanoid ~= nil and targetHumanoid.Health > 0 then
			local blockingTimestamp = targetCharacter:GetAttribute("BlockingTimestamp")
			if blockingTimestamp ~= nil then
				-- They are! Check to see if this attack is hitting the front. Blocking can only work from the front.
				local targetLook = targetPart.CFrame.LookVector
				local attackerLook = (targetPart.Position - root.Position).Unit

				-- This is for later.
				local toughness = gunData.Toughness or 0

				local targetToughness = 0
				local targetGun = targetCharacter:FindFirstChildOfClass("Tool")
				if targetGun ~= nil and targetGun:FindFirstChild("GunData") then
					targetToughness = require(targetGun.GunData).Toughness or 0
				end

				local blockBreakLevel = charge + toughness - targetToughness

				local alignment = targetLook:Dot(attackerLook)
				if alignment < 0 then
					-- Yep, they're hitting the front.
					blocked = true

					-- Check for a perfect block.
					local timeSinceBlock = os.clock() - blockingTimestamp
					if timeSinceBlock < 0.7 then
						-- Perfect block! This will negate all damage to the target.
						local PBSound = script.PBSound:Clone()
						local PBParticles = script.PBParticles:Clone()

						PBSound.Parent = targetPart
						PBParticles.Parent = targetPart

						PBSound.TimePosition = 0.2

						PBSound:Play()
						PBParticles:Emit(20)

						game.Debris:AddItem(PBSound, 2)
						game.Debris:AddItem(PBParticles, 2)

						if blockBreakLevel <= 3 then
							-- Backfire on the attacker for half of its damage.
							
							if targetCharacter:FindFirstChild("Trained Fists") then
								-- Yakuza reference
								local animator = targetHumanoid:FindFirstChild("Animator") or targetHumanoid
								local animation = animator:LoadAnimation(replicatedStorage.GunAnimations.TigerDrop)
								local sound = script.TigerDropSound:Clone()

								sound.Parent = targetPart

								sound:Play()
								animation:Play(.02, 1000)

								game.Debris:AddItem(animation, 3)
								game.Debris:AddItem(sound, 3)
							end

							-- Stagger animation
							local humanoid = character.Humanoid
							local animator = humanoid:FindFirstChild("Animator") or humanoid
							local animation = animator:LoadAnimation(replicatedStorage.GunAnimations.Stagger) :: AnimationTrack
							animation:Play(.1, 2)

							game.Debris:AddItem(animation, 3)

							registerHit(playerWhoShot, character, gun, gunData, character.Head, charge, root.Position, character.Head.Position)
						end
						
						damage = 0
					else
						-- Regular block.

						-- Break the block if this is a strong enough weapon and swing.
						if blockBreakLevel >= 3 then
							breakBlock(targetPart, targetCharacter)
						end

						-- Reduce the attack's damage based on blockBreakLevel.
						if blockBreakLevel > 3 then
							-- Reduce 20%
							damage = damage * 0.8
						elseif blockBreakLevel == 3 then
							-- Reduce 60%
							damage = damage * 0.4
						elseif blockBreakLevel == 2 then
							-- Reduce 80%
							damage = damage * 0.2
						elseif blockBreakLevel <= 1 then
							-- Reduce 90%
							damage = damage * 0.1
						end
					end
				else
					-- They didn't hit the front, but we should still break their block since they got the hit in.
					breakBlock(targetPart, targetCharacter)
				end
			end
		end
	end

	if gunHitModule then
		require(gunHitModule)(playerWhoShot, damage, gun, gunData)
	elseif (targetCharacter) and targetCharacter:FindFirstChildOfClass("ForceField") == nil then
		local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
		if not targetHumanoid then return end

		local hitPlayer = game.Players:GetPlayerFromCharacter(targetCharacter)
		local character = playerWhoShot.Character

		if gunData.Latex and hitPlayer and damage > 0 then
			local LatexValues = character:WaitForChild("LatexValues")
			_G.InfectPlayer(hitPlayer, damage, LatexValues.LatexType.Value, true, character.Torso.Color)
		else
			if damage < 0 then damage = 0 end
			targetHumanoid.Health -= damage
		end

		-- print(playerWhoShot.Name.." hit "..targetCharacter.Name.."'s "..hitPart.Name)

		if targetHumanoid.Health <= 0 and not game:GetService("CollectionService"):HasTag(targetHumanoid,"Killed") then
			game:GetService("CollectionService"):AddTag(targetHumanoid,"Killed")

			playerWhoShot.Kills.Value = playerWhoShot.Kills.Value+1

			targetCharacter:SetAttribute("BlockingTimestamp", nil)

			--print(playerWhoShot.Name .. " killed " .. character.Name .. " with " .. gun.Name)
		elseif hitPlayer then
			-- This is a player and they didn't die
			-- Fill injury bucket
			local injuryBucket = character:FindFirstChild("InjuryBucket")
			injuryBucket.Value = injuryBucket.Value + damage

			--print(targetCharacter.Name.." - "..injuryBucket.Value)

			if injuryBucket.Value >= injuryBucketMax then
				-- Roll chance for injury
				local injuryRoll = rng:NextInteger(1, injuryChance) == 1
				if injuryRoll then
					addInjury(hitPlayer, hitPart)
				end
				injuryBucket.Value = 0
			end
		end

		if gunData.Effects then
			for i,v in pairs(gunData.Effects)do
				-- print("Effect "..v.." added")
				if (script.HitEffects[v]:FindFirstChild("Stacks") == nil or script.HitEffects[v].Stacks.Value) and not targetCharacter:FindFirstChild(script.HitEffects[v].Name) then
					local effect = script.HitEffects[v]:Clone()
					effect.Parent = targetCharacter
					effect.Disabled = false
				end
			end
		end

		gunHitRemote:FireAllClients(playerWhoShot, gunData, hitPart, endPosition, blocked)
	end
end

local function onGunHitRequest(playerWhoShot, targetCharacterOrPart, gun, hitPart, charge, positionAtHit, endPosition)
	-- Type checking, Enabled at your own caution
	--if typeof(playerWhoShot) ~= "Instance" or not playerWhoShot:IsA("Player") then return end
	--if typeof(targetCharacterOrPart) ~= "Instance" or (not targetCharacterOrPart:IsA("BasePart") and not targetCharacterOrPart:IsA("Model")) then return end
	--if typeof(gun) ~= "Instance" or not gun:IsA("Tool") then return end
	--if typeof(hitPart) ~= "Instance" or not hitPart:IsA("BasePart") then return end
	--if typeof(charge) ~= "number" then return end
	--if typeof(positionAtHit) ~= "Vector3" then return end
	--if typeof(endPosition) ~= "Vector3" then return end

	if targetCharacterOrPart == nil then return end
	local character = playerWhoShot.Character

	-- Check if player is loaded in
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		-- Check if player is alive
		if humanoid and humanoid.Health > 0 then
			-- Check to make sure they have the gun equipped
			if gun == nil then
				-- No gun specified
				return
			elseif gun.Parent == character then
				-- Player is holding the gun

				-- Make sure they're not blocking
				if character:GetAttribute("BlockingTimestamp") ~= nil then
					-- You can't attack while blocking.
					return
				end

				local gunData = require(gun.GunData)
				gunData = deepCopy(gunData)

				--// CannotShoot if NoWeapon Latex.
				if gunData.Charge == nil and character:WaitForChild("LatexValues").NoWeapon.Value == true then
					return
				end

				local root = character.HumanoidRootPart
				local positionRightNow = root.Position

				local discrepancy = (positionRightNow - positionAtHit).Magnitude
				-- See if where they claimed to be firing from is close enough to their actual position
				if discrepancy < 20 then
					-- Yea, close enough

					local targetPart, targetCharacter, gunHitModule
					if targetCharacterOrPart:IsA("Model") then
						targetCharacter = targetCharacterOrPart
						targetPart = targetCharacter:FindFirstChild("HumanoidRootPart")
					elseif targetCharacterOrPart:IsA("BasePart") then
						targetPart = targetCharacterOrPart			
						if targetPart.Parent:IsA("Model") then
							targetCharacter = targetPart.Parent
						end
					end

					if targetCharacter ~= nil and (not targetPart or hitPart ~= nil and hitPart.Parent ~= targetCharacter) then
						-- Wait, that's not even their limb.
						-- print("Wait up...")
						return
					end

					-- Check to see if they're trying to wallshoot (cast a ray from the root to the barrel of the gun)
					local wallshootCheckBlacklist = {targetCharacter}
					for i,v in pairs(character:GetChildren()) do
						if v:IsA("BasePart") or v:IsA("Accessory") or v:IsA("Model") or v:IsA("Folder") then
							table.insert(wallshootCheckBlacklist, v)
						end
					end

					local rayDirection = (gun.Handle.Position - positionRightNow)

					local wallshootCheckRaycastResult = raycast(positionRightNow, rayDirection, wallshootCheckBlacklist)

					if wallshootCheckRaycastResult ~= nil and wallshootCheckRaycastResult.Instance:IsDescendantOf(gun) == false and wallshootCheckRaycastResult.Instance.CanCollide == false and wallshootCheckRaycastResult.Instance.Transparency == 1 then
						-- That's something invisible without collision. We're probably not meant to see it as an obstacle. Retry just one time.
						table.insert(wallshootCheckBlacklist, wallshootCheckRaycastResult.Instance)
						wallshootCheckRaycastResult = raycast(positionRightNow, rayDirection, wallshootCheckBlacklist)
					end

					if wallshootCheckRaycastResult ~= nil and wallshootCheckRaycastResult.Instance:IsDescendantOf(gun) then
						-- No wallshooting here
						-- print("No Wallshooting here")
						local targetPart, targetCharacter, gunHitModule
						if targetCharacterOrPart:IsA("Model") then
							targetCharacter = targetCharacterOrPart
							targetPart = targetCharacter:FindFirstChild("HumanoidRootPart")
							if targetPart == nil then
								targetPart = targetCharacter:FindFirstChild("Head")
								if targetPart == nil then
									-- Oh my god okay just use whatever
									targetPart = targetCharacter:FindFirstChildOfClass("BasePart")
									if targetPart == nil then
										-- You're kidding me.
										return
									end
								end
							end
						elseif targetCharacterOrPart:IsA("BasePart") then
							targetPart = targetCharacterOrPart			
							if targetPart.Parent:IsA("Model") then
								targetCharacter = targetPart.Parent
							end
						end

						if targetPart == nil then return end

						gunHitModule = getGunHitModule(targetPart)

						-- Check for line of sight
						local directRaycastResult = checkBulletHit(gun, positionAtHit, endPosition)
						local partRaycastResult = checkBulletHit(gun, positionAtHit, targetPart.Position)

						local raycastResult = nil

						-- For some reason, the line below this comment sometimes errors and screams at you for trying to index "Instance" of nil.
						-- EVEN THOUGH THERE IS A CHECK *RIGHT* BEFORE IT TO SEE IF IT'S NIL
						-- I DO NOT UNDERSTAND
						-- so I just wrapped it in a pcall
						-- it works. shut up
						-- 
						-- 	~steven

						pcall(function()
							if directRaycastResult ~= nil and directRaycastResult.Instance == targetPart or directRaycastResult.Instance:IsDescendantOf(targetCharacter) then
								raycastResult = directRaycastResult
							elseif partRaycastResult ~= nil and partRaycastResult.Instance == targetPart or partRaycastResult.Instance:IsDescendantOf(targetCharacter) then
								raycastResult = partRaycastResult
							end
						end)

						if raycastResult then
							-- Line of sight verified
							-- print("LoS True!")
							-- Register hit
							registerHit(playerWhoShot, targetCharacter, gun, gunData, hitPart, charge, positionAtHit, endPosition, gunHitModule)
						else
							-- print("Couldn't get a clear shot...")
							-- print(directRaycastResult and directRaycastResult.Instance:GetFullName())
							-- print(partRaycastResult and partRaycastResult.Instance:GetFullName())
							-- print(targetCharacter)
						end
					else
						-- print("WALLSHOOT!")
						-- print(wallshootCheckRaycastResult.Instance:GetFullName())
					end
				end
			end
		end
	end
end

--print(returnIsElectric(require(game.ReplicatedStorage.GunDatas.StunStickData)))

gunHitRemote.OnServerEvent:Connect(onGunHitRequest)

gunFireRemote.OnServerEvent:Connect(function(player,data,gun)
	local gunData = gun and gun:FindFirstChild("GunData") and require(gun.GunData) or nil
	if not gunData then
		return
	end

	if data == "Reload" then
		-- Gun reloading
		local injuriesFolder = player.Injuries

		local brokenArmMultiplier = 1
		if injuriesFolder:FindFirstChild("BrokenArm") ~= nil then
			brokenArmMultiplier = 3
			if player:GetAttribute("PainkillerTimer") ~= nil then
				brokenArmMultiplier = 1 + (brokenArmMultiplier-1)*0.2
			end
		end

		if gun.GunData:FindFirstChild("ReserveAmmo") == nil or gunData.MagSize == 0 or gun.GunData.Mag.Value < gunData.MagSize then			
			if gunData.Handloading then
				gun.Handle.ReloadStartSound:Play()
				wait(gunData.ReloadStartDelay*brokenArmMultiplier)
				repeat
					gun.GunData.Mag.Value += 1
					gun.GunData.ReserveAmmo.Value -= 1
					gun.Handle.ReloadSound:Play()
					wait(gunData.ReloadTime*brokenArmMultiplier)
				until gun.GunData.Mag.Value == gunData.MagSize or gunData.ReserveAmmo and gun.GunData.ReserveAmmo.Value == 0
				wait(gunData.ReloadEndDelay*brokenArmMultiplier)
				gun.Handle.ReloadEndSound:Play()
			else
				gun.Handle.ReloadSound:Play()
				local amountNeededToReload = gunData.MagSize - gun.GunData.Mag.Value
				if gun.GunData:FindFirstChild("ReserveAmmo") == nil or gunData.ReserveAmmo == nil then
					amountNeededToReload = gunData.MagSize
				elseif amountNeededToReload > gun.GunData.ReserveAmmo.Value then
					amountNeededToReload = gun.GunData.ReserveAmmo.Value 
				end
				wait(gunData.ReloadTime*brokenArmMultiplier)
				gun.GunData.Mag.Value += math.clamp(amountNeededToReload,0,gunData.MagSize)
				if gun.GunData:FindFirstChild("ReserveAmmo") then
					gun.GunData.ReserveAmmo.Value -= amountNeededToReload
				end
			end
		end
	else
		local ammoCost = gunData["Cost"] or 1

		if gun.GunData.Mag.Value >= ammoCost then
			-- Gun fired
			for i,v in pairs(game.Players:GetPlayers())do
				if v ~= player then
					gunVisualizerRemote:FireClient(v,player,data)
				end
			end

			local isElectric = gunHasEffect(gunData, {"TazeIcify", "TazeIgnite"})
			if isElectric then
				-- Backfire when an electrical weapon is used in water.
				-- Because funny.
				local targetCharacter = player.Character

				if targetCharacter ~= nil then
					local hum = targetCharacter:FindFirstChildOfClass("Humanoid")

					if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
						registerHit(player, targetCharacter, gun, gunData, targetCharacter.Head, 0, targetCharacter.HumanoidRootPart.Position, targetCharacter.Head.Position)
					end
				end
			end

			gun.GunData.Mag.Value -= ammoCost
		end
	end
end)

toggleBlockRemote.OnServerEvent:Connect(function(plr, state : boolean)
	-- Check if player is loaded in
	local character = plr.Character
	if character == nil then return end

	-- Check if they're alive
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health == 0 then return end

	-- Check if they're trying to block when they're already blocking, or vice versa
	local blockingTimestamp = character:GetAttribute("BlockingTimestamp")
	local isBlocking = blockingTimestamp ~= nil
	if isBlocking == state then return end

	if state == false then
		-- If they just want to STOP blocking, I don't think we need to be super heavy on the sanity checks.
		character:SetAttribute("BlockCooldown", true)
		character:SetAttribute("BlockingTimestamp", nil)

		task.wait(.4)

		character:SetAttribute("BlockCooldown", nil)
	else
		-- Check if their block cooldown is enabled
		if character:GetAttribute("BlockCooldown") == true then return end

		-- Check if they have a "gun"
		local gun = character:FindFirstChildOfClass("Tool")
		if gun == nil then return end

		-- Check if their "gun" is a melee
		local gunData = require(gun.GunData)
		if gunData.Charge == nil then return end

		-- Alright, you can start blocking.
		character:SetAttribute("BlockCooldown", true)
		character:SetAttribute("BlockingTimestamp", os.clock())

		task.wait(.1)

		character:SetAttribute("BlockCooldown", nil)
	end
end)

game.Players.PlayerAdded:Connect(function(player)
	local injuriesFolder = Instance.new("Folder")
	injuriesFolder.Name = "Injuries"
	injuriesFolder.Parent = player

	local killCount = Instance.new("IntValue")
	killCount.Name = "Kills"
	killCount.Value = 0
	killCount.Parent = player

	local deathCount = Instance.new("IntValue")
	deathCount.Name = "Deaths"
	deathCount.Value = 0
	deathCount.Parent = player

	injuriesFolder.ChildAdded:Connect(function()
		if player.Team == game.Teams.Menu then return end
		updateInjuries(player)
	end)

	injuriesFolder.ChildRemoved:Connect(function()
		updateInjuries(player)
	end)

	player.CharacterAdded:Connect(function(character)
		local injuryBucket = Instance.new("NumberValue")
		injuryBucket.Value = 0
		injuryBucket.Name = "InjuryBucket"
		injuryBucket.Parent = character

		local hum = character:WaitForChild("Humanoid")

		hum.Died:Connect(function()
			deathCount.Value = deathCount.Value+1
		end)

		while hum:GetAttribute("DefaultMaxHealth") == nil do
			task.wait(1)
		end

		updateInjuries(player)
	end)

	player:GetAttributeChangedSignal("PainkillerTimer"):Connect(function()
		updateInjuries(player)
	end)

	--[[
	task.wait(10)
	
	-- lemme just break every bone in your body real quick
	addInjury(player, player.Character["Right Arm"])
	task.wait(1)
	addInjury(player, player.Character["Right Leg"])
	task.wait(1)
	addInjury(player, player.Character["Head"])
	task.wait(1)
	addInjury(player, player.Character["Torso"])
	task.wait(1)
	]]
end)

-- Bucket decay + natural healing + painkiller timer
while true do
	local timeWaited = task.wait(10)
	for i,player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		if character then
			local injuryBucket = character:FindFirstChild("InjuryBucket")
			if injuryBucket and injuryBucket.Value > 0 then
				-- Bucket decay
				injuryBucket.Value = math.clamp(injuryBucket.Value - timeWaited*injuryBucketDecayRate, 0, injuryBucketMax)
			end
		end

		local injuriesFolder = player:FindFirstChild("Injuries")
		if injuriesFolder then
			local infectedHealMultiplier = 1
			local isInfected = infectedCheckModule(player)
			if isInfected then
				infectedHealMultiplier = 2
			end

			for i,value in pairs(injuriesFolder:GetChildren()) do
				value.Value = value.Value - timeWaited * infectedHealMultiplier
				if value.Value <= 0 then
					-- Injury healed naturally
					value:Destroy()
				end
			end
		end

		local painkillerTimer = player:GetAttribute("PainkillerTimer")
		if painkillerTimer ~= nil then
			-- On painkillers
			local newTime = painkillerTimer - timeWaited
			if newTime <= 0 then
				-- Painkillers ran out
				player:SetAttribute("PainkillerTimer", nil)
			else
				player:SetAttribute("PainkillerTimer", newTime)
			end
		end
	end
end