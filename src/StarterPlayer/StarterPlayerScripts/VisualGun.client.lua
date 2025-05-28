local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- local raycastHitbox = require(replicatedStorage.Modules.RaycastHitboxV4)

local localPlayer = game.Players.LocalPlayer

local gunAnimationStorage = game.ReplicatedStorage.GunAnimations

local remotesFolder = replicatedStorage.Remotes
local bindablesFolder = replicatedStorage.BindableFunction

local gunFireRemote = remotesFolder.Guns.GunFire
local gunHitRemote = remotesFolder.Guns.GunHit
local gunVisualizerRemote = remotesFolder.Guns.GunVisualizer

local Glass = {"1565824613", "1565825075",}
local Metal = {"282954522", "282954538", "282954576", "1565756607", "1565756818",}
local Grass = {"1565830611", "1565831129", "1565831468", "1565832329",}
local Wood = {"287772625", "287772674", "287772718", "287772829", "287772902",}
local Concrete = {"287769261", "287769348", "287769415", "287769483", "287769538",}

local HitSounds = {
	["Glass"] = Glass,
	["Metal"] = Metal,
	["Grass"] = Grass,
	["Wood"] = Wood,
	["Concrete"] = Concrete
}

local MaterialCategories = {
	["Brick"] = "Concrete",
	["CobbleStone"] = "Concrete",
	["Concrete"] = "Concrete",
	["Pavement"] = "Concrete",
	["Rock"] = "Concrete",
	["Salt"] = "Concrete",
	["Sandstone"] = "Concrete",
	["Limestone"] = "Concrete",
	["CrackedLava"] = "Concrete",
	["Asphalt"] = "Concrete",
	["Basalt"] = "Concrete",
	["Granite"] = "Concrete",
	["Marble"] = "Concrete",
	["Neon"] = "Concrete",
	["Pebble"] = "Concrete",
	["Plastic"] = "Concrete",
	["Slate"] = "Concrete",
	["SmoothPlastic"] = "Concrete",

	["CorrodedMetal"] = "Metal",
	["DiamondPlate"] = "Metal",
	["Metal"] = "Metal",

	["Glacier"] = "Glass",
	["Foil"] = "Glass",
	["ForceField"] = "Glass",
	["Ice"] = "Glass",
	["Glass"] = "Glass",

	["Fabric"] = "Grass",
	["Ground"] = "Grass",
	["LeafyGrass"] = "Grass",
	["Snow"] = "Grass",
	["Grass"] = "Grass",
	["Mud"] = "Grass",
	["Sand"] = "Grass",

	["Wood"] = "Wood",
	["WoodPlanks"] = "Wood"
}

--local Explosion = {"287390459", "287390954", "287391087", "287391197", "287391361", "287391567",}

--local Cracks = {"342190504", "342190495", "342190488", "342190510",} -- Bullet Cracks
--local Hits = {"363818432", "363818488", "363818567", "363818611", "363818653",} -- Player
--local Whizz = {"342190005", "342190012", "342190017", "342190024",} -- Bullet Whizz


local function effect(effectFolder, parent, visibleTime, colour, severity)
	severity = severity or 1

	for i,v in pairs(effectFolder:GetChildren())do
		if v:IsA("ParticleEmitter") then
			local count = 1
			local Particle = v:Clone()
			if Particle:FindFirstChild("PartColor") == nil or Particle.PartColor.Value then
				Particle.Color = colour and ColorSequence.new({ColorSequenceKeypoint.new(0,colour),ColorSequenceKeypoint.new(1,colour)}) or  ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
			end			
			Particle.Parent =parent
			if Particle:FindFirstChild("EmitCount") then
				count = math.ceil(Particle.EmitCount.Value * severity)
			end
			delay(visibleTime,function()
				Particle:Emit(count)
				debris:AddItem(Particle,Particle.Lifetime.Max)
			end)
		end
	end	
end

local function flash(gun,muzzleFlashData) 	
	if muzzleFlashData then	
		local muzzleEffect = muzzleFlashData.Effect or game.ReplicatedStorage.GunEffects.DefaultMuzzleEffect 
		effect(muzzleEffect,gun:FindFirstChild("GunMuzzlePoint",true),muzzleFlashData["VisibleTime"])
		local Light = Instance.new("PointLight")
		Light.Brightness = muzzleFlashData["Brightness"]
		Light.Color = muzzleFlashData["Colour"]
		Light.Enabled = true
		Light.Range = muzzleFlashData["Range"]
		Light.Shadows = muzzleFlashData["Shadows"]
		Light.Parent = gun:FindFirstChild("GunMuzzlePoint",true)
		debris:addItem(Light,muzzleFlashData["VisibleTime"])
	end
end

local function bulletTrail(startPoint,endPoint,gunData,playerWhoShot)
	if gunData.Trail then
		local speed = gunData.BulletSpeed or 500	
		local startPart = script[gunData.Trail]:Clone()
		startPart.CFrame = CFrame.new(startPoint,endPoint)
		startPart.Parent = workspace.GunEffects
		local lifeTime =  (startPoint-endPoint).Magnitude/speed
		tweenService:Create(startPart,TweenInfo.new((startPoint-endPoint).Magnitude/speed,Enum.EasingStyle.Linear),{Position = endPoint}):Play()
		--for i,v in pairs(game.Players:GetPlayers())do
		--	if v ~= playerWhoShot then
		--		gunFireRemote:FireClient(v,gunData,startPart)
		--	end
		--end
		local whizData = gunData.Whiz
		if whizData and startPart and startPart.Parent ~= nil and playerWhoShot ~= localPlayer then
			spawn(function()
				local whiz = false
				repeat 
					if localPlayer:DistanceFromCharacter(startPart.Position) <= gunData.Whiz.Distance then
						whiz = true
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://"..whizData["Sounds"][math.random(1,#whizData["Sounds"])]
						sound.Volume = whizData["Vol"] --loudness
						sound.PlaybackSpeed = Random.new():NextNumber(whizData["PitchMin"], whizData["PitchMax"])
						sound.Name = "WhizSound_Clone"
						sound.Parent = game.SoundService--part		
						if not sound.IsLoaded then
							sound.Loaded:Wait()
						end
						sound:Play()
						debris:AddItem(sound, sound.TimeLength / sound.PlaybackSpeed)
					end
					wait() 
				until startPart == nil or startPart.Parent == nil or whiz
			end)
		end
		debris:AddItem(startPart,lifeTime)
	end
end

local function getMaterialCategory(materialName)
	local materialCategory = MaterialCategories[materialName]
	if materialCategory == nil then
		-- Default to concrete
		materialCategory = "Concrete"
	end

	return materialCategory
end

local function blood(gunData, hitPart, hitPosition, blocked)
	local bloodEffect = gunData.BloodEffect or game.ReplicatedStorage.GunEffects.DefaultBloodEffect 
	local bloodData = gunData.Blood
	
	if bloodData == nil then return end

	if bloodEffect ~= "None" then
		local soundPart = script.SoundPart:Clone()
		soundPart.Parent = workspace.GunEffects
		soundPart.CFrame = CFrame.new(hitPosition)
		
		local sound = soundPart.Sound
		sound.SoundId = "rbxassetid://"..bloodData["Sounds"][math.random(1,#bloodData["Sounds"])]
		sound.Volume = bloodData["Vol"] --loudness
		sound.PlaybackSpeed = Random.new():NextNumber(bloodData["PitchMin"], bloodData["PitchMax"])

		sound.Parent = soundPart

		if blocked == true then
			local blockedSound = sound:Clone()

			blockedSound.SoundId = "rbxassetid://10651801732"
			blockedSound.Volume = 1
			blockedSound.PlaybackSpeed = Random.new():NextNumber(1, 1.4)

			local muffle = Instance.new("EqualizerSoundEffect")
			muffle.HighGain = -25
			muffle.MidGain = -25

			muffle.Parent = sound

			blockedSound.Parent = soundPart
			blockedSound:Play()

			effect(bloodEffect, hitPart, 0.01, Color3.new(0.2), 0.2)
		else
			effect(bloodEffect, hitPart, 0.01, Color3.new(0.2), 1)
		end

		sound.Parent = soundPart

		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end

		sound:Play()
		debris:AddItem(soundPart, sound.TimeLength / sound.PlaybackSpeed)
	end
end

local function bulletHole(rayResult,gun,gunData)
	local holeData = gunData.Hole
	if holeData then
		local materialCategory = getMaterialCategory(rayResult.Instance.Material.Name)

		local hitPart = rayResult.Instance	
		local surfaceCF = CFrame.new(rayResult.Position, rayResult.Position + rayResult.Normal)

		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = surfaceCF
		Attachment.Parent = workspace.Terrain

		local Hole = Instance.new("Part")
		Hole.Name = "BulletHole"
		Hole.Transparency = 1
		Hole.Anchored = true
		Hole.CanCollide = false
		Hole.FormFactor = "Custom"
		Hole.Size = Vector3.new(1, 1, 0.2)

		local Mesh = Instance.new("BlockMesh")
		Mesh.Offset = Vector3.new()
		Mesh.Scale = Vector3.new(holeData["Size"], holeData["Size"], 0)
		Mesh.Parent = Hole

		local Decal = Instance.new("Decal")
		Decal.Face = Enum.NormalId.Front
		Decal.Texture = "rbxassetid://"..holeData["Textures"][math.random(1,#holeData["Textures"])]

		local hitPartColor = Color3.new(1, 1, 1)
		if holeData["PartColour"] then
			if hitPart then
				if hitPart.Color then
					hitPartColor = hitPart.Color
				elseif hitPart and hitPart:IsA("Terrain") then
					local material = rayResult.Material
					if material ~= Enum.Material.Water then
						hitPartColor = workspace.Terrain:GetMaterialColor(rayResult.Material)
					else
						hitPartColor = workspace.Terrain.WaterColor
					end
				end
				Decal.Color3 = hitPartColor
			end
		end

		local hitEffect = gunData.HitEffect or game.ReplicatedStorage.GunEffects.DefaultHitEffect 
		effect(hitEffect[materialCategory],Hole,0.01,hitPartColor)

		Decal.Parent = Hole
		Hole.Parent = workspace.GunEffects
		Hole.CFrame = surfaceCF * CFrame.Angles(0, 0, math.random(0, 360))

		if (not hitPart.Anchored) then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = Hole
			weld.Part1 = hitPart
			weld.Parent = Hole
			Hole.Anchored = false
		end

		delay(holeData["LifeTime"], function()
			tweenService:Create(Hole,TweenInfo.new(0.5),{Transparency = 1})
			wait(0.5)
			Hole:Destroy()
		end)
	end
end

local function livingHit(rayResult,gun,gunData,playerWhoShot,headshot,charge)
	local bloodData = gunData.Blood

	local character = localPlayer.Character
	if playerWhoShot == localPlayer then
		if character then
			local gunFirePoint = gun:FindFirstChild("GunFirePoint",true) and gun:FindFirstChild("GunFirePoint",true).WorldPosition or gun.Handle.Position

			gunHitRemote:FireServer(rayResult.Instance.Parent, gun, rayResult.Instance, charge, gunFirePoint, rayResult.Position)
			bindablesFolder.GunSystem.Shot:Fire(localPlayer, rayResult.Instance.Parent)
		end
	else
		local shotCharacter = rayResult.Instance.Parent
		if shotCharacter == character then
			bindablesFolder.GunSystem.Shot:Fire(playerWhoShot, character)
		end
	end

	-- Blood effects were binded to gunHitRemote instead of here so that they accurately protray hits.
end

local function wallHit(rayResult, gun, gunData, scriptedObject, charge)
	if rayResult == nil then return end

	local hitPart = rayResult.Instance
	local surfaceHitData = gunData.SurfaceHitSounds

	if surfaceHitData then
		local materialCategory = getMaterialCategory(hitPart.Material.Name)

		local soundPart = script.SoundPart:Clone()
		soundPart.Parent = workspace.GunEffects
		soundPart.Position = rayResult.Position

		local sound = soundPart.Sound
		if surfaceHitData.Sounds == "Default" or surfaceHitData.Sounds == nil then
			local materialSoundData = HitSounds[materialCategory]
			sound.SoundId =  "rbxassetid://".. materialSoundData[math.random(#materialSoundData)]
		else
			sound.SoundId = "rbxassetid://"..surfaceHitData["Sounds"][math.random(1,#surfaceHitData["Sounds"])]
		end
		sound.Volume = surfaceHitData.Vol --loudness
		sound.PlaybackSpeed = Random.new():NextNumber(surfaceHitData.PitchMin, surfaceHitData.PitchMax)
		sound.Parent = soundPart		
		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end
		sound:Play()
		debris:AddItem(soundPart, sound.TimeLength / sound.PlaybackSpeed)
	end

	if not scriptedObject then
		bulletHole(rayResult,gun,gunData)
	else
		-- This object reacts to gun damage
		local character = localPlayer.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				gunHitRemote:FireServer(hitPart, gun, rayResult.Instance, charge, root.Position, rayResult.Position)
			end
		end
	end
end

local function shell(gun,shellData)
	if shellData then
		local Shell = script.Shell:Clone()
		local posPart = gun:FindFirstChild("ShellEjectPoint")

		if posPart then
			local pos = posPart.WorldCFrame
			Shell.CFrame = pos
			Shell.Size = shellData.PartSize
			Shell.CanCollide = shellData.Collide
			Shell.Velocity = gun.Handle.ShellEjectPoint.WorldCFrame.lookVector * shellData.Velocity
			Shell.RotVelocity = gun.Handle.ShellEjectPoint.WorldCFrame.lookVector * shellData.RotVelocity
			Shell.FileMesh.Scale = shellData.MeshSize
			Shell.FileMesh.MeshId = "rbxassetid://"..shellData.Mesh
			Shell.FileMesh.TextureId = "rbxassetid://"..shellData.Texture
			Shell.Parent = workspace.GunEffects
			debris:addItem(Shell,shellData.LifeTime)
		end
	end
end

local function raycast(gun,rayOrigin,rayDirection,blacklist)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = blacklist
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	return raycastResult
end

local function checkPlayerCanHit(gun, gunData, hitPlayer : Player, playerWhoShot : Player)
	local canHit = false
	if hitPlayer == nil then
		-- Not a player
		canHit = true
	elseif hitPlayer.Team ~= playerWhoShot.Team then
		-- Not on the same team
		canHit = true
		--elseif hitPlayer.Team == game.Teams["Test Subject"] and playerWhoShot.Team == game.Teams["Test Subject"] then
		--	-- Both are Test Subject
		--	canHit = true
	elseif gunData.FriendlyFire == true then
		-- Friendly fire is enabled
		canHit = true
	elseif gunData.Charge ~= nil and (playerWhoShot.Character:GetAttribute("Boxing") == true and hitPlayer.Character:GetAttribute("Boxing") == true) then
		-- Player is using melee + Both players are in a boxing ring
		canHit = true
	elseif gunData.Latex == true then
		-- Weapon is a latex.
		canHit = true
	end

	return canHit
end

-- Returns:
-- Can hit (boolean)
-- Humanoid
-- Gun hit module
-- Accessory
local function checkPartCanHit(hitPart : BasePart)
	local onGunHit = hitPart:FindFirstChild("OnGunHit")
	if onGunHit == nil then
		onGunHit = hitPart.Parent:FindFirstChild("OnGunHit")
	end

	-- I hate this piece of code SO much
	local accessory = nil
	local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")

	if hitPart.Parent:IsA("Accessory") then accessory = hitPart.Parent end

	if humanoid == nil and hitPart.Parent.Parent ~= nil then
		humanoid = hitPart.Parent.Parent:FindFirstChildOfClass("Humanoid")
		if accessory == nil and hitPart.Parent.Parent:IsA("Accessory") then accessory = hitPart.Parent.Parent end

		if humanoid == nil and hitPart.Parent.Parent.Parent ~= nil then
			humanoid = hitPart.Parent.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if accessory == nil and hitPart.Parent.Parent.Parent:IsA("Accessory") then accessory = hitPart.Parent.Parent.Parent end
		end
	end

	if (hitPart.CanCollide == true and hitPart.Transparency < 1) or hitPart.Name == "HITBOX" or (humanoid ~= nil and hitPart.Name ~= "e") or onGunHit ~= nil then
		return true, humanoid, onGunHit, accessory
	else
		return false, nil, nil, nil
	end
end

local headAttachmentNames = {
	["FaceCenterAttachment"] = true,
	["FaceFrontAttachment"] = true,
	["HairAttachment"] = true,
	["HatAttachment"] = true
}

local function createBullet(gun,gunData,pos,playerWhoShot,charge)
	local gunFirePoint =  gun:FindFirstChild("GunFirePoint",true) and gun:FindFirstChild("GunFirePoint",true).WorldPosition or gun.Handle.Position

	local triesLeft = 10
	--local pos = spread(gun,gunData,pos)
	local rayOrigin = gunFirePoint
	local rayDirection = (pos - gunFirePoint).Unit * gunData.Range
	--gun.Parent,

	local blacklist = {gun.Parent,workspace.GunEffects}

	for i,v in pairs(game.Players:GetDescendants()) do
		if v.Name == "HumanoidRootPart" then
			table.insert(blacklist,v)
		end
	end

	local rayResult, canHitPart, humanoid, onGunHit, accessory

	while triesLeft > 1 do
		-- print("Searching...")
		triesLeft -= 1
		rayResult = raycast(gun,rayOrigin,rayDirection,blacklist)

		if rayResult then
			rayOrigin = rayResult and rayResult.Position			
			table.insert(blacklist,rayResult.Instance)
		end

		if rayResult == nil then
			break
		else
			local hitPart = rayResult.Instance

			canHitPart, humanoid, onGunHit, accessory = checkPartCanHit(hitPart)
			if canHitPart == true then
				break
			end
		end
	end

	bulletTrail(gunFirePoint,rayResult and rayResult.Position or pos,gunData,playerWhoShot)
	shell(gun,gunData.Shell)

	if triesLeft > 1 then
		local directHitConnected = false

		if rayResult then
			local hitPart = rayResult.Instance

			if humanoid and onGunHit == nil then
				if accessory ~= nil then
					local attachment = accessory.Handle:FindFirstChildOfClass("Attachment")

					if attachment ~= nil and headAttachmentNames[attachment.Name] == true then
						hitPart = humanoid.Parent:FindFirstChild("Head")
					else
						hitPart = humanoid.Parent:FindFirstChild("Torso")
					end

					-- yes we are literally remaking RayResult from the ground up just to replace Instance
					rayResult = {
						["Distance"] = rayResult.Distance,
						["Instance"] = hitPart,
						["Material"] = rayResult.Material,
						["Position"] = rayResult.Position,
						["Normal"] = rayResult.Normal
					}
				end

				directHitConnected = true
				local hitPlayer = game.Players:GetPlayerFromCharacter(humanoid.Parent)

				local canHitPlayer = checkPlayerCanHit(gun, gunData, hitPlayer, playerWhoShot)
				if canHitPlayer then
					-- print("I got someone!")
					livingHit(rayResult,gun,gunData,playerWhoShot,hitPart.Name == "Head" and gunData.HeadshotMultiplier,charge)
				end
			else
				directHitConnected = true
				wallHit(rayResult, gun, gunData, onGunHit, charge)
			end
		end

		if directHitConnected == false then
			if gunData.Charge ~= nil and playerWhoShot == localPlayer then
				-- The direct hit might not have connected, but this is the player's own melee. Maybe the hitbox will connect. Let's see.

				--[[
				local hitbox
				if gun.Name == "Fists" or gun.Name == "Trained Fists" then
					-- Make an exception for fists, because they swing with both arms.
					hitbox = raycastHitbox:GetHitbox(localPlayer.Character)
					if hitbox == nil then
						hitbox = raycastHitbox.new(localPlayer.Character)
					else
						local points = {}
						for i,v in pairs(localPlayer.Character:GetDescendants()) do
							if v:IsA("Attachment") and v.Name == "DmgPoint" then
								table.insert(points, {v.Parent, v.Position})
							end
						end
						
						for i,pointInfo in pairs(points) do
							hitbox:SetPoints(pointInfo[1], {pointInfo[2]})
						end
					end
				else
					hitbox = raycastHitbox.new(gun)
				end
				
				-- hitbox.Visualizer = true

				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {localPlayer.Character}
				
				hitbox.RaycastParams = raycastParams
				hitbox.DetectionMode = 2
				]]

				local listening = true

				local dmgPoints = {}
				for i,v in pairs(localPlayer.Character:GetDescendants()) do
					if v:IsA("Attachment") and v.Name == "DmgPoint" then
						table.insert(dmgPoints, v)
					end
				end

				local function onHit(hitboxRaycastResult)
					if listening == false then return end

					local hitPart = hitboxRaycastResult.Instance

					if hitPart ~= nil then
						local canHitPart, humanoid, onGunHit = checkPartCanHit(hitPart)

						if canHitPart == true then
							-- Hitbox hits will only accept humanoids or parts with OnGunHit modules
							if humanoid ~= nil and onGunHit == nil then
								local hitPlayer = game.Players:GetPlayerFromCharacter(humanoid.Parent)

								local canHitPlayer = checkPlayerCanHit(gun, gunData, hitPlayer, playerWhoShot)
								if canHitPlayer then
									gunHitRemote:FireServer(humanoid.Parent, gun, hitPart, charge, gunFirePoint, hitPart.Position)
									return humanoid.Parent
								end
							elseif onGunHit ~= nil then
								wallHit(hitboxRaycastResult, gun, gunData, onGunHit, charge)
								return onGunHit.Parent
							end
						end

						return hitPart
					end

					return nil
				end

				local blacklist = {localPlayer.Character}

				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
				overlapParams.FilterDescendantsInstances = blacklist

				task.spawn(function()
					while listening == true do
						task.wait(0.016) -- 15 FPS
						for i,dmgPoint : Attachment in pairs(dmgPoints) do
							-- print("check")
							local hitboxDiameter = gunData.Range/4
							
							--[[
							local visualizer = Instance.new("Part")
							visualizer.Name = "HitboxVisualizer"
							
							visualizer.Material = Enum.Material.Neon
							visualizer.Color = Color3.new(1, 0, 0)
							visualizer.Transparency = 0.9
							visualizer.Anchored = true
							visualizer.CanCollide = false
							visualizer.CanTouch = false
							visualizer.CanQuery = false
							visualizer.Archivable = false
							
							visualizer.Shape = "Ball"
							visualizer.Size = Vector3.new(hitboxDiameter, hitboxDiameter, hitboxDiameter)
							visualizer.CFrame = CFrame.new(dmgPoint.WorldPosition)
							
							visualizer.Parent = workspace
							game.Debris:AddItem(visualizer, 0.016)
							]]

							local hitParts = workspace:GetPartBoundsInRadius(dmgPoint.WorldPosition, hitboxDiameter/2, overlapParams)
							for i,hitPart in pairs(hitParts) do
								-- print(i)
								local blacklisted = false
								for i,blacklistedInstance in pairs(blacklist) do
									if hitPart == blacklistedInstance or hitPart:IsDescendantOf(blacklistedInstance) then
										blacklisted = true 
										break
									end
								end

								if blacklisted == false then
									local newBlacklistItem = onHit({Distance = (dmgPoint.WorldPosition - hitPart.Position).Magnitude, ["Instance"] = hitPart, Material = hitPart.Material, Position = hitPart.Position})

									if newBlacklistItem ~= nil then
										-- local highlight = Instance.new("Highlight")
										-- highlight.Parent = newBlacklistItem
										-- game.Debris:AddItem(highlight, 0.5)

										table.insert(blacklist, newBlacklistItem)

										-- print("Added "..newBlacklistItem:GetFullName().." to blacklist")
										overlapParams.FilterDescendantsInstances = blacklist
									end
								end
							end
						end
					end
				end)

				--hitbox:HitStart() -- Turns on the hitbox
				task.wait(.25)
				if listening == true then
					-- We still didn't hit anything.
					listening = false
				end
			else
				wallHit(rayResult, gun, gunData, onGunHit, charge)
			end
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

local function vis(player,data)	
	local gun = player.Character and player.Character:FindFirstChildWhichIsA("Tool") 
	if gun and gun:FindFirstChild("GunData") and gun:FindFirstChild("Handle") and player.Character.Humanoid.Health > 0   then
		local gunData = require(gun.GunData)
		local gunData = deepCopy(gunData)
		if gunData.Charge then --data["Charge"] ~= 0 then
			gunData.Damage = gunData.Charge.Damage and gunData.Charge.Damage[data["Charge"]] or gunData.Damage
			if gunData.SurfaceHitSounds then
				gunData.SurfaceHitSounds.Sounds = gunData.Charge.SurfaceHitSounds and gunData.Charge.SurfaceHitSounds[data["Charge"]] or gunData.SurfaceHitSounds.Sounds
			end
			if gunData.Blood then
				gunData.Blood.Sounds = gunData.Charge.Blood and gunData.Charge.Blood[data["Charge"]] or gunData.Blood.Sounds
			end
			if gunData.Hole then
				gunData.Hole.Textures = gunData.Charge.Hole and gunData.Charge.Hole[data["Charge"]] or gunData.Hole.Textures
			end
		end

		local fireSounds = gun.Handle.FireSounds
		if data["Charge"] == 1 and gun.Handle:FindFirstChild("FireSoundsLow") then
			fireSounds = gun.Handle.FireSoundsLow
		elseif data["Charge"] == 2 and gun.Handle:FindFirstChild("FireSoundsMid") then
			fireSounds = gun.Handle.FireSoundsMid
		elseif data["Charge"] == 3 and gun.Handle:FindFirstChild("FireSoundsMax") then
			fireSounds = gun.Handle.FireSoundsMax
		end
		fireSounds = fireSounds:GetChildren()
		local selectedFireSound = fireSounds[math.random(#fireSounds)]
		selectedFireSound = selectedFireSound:Clone()
		selectedFireSound.Parent = gun.Handle
		selectedFireSound:Play()
		debris:AddItem(selectedFireSound,selectedFireSound.TimeLength)
		gun.GunData.Mag.Value -= gunData["Cost"] or 1

		local bulletpostable = data["Pos"]

		flash(gun,gunData.Flash) 
		for i=1,gunData.Bullets do
			task.spawn(function()
				createBullet(gun,gunData,bulletpostable[i],player,data["Charge"])
			end)
		end
	end
end

gunVisualizerRemote.OnClientEvent:Connect(function(...)
	vis(...)
end)

remotesFolder.Guns.LocalGunVisualizer.Event:Connect(function(...)
	vis(...)
end)

gunHitRemote.OnClientEvent:Connect(function(playerWhoShot, gunData, hitPart, hitPosition, blocked)
	-- if playerWhoShot ~= localPlayer then return end

	blood(gunData, hitPart, hitPosition, blocked)
end)