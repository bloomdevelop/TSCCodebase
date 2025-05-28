local UserInputService = game:GetService("UserInputService")
local InitialSensitivity = UserInputService.MouseDeltaSensitivity
local TweeningService = game:GetService("TweenService")
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character = workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild("Humanoid")
local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
local Module = require(Tool:WaitForChild("Setting"))
local GunScript_Server = Tool:WaitForChild("GunScript_Server")
local ChangeMagAndAmmo = GunScript_Server:WaitForChild("ChangeMagAndAmmo")
local ProjectileHandler = require(game.ReplicatedStorage:WaitForChild("Modules").ProjectileHandler)
local MuzzleHandler = require(game.ReplicatedStorage:WaitForChild("Modules").MuzzleHandler)
local AudioHandler = require(game.ReplicatedStorage:WaitForChild("Modules").AudioHandler)
local RemoteHandler = require(game.ReplicatedStorage:WaitForChild("Modules").RemoteHandler)
local Thread = require(game.ReplicatedStorage:WaitForChild("Modules").Thread)
local SmokeTrail = require(game.ReplicatedStorage:WaitForChild("Modules").SmokeTrail)
local ProjectileMotion = require(game.ReplicatedStorage:WaitForChild("Modules").ProjectileMotion) 
local MarkerEvent = script:WaitForChild("MarkerEvent")
local MagValue = GunScript_Server:WaitForChild("Mag")
local AmmoValue = GunScript_Server:WaitForChild("Ammo")
local GUI = script:WaitForChild("GunGUI")
local CrossFrame = GUI.Crosshair.Main
local CrossParts = {game.WaitForChild(CrossFrame,"HR"),game.WaitForChild(CrossFrame,"HL"),game.WaitForChild(CrossFrame,"VD"),game.WaitForChild(CrossFrame,"VU"),}
local IdleAnim
local FireAnim
local ReloadAnim
local TacticalReloadAnim
local ShotgunClipinAnim
local ShotgunPumpinAnim
local SecondaryShotgunPumpinAnim
local HoldDownAnim
local EquippedAnim
local SecondaryFireAnim
local AimIdleAnim
local AimFireAnim
local AimSecondaryFireAnim
local AimChargingAnim
local InspectAnim
local PreShotgunReloadAnim
local MinigunRevUpAnim
local MinigunRevDownAnim
local ChargingAnim
local Grip2
local Handle2
local HandleToFire = Handle
local CurrentRate = 0
local LastRate = 0
local ElapsedTime = 0
local ChargeLevel = 0
local Beam, Attach0, Attach1
local Connections = {}

local TargetEvent
if game:GetService("RunService"):IsClient() then
	TargetEvent = game:GetService("RunService").RenderStepped
else
	TargetEvent = game:GetService("RunService").Heartbeat
end

local spring = require(game.ReplicatedStorage:WaitForChild("Modules").Spring)
local oldPosition = Vector2.new()

--scope--

-- for the scope wiggle
local scope = spring.spring.new(Vector3.new(0,200,0))
scope.s = Module.ScopeSwaySpeed
scope.d = Module.ScopeSwayDamper
-- for the knockback wiggle
local knockback = spring.spring.new(Vector3.new())
knockback.s = Module.ScopeKnockbackSpeed
knockback.d = Module.ScopeKnockbackDamper

--camera--

local cameraspring = spring.spring.new(Vector3.new())
cameraspring.s	= Module.RecoilSpeed
cameraspring.d	= Module.RecoilDamper

--crosshair--

local crossscale = spring.spring.new(0)	
crossscale.s = 10	
crossscale.d = 0.8
crossscale.t = 1
local crossspring = spring.spring.new(0)
crossspring.s = 12
crossspring.d = 0.65

function setcrossscale(scale)
	crossscale.t = scale
end	

function setcrosssize(size)
	crossspring.t = size
end

function setcrosssettings(size,speed,damper)
	crossspring.t = size
	crossspring.s = speed
	crossspring.d = damper
end

--------------------------------------------------------------------------------------------------

if Module.DualEnabled then
	Handle2 = Tool:WaitForChild("Handle2",2)
	if Handle2 == nil and Module.DualEnabled then error("\"Dual\" setting is enabled but \"Handle2\" is missing!") end
end

local Equipped = false
local ActuallyEquipped = false
local Enabled = true
local Down = false
local HoldDown = false
local Reloading = false
local AimDown = false
local Scoping = false
local Inspecting = false
local Charging = false
local Mag = MagValue.Value
local Ammo = AmmoValue.Value
local MaxAmmo = Module.MaxAmmo

if Module.IdleAnimationID ~= nil or Module.DualEnabled then
	IdleAnim = Tool:WaitForChild("IdleAnim")
	IdleAnim = Humanoid:LoadAnimation(IdleAnim)
end
if Module.FireAnimationID ~= nil then
	FireAnim = Tool:WaitForChild("FireAnim")
	FireAnim = Humanoid:LoadAnimation(FireAnim)
end
if Module.ReloadAnimationID ~= nil then
	ReloadAnim = Tool:WaitForChild("ReloadAnim")
	ReloadAnim = Humanoid:LoadAnimation(ReloadAnim)
end
if Module.ShotgunClipinAnimationID ~= nil then
	ShotgunClipinAnim = Tool:WaitForChild("ShotgunClipinAnim")
	ShotgunClipinAnim = Humanoid:LoadAnimation(ShotgunClipinAnim)
end
if Module.ShotgunPumpinAnimationID ~= nil then
	ShotgunPumpinAnim = Tool:WaitForChild("ShotgunPumpinAnim")
	ShotgunPumpinAnim = Humanoid:LoadAnimation(ShotgunPumpinAnim)
end
if Module.SecondaryShotgunPumpinAnimationID ~= nil then
	SecondaryShotgunPumpinAnim = Tool:WaitForChild("SecondaryShotgunPumpinAnim")
	SecondaryShotgunPumpinAnim = Humanoid:LoadAnimation(SecondaryShotgunPumpinAnim)
end
if Module.HoldDownAnimationID ~= nil then
	HoldDownAnim = Tool:WaitForChild("HoldDownAnim")
	HoldDownAnim = Humanoid:LoadAnimation(HoldDownAnim)
end
if Module.EquippedAnimationID ~= nil then
	EquippedAnim = Tool:WaitForChild("EquippedAnim")
	EquippedAnim = Humanoid:LoadAnimation(EquippedAnim)
end
if Module.SecondaryFireAnimationEnabled and Module.SecondaryFireAnimationID ~= nil then
	SecondaryFireAnim = Tool:WaitForChild("SecondaryFireAnim")
	SecondaryFireAnim = Humanoid:LoadAnimation(SecondaryFireAnim)
end
if Module.AimAnimationsEnabled and Module.AimIdleAnimationID ~= nil then
	AimIdleAnim = Tool:WaitForChild("AimIdleAnim")
	AimIdleAnim = Humanoid:LoadAnimation(AimIdleAnim)
end
if Module.AimAnimationsEnabled and Module.AimFireAnimationID ~= nil then
	AimFireAnim = Tool:WaitForChild("AimFireAnim")
	AimFireAnim = Humanoid:LoadAnimation(AimFireAnim)
end
if Module.AimAnimationsEnabled and Module.AimSecondaryFireAnimationID ~= nil then
	AimSecondaryFireAnim = Tool:WaitForChild("AimSecondaryFireAnim")
	AimSecondaryFireAnim = Humanoid:LoadAnimation(AimSecondaryFireAnim)
end
if Module.AimAnimationsEnabled and Module.AimChargingAnimationID ~= nil then
	AimChargingAnim = Tool:WaitForChild("AimChargingAnim")
	AimChargingAnim = Humanoid:LoadAnimation(AimChargingAnim)
end
if Module.TacticalReloadAnimationEnabled and Module.TacticalReloadAnimationID ~= nil then
	TacticalReloadAnim = Tool:WaitForChild("TacticalReloadAnim")
	TacticalReloadAnim = Humanoid:LoadAnimation(TacticalReloadAnim)
end
if Module.InspectAnimationEnabled and Module.InspectAnimationID ~= nil then
	InspectAnim = Tool:WaitForChild("InspectAnim")
	InspectAnim = Humanoid:LoadAnimation(InspectAnim)
end
if Module.ShotgunReload and Module.PreShotgunReload and Module.PreShotgunReloadAnimationID ~= nil then
	PreShotgunReloadAnim = Tool:WaitForChild("PreShotgunReloadAnim")
	PreShotgunReloadAnim = Humanoid:LoadAnimation(PreShotgunReloadAnim)
end
if Module.MinigunRevUpAnimationID ~= nil then
	MinigunRevUpAnim = Tool:WaitForChild("MinigunRevUpAnim")
	MinigunRevUpAnim = Humanoid:LoadAnimation(MinigunRevUpAnim)
end
if Module.MinigunRevDownAnimationID ~= nil then
	MinigunRevDownAnim = Tool:WaitForChild("MinigunRevDownAnim")
	MinigunRevDownAnim = Humanoid:LoadAnimation(MinigunRevDownAnim)
end
if Module.ChargingAnimationEnabled and Module.ChargingAnimationID ~= nil then
	ChargingAnim = Tool:WaitForChild("ChargingAnim")
	ChargingAnim = Humanoid:LoadAnimation(ChargingAnim)
end

local CurrentAimFireAnim
local CurrentAimFireAnimationSpeed
if Module.AimAnimationsEnabled then
	CurrentAimFireAnim = AimFireAnim
	CurrentAimFireAnimationSpeed = Module.AimFireAnimationSpeed
end
local CurrentFireAnim = FireAnim
local CurrentFireAnimationSpeed = Module.FireAnimationSpeed
local CurrentShotgunPumpinAnim = ShotgunPumpinAnim
local CurrentShotgunPumpinAnimationSpeed = Module.ShotgunPumpinSpeed

local function numLerp(A, B, Alpha)
	return A + (B - A) * Alpha
end

local function RAND(Min, Max, Accuracy)
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end

local function AddressTableValue(v1, v2)
	if v1 ~= nil and Module.ChargedShotAdvanceEnabled then
		return ((ChargeLevel == 1 and v1.Level1) or (ChargeLevel == 2 and v1.Level2) or (ChargeLevel == 3 and v1.Level3) or v2)
	else
		return v2
	end
end

local function AntiWallshot(TipPos, Dir)
	local ray = Ray.new(Character.Head.Position, Dir.Unit * Dir.Magnitude)
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {Character, Camera})
	if (hit and hit.CanCollide and hit.Transparency ~= 1) and (pos - TipPos).Magnitude > 0.1 then
		--print("Wall shooting is illegal!!")
		return false
	else
		return true
	end
end

--Casts a ray. It will ignore nearly transparent objects and the tool's parent.
local function CastRay(StartPos,Direction,Length)
	local Hit, EndPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(StartPos,Direction * Length), {Camera})
	if Hit then
		if (not Tool.Parent or Hit:IsDescendantOf(Tool.Parent)) or Hit.Transparency > 0.9 then
			return CastRay(EndPos + (Direction * 0.01),Direction,Length - ((StartPos - EndPos).magnitude))
		end
	end

	return EndPos
end

--Casts the input's position to 3D space.
local function Get3DPosition(CurrentPosOnScreen)
	local InputRay = Camera:ScreenPointToRay(CurrentPosOnScreen.X, CurrentPosOnScreen.Y)
	local EndPos = InputRay.Origin + InputRay.Direction
	return CastRay(Camera.CFrame.p, (EndPos - Camera.CFrame.p).unit, 1000)
end

--Render functions--
function renderScope()	
	knockback.t = knockback.t:lerp(Vector3.new(), .2)
end

function renderMouse()
	local delta = UserInputService:GetMouseDelta() / Module.ScopeSensitive

	if Scoping and UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
		GUI.Scope.Position = UDim2.new(0, scope.p.x + (knockback.p.y * 1000), 0, scope.p.y + (knockback.p.x * 200))
		local offset = GUI.Scope.AbsoluteSize.x * 0.5
		scope.t = Vector3.new(Mouse.x - offset - delta.x, Mouse.y - offset - delta.y, 0)
		oldPosition = Vector2.new(Mouse.x, Mouse.y)
	elseif Scoping and UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then --For mobile version, but in first-person view
		GUI.Scope.Position = UDim2.new(0, scope.p.x + (knockback.p.y * 1000), 0, scope.p.y + (knockback.p.x * 200))
		local offset = GUI.Scope.AbsoluteSize.x * 0.5
		scope.t = Vector3.new(GUI.Crosshair.AbsolutePosition.X - offset - delta.x, GUI.Crosshair.AbsolutePosition.Y - offset - delta.y, 0)
		oldPosition = Vector2.new(GUI.Crosshair.AbsolutePosition.X, GUI.Crosshair.AbsolutePosition.Y)
	end

	GUI.Scope.Visible = Scoping
	if not Scoping then
		GUI.Crosshair.Main.Visible = true
		scope.t = Vector3.new(600, 200, 0)
	else
		GUI.Crosshair.Main.Visible = false
	end

	if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
		GUI.Crosshair.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)    
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude > 2 then --For mobile version, but in third-person view
		GUI.Crosshair.Position = UDim2.new(0.5, 0, 0.4, -50)
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude <= 2 then --For mobile version, but in first-person view
		GUI.Crosshair.Position = UDim2.new(0.5, -1, 0.5, -19)
	end
end

function renderCam()			
	Camera.CoordinateFrame = Camera.CoordinateFrame*CFrame.Angles(cameraspring.p.x,cameraspring.p.y,cameraspring.p.z)
end

function renderCrosshair()
	local size = crossspring.p*4*crossscale.p --*(char.speed/14*(1-0.8)*2+0.8)*(char.sprint+1)/2
	for i = 1, 4 do
		CrossParts[i].BackgroundTransparency = 1-size/20
	end
	CrossParts[1].Position = UDim2.new(0,size,0,0)
	CrossParts[2].Position = UDim2.new(0,-size-7,0,0)
	CrossParts[3].Position = UDim2.new(0,0,0,size)
	CrossParts[4].Position = UDim2.new(0,0,0,-size-7)
end

function renderRate(dt)
	ElapsedTime = ElapsedTime + dt
	if ElapsedTime >= 1 then
		ElapsedTime = 0
		CurrentRate = CurrentRate - LastRate
		LastRate = CurrentRate
	end
end

function renderMotion()
	local Position = Get3DPosition(GUI.Crosshair.AbsolutePosition)
	local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, Position)
	local direction	= cframe.lookVector

	if direction then
		ProjectileMotion.updateProjectilePath(Beam, Attach0, Attach1, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, direction * AddressTableValue(Module.ChargeAlterTable.BulletSpeed, Module.BulletSpeed), 3, AddressTableValue(Module.ChargeAlterTable.Acceleration, Module.Acceleration))
	end
end

--[[local lastTick = tick()

function renderScopeOLD()
	local deltaTime = tick() - lastTick
	lastTick = tick()
	
	if Scoping and UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
		GUI.Scope.Size = UDim2.new(numLerp(GUI.Scope.Size.X.Scale, 1.2, math.min(deltaTime * 5, 1)), 36, numLerp(GUI.Scope.Size.Y.Scale, 1.2, math.min(deltaTime * 5, 1)), 36)
		GUI.Scope.Position = UDim2.new(0, Mouse.X - GUI.Scope.AbsoluteSize.X / 2, 0, Mouse.Y - GUI.Scope.AbsoluteSize.Y / 2)
	elseif Scoping and UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then --For mobile version, but in first-person view
		GUI.Scope.Size = UDim2.new(numLerp(GUI.Scope.Size.X.Scale, 1.2, math.min(deltaTime * 5, 1)), 36, numLerp(GUI.Scope.Size.Y.Scale, 1.2, math.min(deltaTime * 5, 1)), 36)
	    GUI.Scope.Position = UDim2.new(0, GUI.Crosshair.AbsolutePosition.X - GUI.Scope.AbsoluteSize.X / 2, 0, GUI.Crosshair.AbsolutePosition.Y - GUI.Scope.AbsoluteSize.Y / 2)
	else
		GUI.Scope.Size = UDim2.new(0.6, 36, 0.6, 36)
		GUI.Scope.Position = UDim2.new(0, 0, 0, 0)
	end
	
	GUI.Scope.Visible = Scoping
	
    if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
	    GUI.Crosshair.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)    
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude > 2 then --For mobile version, but in third-person view
	    GUI.Crosshair.Position = UDim2.new(0.5, 0, 0.4, -50)
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude <= 2 then --For mobile version, but in first-person view
	    GUI.Crosshair.Position = UDim2.new(0.5, -1, 0.5, -19)
    end
	
end]]

--------------------

MarkerEvent.Event:connect(function(IsHeadshot)
	pcall(function()
		if Module.HitmarkerEnabled then
			if IsHeadshot then
				GUI.Crosshair.Hitmarker.ImageColor3 = Module.HitmarkerColorHS
				GUI.Crosshair.Hitmarker.ImageTransparency = 0
				TweeningService:Create(GUI.Crosshair.Hitmarker, TweenInfo.new(Module.HitmarkerFadeTimeHS, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
				local markersound = GUI.Crosshair.MarkerSound:Clone()
				markersound.SoundId = "rbxassetid://"..Module.HitmarkerSoundID[math.random(1,#Module.HitmarkerSoundID)]
				markersound.PlaybackSpeed = Module.HitmarkerSoundPitchHS
				markersound.Parent = Player.PlayerGui
				markersound:Play()
				game:GetService("Debris"):addItem(markersound,1.15)
			else
				GUI.Crosshair.Hitmarker.ImageColor3 = Module.HitmarkerColor
				GUI.Crosshair.Hitmarker.ImageTransparency = 0
				TweeningService:Create(GUI.Crosshair.Hitmarker, TweenInfo.new(Module.HitmarkerFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
				local markersound = GUI.Crosshair.MarkerSound:Clone()
				markersound.SoundId = "rbxassetid://"..Module.HitmarkerSoundID[math.random(1,#Module.HitmarkerSoundID)]
				markersound.PlaybackSpeed = Module.HitmarkerSoundPitch
				markersound.Parent = Player.PlayerGui
				markersound:Play()
				game:GetService("Debris"):addItem(markersound,1.15)
			end
		end
	end)
end)

function EjectShell(ShootingHandle)
	if Module.BulletShellEnabled then
		local function spawner()
			local Shell = Instance.new("Part")
			Shell.CFrame = ShootingHandle.ShellEjectPoint.WorldCFrame
			Shell.Size = Module.ShellSize
			Shell.CanCollide = Module.AllowCollide
			Shell.Name = "Shell"
			Shell.Velocity = ShootingHandle.ShellEjectPoint.WorldCFrame.lookVector * Module.BulletShellVelocity
			Shell.RotVelocity = ShootingHandle.ShellEjectPoint.WorldCFrame.lookVector * Module.BulletShellRotVelocity
			Shell.Parent = workspace.CurrentCamera
			local shellmesh = Instance.new("SpecialMesh")
			shellmesh.Scale = Module.ShellScale
			shellmesh.MeshId = "rbxassetid://"..Module.ShellMeshID
			shellmesh.TextureId = "rbxassetid://"..Module.ShellTextureID
			shellmesh.MeshType = "FileMesh"
			shellmesh.Parent = Shell
			game:GetService("Debris"):addItem(Shell,Module.DisappearTime)
		end	
		Thread:Spawn(spawner)								
	end
end

function RecoilCamera()
	if Module.CameraRecoilingEnabled then
		local Recoil = AddressTableValue(Module.ChargeAlterTable.Recoil, Module.Recoil)
		local CurrentRecoil = Recoil * (AimDown and 1-Module.RecoilRedution or 1)
		local RecoilX = math.rad(CurrentRecoil * RAND(Module.AngleX_Min, Module.AngleX_Max, Module.Accuracy))
		local RecoilY = math.rad(CurrentRecoil * RAND(Module.AngleY_Min, Module.AngleY_Max, Module.Accuracy))
		local RecoilZ = math.rad(CurrentRecoil * RAND(Module.AngleZ_Min, Module.AngleZ_Max, Module.Accuracy))
		cameraspring:accelerate(Vector3.new(RecoilX, RecoilY, RecoilZ))
		Thread:Wait(0.03)
		cameraspring:accelerate(Vector3.new(-RecoilX, -RecoilY, 0))
	end
end

function SelfKnockback(p1, p2)
	local SelfKnockbackPower = AddressTableValue(Module.ChargeAlterTable.SelfKnockbackPower, Module.SelfKnockbackPower)
	local SelfKnockbackMultiplier = AddressTableValue(Module.ChargeAlterTable.SelfKnockbackMultiplier, Module.SelfKnockbackMultiplier)
	local SelfKnockbackRedution = AddressTableValue(Module.ChargeAlterTable.SelfKnockbackRedution, Module.SelfKnockbackRedution)
	local Power = Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and SelfKnockbackPower * SelfKnockbackMultiplier * (1-SelfKnockbackRedution) or SelfKnockbackPower * SelfKnockbackMultiplier
	local VelocityMod = (p1 - p2).Unit
	local AirVelocity = Torso.Velocity - Vector3.new(0, Torso.Velocity.Y, 0) + Vector3.new(VelocityMod.X, 0, VelocityMod.Z) * -Power
	local TorsoFly = Instance.new("BodyVelocity")
	TorsoFly.MaxForce = Vector3.new(math.huge,0,math.huge)
	TorsoFly.Velocity = AirVelocity
	TorsoFly.Parent = Torso
	Torso.Velocity = Torso.Velocity + Vector3.new(0, VelocityMod.Y * 2, 0) * -Power
	game:GetService("Debris"):AddItem(TorsoFly, .25)			
end

function Fire(ShootingHandle, FireDirections)
	if Module.AimAnimationsEnabled and AimDown == true then
		if CurrentAimFireAnim then CurrentAimFireAnim:Play(nil,nil,CurrentAimFireAnimationSpeed) end
	else
		if CurrentFireAnim then CurrentFireAnim:Play(nil,nil,CurrentFireAnimationSpeed) end
	end
	if MinigunRevUpAnim and MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Stop() end
	--if FireAnim then FireAnim:Play(nil,nil,Module.FireAnimationSpeed) end
	--if not ShootingHandle.FireSound.Playing or not ShootingHandle.FireSound.Looped then ShootingHandle.FireSound:Play() end
	local hitEffectFolder = script:WaitForChild("HitEffect")
	local bloodEffectFolder = script:WaitForChild("BloodEffect")
	local explosionEffectFolder = script:WaitForChild("ExplosionEffect")
	if Module.ChargedShotAdvanceEnabled then
		if ChargeLevel == 1 then
			if script:FindFirstChild("HitEffectLvl1") then
				hitEffectFolder = script.HitEffectLvl1
			else
				hitEffectFolder = script.HitEffect
			end
			if script:FindFirstChild("BloodEffectLvl1") then
				bloodEffectFolder = script.BloodEffectLvl1
			else
				bloodEffectFolder = script.BloodEffect
			end
			if script:FindFirstChild("ExplosionEffectLvl1") then
				explosionEffectFolder = script.ExplosionEffectLvl1
			else
				explosionEffectFolder = script.ExplosionEffect
			end
		elseif ChargeLevel == 2 then
			if script:FindFirstChild("HitEffectLvl2") then
				hitEffectFolder = script.HitEffectLvl2
			else
				hitEffectFolder = script.HitEffect
			end
			if script:FindFirstChild("BloodEffectLvl2") then
				bloodEffectFolder = script.BloodEffectLvl2
			else
				bloodEffectFolder = script.BloodEffect
			end
			if script:FindFirstChild("ExplosionEffectLvl2") then
				explosionEffectFolder = script.ExplosionEffectLvl2
			else
				explosionEffectFolder = script.ExplosionEffect
			end
		elseif ChargeLevel == 3 then
			if script:FindFirstChild("HitEffectLvl3") then
				hitEffectFolder = script.HitEffectLvl3
			else
				hitEffectFolder = script.HitEffect
			end
			if script:FindFirstChild("BloodEffectLvl3") then
				bloodEffectFolder = script.BloodEffectLvl3
			else
				bloodEffectFolder = script.BloodEffect
			end
			if script:FindFirstChild("ExplosionEffectLvl3") then
				explosionEffectFolder = script.ExplosionEffectLvl3
			else
				explosionEffectFolder = script.ExplosionEffect
			end
		end
	end
	ProjectileHandler:SimulateProjectile(Tool,ShootingHandle,FireDirections,
		ShootingHandle:FindFirstChild("GunFirePoint"),
		{Module.HitEffectEnabled,AddressTableValue(Module.ChargeAlterTable.HitSoundIDs, Module.HitSoundIDs),AddressTableValue(Module.ChargeAlterTable.HitSoundPitchMin, Module.HitSoundPitchMin),AddressTableValue(Module.ChargeAlterTable.HitSoundPitchMax, Module.HitSoundPitchMax),AddressTableValue(Module.ChargeAlterTable.HitSoundVolume, Module.HitSoundVolume),hitEffectFolder,AddressTableValue(Module.ChargeAlterTable.CustomHitEffect, Module.CustomHitEffect)},
		{Module.BloodEnabled,AddressTableValue(Module.ChargeAlterTable.HitCharSndIDs, Module.HitCharSndIDs),AddressTableValue(Module.ChargeAlterTable.HitCharSndPitchMin, Module.HitCharSndPitchMin),AddressTableValue(Module.ChargeAlterTable.HitCharSndPitchMax, Module.HitCharSndPitchMax),AddressTableValue(Module.ChargeAlterTable.HitCharSndVolume, Module.HitCharSndVolume),bloodEffectFolder,{Module.BloodWoundEnabled, AddressTableValue(Module.ChargeAlterTable.BloodWoundSize, Module.BloodWoundSize), AddressTableValue(Module.ChargeAlterTable.BloodWoundTexture, Module.BloodWoundTexture), AddressTableValue(Module.ChargeAlterTable.BloodWoundTextureColor, Module.BloodWoundTextureColor), Module.BloodWoundVisibleTime, Module.BloodWoundFadeTime, AddressTableValue(Module.ChargeAlterTable.BloodWoundPartColor, Module.BloodWoundPartColor)}},
		{Module.BulletHoleEnabled,AddressTableValue(Module.ChargeAlterTable.BulletHoleSize, Module.BulletHoleSize),AddressTableValue(Module.ChargeAlterTable.BulletHoleTexture, Module.BulletHoleTexture),AddressTableValue(Module.ChargeAlterTable.PartColor, Module.PartColor),Module.BulletHoleVisibleTime,Module.BulletHoleFadeTime},
		{AddressTableValue(Module.ChargeAlterTable.ExplosiveEnabled, Module.ExplosiveEnabled),AddressTableValue(Module.ChargeAlterTable.ExplosionRadius, Module.ExplosionRadius),Module.ExplosionSoundEnabled,AddressTableValue(Module.ChargeAlterTable.ExplosionSoundIDs, Module.ExplosionSoundIDs),AddressTableValue(Module.ChargeAlterTable.ExplosionSoundPitchMin, Module.ExplosionSoundPitchMin),AddressTableValue(Module.ChargeAlterTable.ExplosionSoundPitchMax, Module.ExplosionSoundPitchMax),AddressTableValue(Module.ChargeAlterTable.ExplosionSoundVolume, Module.ExplosionSoundVolume),Module.CustomExplosion,explosionEffectFolder,Module.DamageBasedOnDistance,Module.ExplosionCraterEnabled,AddressTableValue(Module.ChargeAlterTable.ExplosionCraterSize, Module.ExplosionCraterSize),AddressTableValue(Module.ChargeAlterTable.ExplosionCraterTexture, Module.ExplosionCraterTexture),AddressTableValue(Module.ChargeAlterTable.ExplosionCraterPartColor, Module.ExplosionCraterPartColor),Module.ExplosionCraterVisibleTime,Module.ExplosionCraterFadeTime,Module.ExplosionKnockback,AddressTableValue(Module.ChargeAlterTable.ExplosionKnockbackPower, Module.ExplosionKnockbackPower),AddressTableValue(Module.ChargeAlterTable.ExplosionKnockbackMultiplierOnPlayer, Module.ExplosionKnockbackMultiplierOnPlayer),AddressTableValue(Module.ChargeAlterTable.ExplosionKnockbackMultiplierOnTarget, Module.ExplosionKnockbackMultiplierOnTarget)},
		{AddressTableValue(Module.ChargeAlterTable.ProjectileType, Module.ProjectileType),AddressTableValue(Module.ChargeAlterTable.BulletSpeed, Module.BulletSpeed),AddressTableValue(Module.ChargeAlterTable.Acceleration, Module.Acceleration),AddressTableValue(Module.ChargeAlterTable.Range, Module.Range),Module.PenetrationType,Module.CanSpinPart,AddressTableValue(Module.ChargeAlterTable.SpinX, Module.SpinX),AddressTableValue(Module.ChargeAlterTable.SpinY, Module.SpinY),AddressTableValue(Module.ChargeAlterTable.SpinZ, Module.SpinZ),AddressTableValue(Module.ChargeAlterTable.PenetrationDepth, Module.PenetrationDepth),AddressTableValue(Module.ChargeAlterTable.PenetrationAmount, Module.PenetrationAmount)},
		{Module.WhizSoundEnabled,Module.WhizSoundID,Module.WhizSoundPitchMin,Module.WhizSoundPitchMax,Module.WhizDistance,Module.WhizSoundVolume},
		{{AddressTableValue(Module.ChargeAlterTable.BaseDamage, Module.BaseDamage),AddressTableValue(Module.ChargeAlterTable.HeadshotDamageMultiplier, Module.HeadshotDamageMultiplier),Module.HeadshotEnabled,Module.DamageDropOffEnabled,AddressTableValue(Module.ChargeAlterTable.ZeroDamageDistance, Module.ZeroDamageDistance),AddressTableValue(Module.ChargeAlterTable.FullDamageDistance, Module.FullDamageDistance)},
		{AddressTableValue(Module.ChargeAlterTable.Knockback, Module.Knockback), AddressTableValue(Module.ChargeAlterTable.Lifesteal, Module.Lifesteal), Module.FlamingBullet, Module.FreezingBullet, GunScript_Server:FindFirstChild("IgniteScript"), GunScript_Server:FindFirstChild("IcifyScript"), AddressTableValue(Module.ChargeAlterTable.IgniteChance, Module.IgniteChance), AddressTableValue(Module.ChargeAlterTable.IcifyChance, Module.IcifyChance)},
		{Module.CriticalDamageEnabled,AddressTableValue(Module.ChargeAlterTable.CriticalBaseChance, Module.CriticalBaseChance),AddressTableValue(Module.ChargeAlterTable.CriticalDamageMultiplier, Module.CriticalDamageMultiplier)},
		{Module.GoreEffectEnabled,Module.GoreSoundIDs,Module.GoreSoundPitchMin,Module.GoreSoundPitchMax,Module.GoreSoundVolume,script:WaitForChild("GoreEffect")}})												
	RemoteHandler.Fire("SecureSettings",Tool,Module)
end

function Reload()
	if ActuallyEquipped and Enabled and not Reloading and (Ammo > 0 or not Module.LimitedAmmoEnabled) and Mag < Module.AmmoPerMag then
		Reloading = true
		if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
		if AimDown then
			TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			setcrossscale(1)
			if Module.AimAnimationsEnabled and AimIdleAnim and AimIdleAnim.IsPlaying then
				AimIdleAnim:Stop()
				if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end
			end
			--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
			if GUI then GUI:Destroy() end]]
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
		UpdateGUI()
		if Module.ShotgunReload then
			if Module.PreShotgunReload then
				if ActuallyEquipped then
					if PreShotgunReloadAnim then PreShotgunReloadAnim:Play(nil,nil,Module.PreShotgunReloadAnimationSpeed) end
					Handle.PreReloadSound:Play()					
				end
				local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.PreShotgunReloadSpeed
				--Thread:Wait(Module.PreShotgunReloadSpeed)
			end
			for i = 1,(Module.AmmoPerMag - Mag) do
				if ActuallyEquipped then
					if ShotgunClipinAnim then ShotgunClipinAnim:Play(nil,nil,Module.ShotgunClipinAnimationSpeed) end
					Handle.ShotgunClipin:Play()					
				end
				local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.ShellClipinSpeed
				--Thread:Wait(Module.ShellClipinSpeed)
				if ActuallyEquipped then
					if Module.LimitedAmmoEnabled then
						if Ammo > 0 then
							Mag = Mag + 1
							Ammo = Ammo - 1
							ChangeMagAndAmmo:FireServer(Mag,Ammo)
							UpdateGUI()						
						end
					else
						Mag = Mag + 1
						Ammo = Ammo - 1
						ChangeMagAndAmmo:FireServer(Mag,Ammo)
						UpdateGUI()	
					end
				end
				if Module.LimitedAmmoEnabled then
					if (not ActuallyEquipped) or (Ammo <= 0) then break end
				else
					if (not ActuallyEquipped) then break end
				end
			end
		end
		if ActuallyEquipped then
			if Module.TacticalReloadAnimationEnabled then
				if Mag > 0 then
					if TacticalReloadAnim then TacticalReloadAnim:Play(nil,nil,Module.TacticalReloadAnimationSpeed) end 
					Handle.TacticalReloadSound:Play()
				else
					if ReloadAnim then ReloadAnim:Play(nil,nil,Module.ReloadAnimationSpeed) end
					Handle.ReloadSound:Play()
				end
			else
				if ReloadAnim then ReloadAnim:Play(nil,nil,Module.ReloadAnimationSpeed) end
				Handle.ReloadSound:Play()
			end
		end
		local ReloadTime = (Mag > 0 and Module.TacticalReloadAnimationEnabled) and Module.TacticalReloadTime or Module.ReloadTime
		local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= ReloadTime
		--Thread:Wait((Mag > 0 and Module.TacticalReloadAnimationEnabled) and Module.TacticalReloadTime or Module.ReloadTime)
		if ActuallyEquipped then
			if not Module.ShotgunReload then
				if Module.LimitedAmmoEnabled then
					local ammoToUse = math.min(Module.AmmoPerMag - Mag, Ammo)
					Mag = Mag + ammoToUse
					Ammo = Ammo - ammoToUse
				else
					Mag = Module.AmmoPerMag
				end
				ChangeMagAndAmmo:FireServer(Mag,Ammo)
			end
		end
		Reloading = false
		UpdateGUI()
	end
end

function UpdateGUI()
	GUI.Frame.Mag.Fill:TweenSizeAndPosition(UDim2.new(Mag/Module.AmmoPerMag,0,1,0), UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
	GUI.Frame.Ammo.Fill:TweenSizeAndPosition(UDim2.new(Ammo/Module.MaxAmmo,0,1,0), UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
	GUI.Frame.Mag.Current.Text = Mag
	GUI.Frame.Mag.Max.Text = Module.AmmoPerMag
	GUI.Frame.Ammo.Current.Text = Ammo
	GUI.Frame.Ammo.Max.Text = Module.MaxAmmo

	GUI.Frame.Mag.Current.Visible = not Reloading
	GUI.Frame.Mag.Max.Visible = not Reloading
	GUI.Frame.Mag.Frame.Visible = not Reloading
	GUI.Frame.Mag.Reloading.Visible = Reloading

	GUI.Frame.Ammo.Current.Visible = not (Ammo <= 0)
	GUI.Frame.Ammo.Max.Visible = not (Ammo <= 0)
	GUI.Frame.Ammo.Frame.Visible = not (Ammo <= 0)
	GUI.Frame.Ammo.NoMoreAmmo.Visible = (Ammo <= 0)

	GUI.ChargeBar.Visible = Module.ChargedShotAdvanceEnabled
	GUI.ChargeBar.Level1.Position = UDim2.new(Module.Level1ChargingTime/Module.AdvancedChargingTime,0,0.5,0)
	GUI.ChargeBar.Level2.Position = UDim2.new(Module.Level2ChargingTime/Module.AdvancedChargingTime,0,0.5,0)

	GUI.Frame.Ammo.Visible = Module.LimitedAmmoEnabled
	GUI.Frame.Size = Module.LimitedAmmoEnabled and UDim2.new(0,250,0,100) or UDim2.new(0,250,0,55)
	GUI.Frame.Position = Module.ChargedShotAdvanceEnabled and (Module.LimitedAmmoEnabled and UDim2.new(1,-260,1,-150)or UDim2.new(1,-260,1,-105)) or (Module.LimitedAmmoEnabled and UDim2.new(1,-260,1,-110)or UDim2.new(1,-260,1,-95))
	GUI.MobileButtons.Visible = UserInputService.TouchEnabled --For mobile version
	GUI.MobileButtons.AimButton.Visible = Module.SniperEnabled or Module.IronsightEnabled
	GUI.MobileButtons.HoldDownButton.Visible = Module.HoldDownEnabled
	GUI.MobileButtons.InspectButton.Visible = Module.InspectAnimationEnabled
end

--------------------------------------------------------------------------------------------------

--= Mobile Functions =--

-- aiming

GUI.MobileButtons.AimButton.MouseButton1Click:connect(function()
	if not Reloading and not HoldDown and AimDown == false and ActuallyEquipped == true and Module.IronsightEnabled and (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude <= 1 then
		TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewIS}):Play()
		setcrossscale(Module.CrossScaleIS)
		if Module.AimAnimationsEnabled and IdleAnim and IdleAnim.IsPlaying then
			IdleAnim:Stop()
			if AimIdleAnim then AimIdleAnim:Play(nil,nil,Module.AimIdleAnimationSpeed) end
		end
		--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui") or Tool.ZoomGui:Clone()
		GUI.Parent = game:GetService("Players").LocalPlayer.PlayerGui]]
		--Scoping = false
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveIS
		AimDown = true
		if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
	elseif not Reloading and not HoldDown and AimDown == false and ActuallyEquipped == true and Module.SniperEnabled and (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude <= 1 then
		TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewS}):Play()
		setcrossscale(Module.CrossScaleS)
		if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
		if Module.AimAnimationsEnabled and IdleAnim and IdleAnim.IsPlaying then
			IdleAnim:Stop()
			if AimIdleAnim then AimIdleAnim:Play(nil,nil,Module.AimIdleAnimationSpeed) end
		end
		AimDown = true
		local StartTime = tick() repeat TargetEvent:Wait() if not (ActuallyEquipped or AimDown) then break end until (tick()-StartTime) >= Module.ScopeDelay
		if ActuallyEquipped and AimDown then
			--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui") or Tool.ZoomGui:Clone()
			GUI.Parent = game:GetService("Players").LocalPlayer.PlayerGui]]
			local zoomsound = GUI.Scope.ZoomSound:Clone()
			zoomsound.Parent = Player.PlayerGui
			zoomsound:Play()
			game:GetService("Debris"):addItem(zoomsound,5)
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveS
			Scoping = true
		end
	else
		TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
		setcrossscale(1)
		if Module.AimAnimationsEnabled and AimIdleAnim and AimIdleAnim.IsPlaying then
			AimIdleAnim:Stop()
			if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end
		end
		--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
		if GUI then GUI:Destroy() end]]
		Scoping = false
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseDeltaSensitivity = InitialSensitivity
		AimDown = false
	end
end)

-- holding down gun

GUI.MobileButtons.HoldDownButton.MouseButton1Click:connect(function()
	if not Reloading and ActuallyEquipped and Enabled and not HoldDown and Module.HoldDownEnabled then
		HoldDown = true
		if AimIdleAnim and AimIdleAnim.IsPlaying then AimIdleAnim:Stop() end
		if IdleAnim and IdleAnim.IsPlaying then IdleAnim:Stop() end
		if HoldDownAnim then HoldDownAnim:Play(nil,nil,Module.HoldDownAnimationSpeed) end
		if AimDown then
			TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			setcrossscale(1)
        	--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
        	if GUI then GUI:Destroy() end]]
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
	else
		HoldDown = false
		if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end
		if HoldDownAnim and HoldDownAnim.IsPlaying then HoldDownAnim:Stop() end
	end
end)

-- inspecting gun

GUI.MobileButtons.InspectButton.MouseButton1Click:connect(function()
	if not Reloading and ActuallyEquipped and Enabled and not AimDown and not Inspecting and Module.InspectAnimationEnabled then
		Inspecting = true
		if InspectAnim then InspectAnim:Play(nil,nil,Module.InspectAnimationSpeed) end
		local StartTime = tick() repeat TargetEvent:Wait() if ActuallyEquipped == false or Reloading == true or Enabled == false or AimDown == true then break end until (tick()-StartTime) >= InspectAnim.Length / InspectAnim.Speed
		Inspecting = false	
	end
end)

-- reloading

GUI.MobileButtons.ReloadButton.MouseButton1Click:connect(function()
	Reload()
end)

-- firing

GUI.MobileButtons.FireButton.MouseButton1Down:connect(function()
	if Module.ChargedShotAdvanceEnabled then
		Charging = true
		if ActuallyEquipped and Enabled and Charging and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) then
			Enabled = false
			if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
			if Module.AimAnimationsEnabled and AimDown == true then
				if AimChargingAnim and not AimChargingAnim.IsPlaying then AimChargingAnim:Play(nil,nil,Module.AimChargingAnimationSpeed) end
			else
				if ChargingAnim and not ChargingAnim.IsPlaying then ChargingAnim:Play(nil,nil,Module.ChargingAnimationSpeed) end
			end
			local ChargingSound = HandleToFire:FindFirstChild("ChargingSound")
			local StartTime = tick()
			while true do
				local DeltaTime = tick() - StartTime
				if ChargeLevel == 0 and DeltaTime >= Module.Level1ChargingTime then
					ChargeLevel = 1
					GUI.ChargeBar.ChargeLevel1:Play()
				elseif ChargeLevel == 1 and DeltaTime >= Module.Level2ChargingTime then
					ChargeLevel = 2
					GUI.ChargeBar.ChargeLevel2:Play()
				elseif ChargeLevel == 2 and DeltaTime >= Module.AdvancedChargingTime then
					ChargeLevel = 3
					GUI.ChargeBar.ChargeLevel3:Play()
					GUI.ChargeBar.Shine.UIGradient.Offset = Vector2.new(-1, 0)
					TweeningService:Create(GUI.ChargeBar.Shine.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)}):Play()
				end
				local ChargePercent = math.min(DeltaTime / Module.AdvancedChargingTime, 1)
				if ChargePercent < .5 then --Fade from red to yellow then to green
					GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1, ChargePercent * 2, 0)
				else
					GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1 - ((ChargePercent - .5) / .5), 1, 0)
				end
				GUI.ChargeBar.Fill.Size = UDim2.new(ChargePercent, 0, 1, 0)
				if ChargingSound then
					if not ChargingSound.Playing then ChargingSound:Play() end
					if Module.ChargingSoundIncreasePitch then
						ChargingSound.PlaybackSpeed = Module.ChargingSoundPitchRange[1] + (ChargePercent * (Module.ChargingSoundPitchRange[2] - Module.ChargingSoundPitchRange[1]))
					end
				end
				Thread:Wait()
				if ActuallyEquipped == false or Charging == false then
					break
				end
			end
			if AimChargingAnim and AimChargingAnim.IsPlaying then AimChargingAnim:Stop(0) end
			if ChargingAnim and ChargingAnim.IsPlaying then ChargingAnim:Stop(0) end
			GUI.ChargeBar.Fill.Size = UDim2.new(0,0,1,0)
			if ChargingSound then
				if ChargingSound.Playing then ChargingSound:Stop() end
				if Module.ChargingSoundIncreasePitch then ChargingSound.PlaybackSpeed = Module.ChargingSoundPitchRange[1] end
			end
			if not ActuallyEquipped then
				ChargeLevel = 0
				Enabled = true
			end
			if ActuallyEquipped and not Enabled and not Charging and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) then
				for i = 1, (Module.BurstFireEnabled and (AddressTableValue(Module.ChargeAlterTable.BulletPerBurst, Module.BulletPerBurst)) or 1) do
					if not ActuallyEquipped then break end
					local directions = {}
					--VVV Edit here VVV--
					knockback.t = 1 * Vector3.new(-1, -20 * .005, 0)
					--^^^ Edit here ^^^--
					Thread:Spawn(RecoilCamera)
					crossspring:accelerate(AddressTableValue(Module.ChargeAlterTable.CrossExpansion, Module.CrossExpansion))
					if not Module.ShotgunPump then
						Thread:Spawn(function()
							local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
							if ActuallyEquipped then EjectShell(HandleToFire) end
						end)
					end
					local soundFolder = HandleToFire.FireSounds
					if ChargeLevel == 1 then
						if HandleToFire:FindFirstChild("FireSoundsLvl1") then
							soundFolder = HandleToFire.FireSoundsLvl1
						else
							soundFolder = HandleToFire.FireSounds
						end
					elseif ChargeLevel == 2 then
						if HandleToFire:FindFirstChild("FireSoundsLvl2") then
							soundFolder = HandleToFire.FireSoundsLvl2
						else
							soundFolder = HandleToFire.FireSounds
						end
					elseif ChargeLevel == 3 then
						if HandleToFire:FindFirstChild("FireSoundsLvl3") then
							soundFolder = HandleToFire.FireSoundsLvl3
						else
							soundFolder = HandleToFire.FireSounds
						end
					end
					local tracks = soundFolder:GetChildren()
					local rn = math.random(1, #tracks)
					local track = tracks[rn]
					if track ~= nil then
						AudioHandler:PlayAudio({
							SoundId = track.SoundId,
							EmitterSize = track.EmitterSize,
							MaxDistance = track.MaxDistance,
							Volume = track.Volume,
							Pitch = track.PlaybackSpeed,
							Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint"),
							Echo = Module.EchoEffect,
							Silenced = Module.SilenceEffect
						},
						{
							Enabled = Module.LowAmmo,
							CurrentAmmo = Mag,
							AmmoPerMag = Module.AmmoPerMag,
							SoundId = HandleToFire.LowAmmoSound.SoundId,
							EmitterSize = HandleToFire.LowAmmoSound.EmitterSize,
							MaxDistance = HandleToFire.LowAmmoSound.MaxDistance,
							Volume = HandleToFire.LowAmmoSound.Volume,
							Pitch = Module.RaisePitch and (math.max(math.abs(Mag / 10 - 1), 0.4)) or HandleToFire.LowAmmoSound.PlaybackSpeed,
							Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint")
						},true)
					end
					local muzzleFolder = script:WaitForChild("MuzzleEffect")
					if ChargeLevel == 1 then
						if script:FindFirstChild("MuzzleEffectLvl1") then
							muzzleFolder = script.MuzzleEffectLvl1
						else
							muzzleFolder = script.MuzzleEffect
						end
					elseif ChargeLevel == 2 then
						if script:FindFirstChild("MuzzleEffectLvl2") then
							muzzleFolder = script.MuzzleEffectLvl2
						else
							muzzleFolder = script.MuzzleEffect
						end
					elseif ChargeLevel == 3 then
						if script:FindFirstChild("MuzzleEffectLvl3") then
							muzzleFolder = script.MuzzleEffectLvl3
						else
							muzzleFolder = script.MuzzleEffect
						end
					end
					MuzzleHandler:VisualizeMuzzle(HandleToFire,
						Module.MuzzleFlashEnabled,
						{Module.MuzzleLightEnabled,AddressTableValue(Module.ChargeAlterTable.LightBrightness, Module.LightBrightness),AddressTableValue(Module.ChargeAlterTable.LightColor, Module.LightColor),AddressTableValue(Module.ChargeAlterTable.LightRange, Module.LightRange),Module.LightShadows,Module.VisibleTime},
						muzzleFolder,
						true)
					CurrentRate = CurrentRate + Module.SmokeTrailRateIncrement
					for ii = 1, (Module.ShotgunEnabled and (AddressTableValue(Module.ChargeAlterTable.BulletPerShot, Module.BulletPerShot)) or 1) do
						local Position = Get3DPosition(GUI.Crosshair.AbsolutePosition)
						local spread = AddressTableValue(Module.ChargeAlterTable.Spread, Module.Spread)
						local currentSpread = spread * 10 * (AimDown and 1-Module.SpreadRedutionIS and 1-Module.SpreadRedutionS or 1)
						local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, Position)

						if Module.ShotgunPattern and Module.SpreadPattern then
							local x, y = Module.SpreadPattern[ii][1], Module.SpreadPattern[ii][2]
							cframe = cframe * CFrame.Angles(math.rad(currentSpread * y / 50), math.rad(currentSpread * x / 50), 0)
						else
							cframe = cframe * CFrame.Angles(math.rad(math.random(-currentSpread, currentSpread) / 50), math.rad(math.random(-currentSpread, currentSpread) / 50), 0)
						end

						local direction	= cframe.lookVector
						table.insert(directions, direction)
						--Fire(HandleToFire, direction)
					end
					if AddressTableValue(Module.ChargeAlterTable.SelfKnockback, Module.SelfKnockback) then
						local kbPosition = Get3DPosition(GUI.Crosshair.AbsolutePosition)
						SelfKnockback(kbPosition, Torso.Position)
					end
					Fire(HandleToFire, directions)
					Mag = Mag - 1
					ChangeMagAndAmmo:FireServer(Mag,Ammo)
					UpdateGUI()
					if Module.BurstFireEnabled then
						local BurstRate = AddressTableValue(Module.ChargeAlterTable.BurstRate, Module.BurstRate)
						local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= BurstRate
						--Thread:Wait(Module.BurstRate)
					end
					--if not ActuallyEquipped then break end
					if Mag <= 0 then break end
				end
				if not Module.ShotgunPump then
					HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

					if Module.AimAnimationsEnabled then
						CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
						CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
					end

					CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
					CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed	
				end
				Thread:Wait(AddressTableValue(Module.ChargeAlterTable.FireRate, Module.FireRate))
				if Mag <= 0 then
					if CurrentRate >= Module.MaximumRate and Module.SmokeTrailEnabled then
						Thread:Spawn(function()
							SmokeTrail:StopEmission()
							SmokeTrail:EmitSmokeTrail(HandleToFire, script.SmokeBeam, Module.MaximumTime)
						end)
					end				
				end
				if Module.ShotgunPump then
					if ActuallyEquipped then
						if CurrentShotgunPumpinAnim then CurrentShotgunPumpinAnim:Play(nil,nil,CurrentShotgunPumpinAnimationSpeed) end
						if HandleToFire:FindFirstChild("PumpSound") then HandleToFire.PumpSound:Play() end
						Thread:Spawn(function()
							local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
							if ActuallyEquipped then EjectShell(HandleToFire) end
						end)
					end
					HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

					if Module.AimAnimationsEnabled then
						CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
						CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
					end

					CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
					CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed

					CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == ShotgunPumpinAnim and Module.SecondaryShotgunPump) and SecondaryShotgunPumpinAnim or ShotgunPumpinAnim
					CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == Module.ShotgunPumpinAnimationSpeed and Module.SecondaryShotgunPump) and Module.SecondaryShotgunPumpinAnimationSpeed or Module.ShotgunPumpinAnimationSpeed
					Thread:Wait(Module.ShotgunPumpinSpeed)
				end
				ChargeLevel = 0
				Enabled = true
				if ActuallyEquipped and Module.AutoReload then
					if Mag <= 0 then Reload() end
				end
			end
		end
	else
		Down = true
		local IsChargedShot = false
		if ActuallyEquipped and Enabled and Down and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) then
			Enabled = false
			if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
			if Module.ChargedShotEnabled then
				if ActuallyEquipped and HandleToFire:FindFirstChild("ChargeSound") then HandleToFire.ChargeSound:Play() end
				Thread:Wait(Module.ChargingTime)
				IsChargedShot = true
			end
			if Module.MinigunEnabled then
				if MinigunRevUpAnim and not MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Play(nil,nil,Module.MinigunRevUpAnimationSpeed) end
				if ActuallyEquipped and HandleToFire:FindFirstChild("WindUp") then HandleToFire.WindUp:Play() end
				Thread:Wait(Module.DelayBeforeFiring)
			end
			while ActuallyEquipped and not Reloading and not HoldDown and (Down or IsChargedShot) and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) do
				IsChargedShot = false	
				for i = 1, (Module.BurstFireEnabled and Module.BulletPerBurst or 1) do
					if not ActuallyEquipped then break end
					local directions = {}
					--VVV Edit here VVV--
					knockback.t = 1 * Vector3.new(-1, -20 * .005, 0)
					--^^^ Edit here ^^^--
					Thread:Spawn(RecoilCamera)
					crossspring:accelerate(Module.CrossExpansion)
					if not Module.ShotgunPump then
						Thread:Spawn(function()
							local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
							if ActuallyEquipped then EjectShell(HandleToFire) end
						end)
					end
					local tracks = HandleToFire.FireSounds:GetChildren()
					local rn = math.random(1, #tracks)
					local track = tracks[rn]
					if track ~= nil then
						AudioHandler:PlayAudio({
							SoundId = track.SoundId,
							EmitterSize = track.EmitterSize,
							MaxDistance = track.MaxDistance,
							Volume = track.Volume,
							Pitch = track.PlaybackSpeed,
							Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint"),
							Echo = Module.EchoEffect,
							Silenced = Module.SilenceEffect
						},
						{
							Enabled = Module.LowAmmo,
							CurrentAmmo = Mag,
							AmmoPerMag = Module.AmmoPerMag,
							SoundId = HandleToFire.LowAmmoSound.SoundId,
							EmitterSize = HandleToFire.LowAmmoSound.EmitterSize,
							MaxDistance = HandleToFire.LowAmmoSound.MaxDistance,
							Volume = HandleToFire.LowAmmoSound.Volume,
							Pitch = Module.RaisePitch and (math.max(math.abs(Mag / 10 - 1), 0.4)) or HandleToFire.LowAmmoSound.PlaybackSpeed,
							Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint")
						},true)
					end
					MuzzleHandler:VisualizeMuzzle(HandleToFire,
						Module.MuzzleFlashEnabled,
						{Module.MuzzleLightEnabled,Module.LightBrightness,Module.LightColor,Module.LightRange,Module.LightShadows,Module.VisibleTime},
						script:WaitForChild("MuzzleEffect"),
						true)
					CurrentRate = CurrentRate + Module.SmokeTrailRateIncrement
					for ii = 1, (Module.ShotgunEnabled and Module.BulletPerShot or 1) do
						local Position = Get3DPosition(GUI.Crosshair.AbsolutePosition)
						local spread = Module.Spread * 10 * (AimDown and 1-Module.SpreadRedutionIS and 1-Module.SpreadRedutionS or 1)
						local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, Position)

						if Module.ShotgunPattern and Module.SpreadPattern then
							local x, y = Module.SpreadPattern[ii][1], Module.SpreadPattern[ii][2]
							cframe = cframe * CFrame.Angles(math.rad(spread * y / 50), math.rad(spread * x / 50), 0)
						else
							cframe = cframe * CFrame.Angles(math.rad(math.random(-spread, spread) / 50), math.rad(math.random(-spread, spread) / 50), 0)
						end

						local direction	= cframe.lookVector
						table.insert(directions, direction)
						--Fire(HandleToFire, direction)
					end
					if Module.SelfKnockback then
						local kbPosition = Get3DPosition(GUI.Crosshair.AbsolutePosition)
						SelfKnockback(kbPosition, Torso.Position)
					end
					Fire(HandleToFire, directions)
					Mag = Mag - 1
					ChangeMagAndAmmo:FireServer(Mag,Ammo)
					UpdateGUI()
					if Module.BurstFireEnabled then
						local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BurstRate
						--Thread:Wait(Module.BurstRate)
					end
					--if not ActuallyEquipped then break end
					if Mag <= 0 then break end
				end
				if not Module.ShotgunPump then
					HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

					if Module.AimAnimationsEnabled then
						CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
						CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
					end

					CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
					CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed				
				end
				Thread:Wait(Module.FireRate)
				if Mag <= 0 then
					if CurrentRate >= Module.MaximumRate and Module.SmokeTrailEnabled then
						Thread:Spawn(function()
							SmokeTrail:StopEmission()
							SmokeTrail:EmitSmokeTrail(HandleToFire, script.SmokeBeam, Module.MaximumTime)
						end)
					end				
				end
				if not Module.Auto then break end
			end
			--if HandleToFire.FireSound.Playing and HandleToFire.FireSound.Looped then HandleToFire.FireSound:Stop() end
			if Module.MinigunEnabled then
				if ActuallyEquipped and MinigunRevDownAnim and not MinigunRevDownAnim.IsPlaying then MinigunRevDownAnim:Play(nil,nil,Module.MinigunRevDownAnimationSpeed) end
				if MinigunRevUpAnim and MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Stop() end
				if ActuallyEquipped and HandleToFire:FindFirstChild("WindDown") then HandleToFire.WindDown:Play() end
				Thread:Wait(Module.DelayAfterFiring)
			end
			if Module.ShotgunPump then
				if ActuallyEquipped then
					if CurrentShotgunPumpinAnim then CurrentShotgunPumpinAnim:Play(nil,nil,CurrentShotgunPumpinAnimationSpeed) end
					if HandleToFire:FindFirstChild("PumpSound") then HandleToFire.PumpSound:Play() end
					Thread:Spawn(function()
						local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
						if ActuallyEquipped then EjectShell(HandleToFire) end
					end)
				end
				HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

				if Module.AimAnimationsEnabled then
					CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
					CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
				end

				CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
				CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed

				CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == ShotgunPumpinAnim and Module.SecondaryShotgunPump) and SecondaryShotgunPumpinAnim or ShotgunPumpinAnim
				CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == Module.ShotgunPumpinAnimationSpeed and Module.SecondaryShotgunPump) and Module.SecondaryShotgunPumpinAnimationSpeed or Module.ShotgunPumpinAnimationSpeed
				Thread:Wait(Module.ShotgunPumpinSpeed)
			end
			Enabled = true
			if ActuallyEquipped and Module.AutoReload then
				if Mag <= 0 then Reload() end
			end
		end
	end
end)

-- non firing

GUI.MobileButtons.FireButton.MouseButton1Up:connect(function()
	Down = false
	if Module.ChargedShotAdvanceEnabled then
		Charging = false
	end
	if CurrentRate >= Module.MaximumRate and Module.SmokeTrailEnabled then
		Thread:Spawn(function()
			SmokeTrail:StopEmission()
			SmokeTrail:EmitSmokeTrail(HandleToFire, script.SmokeBeam, Module.MaximumTime)
		end)
	end	
end)

--------------------------------------------------------------------------------------------------

Mouse.Button1Down:connect(function()
	if not UserInputService.TouchEnabled then
		if Module.ChargedShotAdvanceEnabled then
			Charging = true
			if ActuallyEquipped and Enabled and Charging and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) then
				Enabled = false
				if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
				if Module.AimAnimationsEnabled and AimDown == true then
					if AimChargingAnim and not AimChargingAnim.IsPlaying then AimChargingAnim:Play(nil,nil,Module.AimChargingAnimationSpeed) end
				else
					if ChargingAnim and not ChargingAnim.IsPlaying then ChargingAnim:Play(nil,nil,Module.ChargingAnimationSpeed) end
				end
				local ChargingSound = HandleToFire:FindFirstChild("ChargingSound")
				local StartTime = tick()
				while true do
					local DeltaTime = tick() - StartTime
					if ChargeLevel == 0 and DeltaTime >= Module.Level1ChargingTime then
						ChargeLevel = 1
						GUI.ChargeBar.ChargeLevel1:Play()
					elseif ChargeLevel == 1 and DeltaTime >= Module.Level2ChargingTime then
						ChargeLevel = 2
						GUI.ChargeBar.ChargeLevel2:Play()
					elseif ChargeLevel == 2 and DeltaTime >= Module.AdvancedChargingTime then
						ChargeLevel = 3
						GUI.ChargeBar.ChargeLevel3:Play()
						GUI.ChargeBar.Shine.UIGradient.Offset = Vector2.new(-1, 0)
						TweeningService:Create(GUI.ChargeBar.Shine.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)}):Play()
					end
					local ChargePercent = math.min(DeltaTime / Module.AdvancedChargingTime, 1)
					if ChargePercent < .5 then --Fade from red to yellow then to green
						GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1, ChargePercent * 2, 0)
					else
						GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1 - ((ChargePercent - .5) / .5), 1, 0)
					end
					GUI.ChargeBar.Fill.Size = UDim2.new(ChargePercent, 0, 1, 0)
					if ChargingSound then
						if not ChargingSound.Playing then ChargingSound:Play() end
						if Module.ChargingSoundIncreasePitch then
							ChargingSound.PlaybackSpeed = Module.ChargingSoundPitchRange[1] + (ChargePercent * (Module.ChargingSoundPitchRange[2] - Module.ChargingSoundPitchRange[1]))
						end
					end
					Thread:Wait()
					if ActuallyEquipped == false or Charging == false then
						break
					end
				end
				if AimChargingAnim and AimChargingAnim.IsPlaying then AimChargingAnim:Stop(0) end
				if ChargingAnim and ChargingAnim.IsPlaying then ChargingAnim:Stop(0) end
				GUI.ChargeBar.Fill.Size = UDim2.new(0,0,1,0)
				if ChargingSound then
					if ChargingSound.Playing then ChargingSound:Stop() end
					if Module.ChargingSoundIncreasePitch then ChargingSound.PlaybackSpeed = Module.ChargingSoundPitchRange[1] end
				end
				if not ActuallyEquipped then
					ChargeLevel = 0
					Enabled = true
				end
				if ActuallyEquipped and not Enabled and not Charging and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) then
					for i = 1, (Module.BurstFireEnabled and (AddressTableValue(Module.ChargeAlterTable.BulletPerBurst, Module.BulletPerBurst)) or 1) do
						if not ActuallyEquipped then break end
						local directions = {}
						--VVV Edit here VVV--
						knockback.t = 1 * Vector3.new(-1, -20 * .005, 0)
						--^^^ Edit here ^^^--
						Thread:Spawn(RecoilCamera)
						crossspring:accelerate(AddressTableValue(Module.ChargeAlterTable.CrossExpansion, Module.CrossExpansion))
						if not Module.ShotgunPump then
							Thread:Spawn(function()
								local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
								if ActuallyEquipped then EjectShell(HandleToFire) end
							end)
						end
						local soundFolder = HandleToFire.FireSounds
						if ChargeLevel == 1 then
							if HandleToFire:FindFirstChild("FireSoundsLvl1") then
								soundFolder = HandleToFire.FireSoundsLvl1
							else
								soundFolder = HandleToFire.FireSounds
							end
						elseif ChargeLevel == 2 then
							if HandleToFire:FindFirstChild("FireSoundsLvl2") then
								soundFolder = HandleToFire.FireSoundsLvl2
							else
								soundFolder = HandleToFire.FireSounds
							end
						elseif ChargeLevel == 3 then
							if HandleToFire:FindFirstChild("FireSoundsLvl3") then
								soundFolder = HandleToFire.FireSoundsLvl3
							else
								soundFolder = HandleToFire.FireSounds
							end
						end
						local tracks = soundFolder:GetChildren()
						local rn = math.random(1, #tracks)
						local track = tracks[rn]
						if track ~= nil then
							AudioHandler:PlayAudio({
								SoundId = track.SoundId,
								EmitterSize = track.EmitterSize,
								MaxDistance = track.MaxDistance,
								Volume = track.Volume,
								Pitch = track.PlaybackSpeed,
								Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint"),
								Echo = Module.EchoEffect,
								Silenced = Module.SilenceEffect
							},
							{
								Enabled = Module.LowAmmo,
								CurrentAmmo = Mag,
								AmmoPerMag = Module.AmmoPerMag,
								SoundId = HandleToFire.LowAmmoSound.SoundId,
								EmitterSize = HandleToFire.LowAmmoSound.EmitterSize,
								MaxDistance = HandleToFire.LowAmmoSound.MaxDistance,
								Volume = HandleToFire.LowAmmoSound.Volume,
								Pitch = Module.RaisePitch and (math.max(math.abs(Mag / 10 - 1), 0.4)) or HandleToFire.LowAmmoSound.PlaybackSpeed,
								Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint")
							},true)
						end
						local muzzleFolder = script:WaitForChild("MuzzleEffect")
						if ChargeLevel == 1 then
							if script:FindFirstChild("MuzzleEffectLvl1") then
								muzzleFolder = script.MuzzleEffectLvl1
							else
								muzzleFolder = script.MuzzleEffect
							end
						elseif ChargeLevel == 2 then
							if script:FindFirstChild("MuzzleEffectLvl2") then
								muzzleFolder = script.MuzzleEffectLvl2
							else
								muzzleFolder = script.MuzzleEffect
							end
						elseif ChargeLevel == 3 then
							if script:FindFirstChild("MuzzleEffectLvl3") then
								muzzleFolder = script.MuzzleEffectLvl3
							else
								muzzleFolder = script.MuzzleEffect
							end
						end
						MuzzleHandler:VisualizeMuzzle(HandleToFire,
							Module.MuzzleFlashEnabled,
							{Module.MuzzleLightEnabled,AddressTableValue(Module.ChargeAlterTable.LightBrightness, Module.LightBrightness),AddressTableValue(Module.ChargeAlterTable.LightColor, Module.LightColor),AddressTableValue(Module.ChargeAlterTable.LightRange, Module.LightRange),Module.LightShadows,Module.VisibleTime},
							muzzleFolder,
							true)
						CurrentRate = CurrentRate + Module.SmokeTrailRateIncrement
						for ii = 1, (Module.ShotgunEnabled and (AddressTableValue(Module.ChargeAlterTable.BulletPerShot, Module.BulletPerShot)) or 1) do
							local Position = Get3DPosition(GUI.Crosshair.AbsolutePosition)
							local spread = AddressTableValue(Module.ChargeAlterTable.Spread, Module.Spread)
							local currentSpread = spread * 10 * (AimDown and 1-Module.SpreadRedutionIS and 1-Module.SpreadRedutionS or 1)
							local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, Position)

							if Module.ShotgunPattern and Module.SpreadPattern then
								local x, y = Module.SpreadPattern[ii][1], Module.SpreadPattern[ii][2]
								cframe = cframe * CFrame.Angles(math.rad(currentSpread * y / 50), math.rad(currentSpread * x / 50), 0)
							else
								cframe = cframe * CFrame.Angles(math.rad(math.random(-currentSpread, currentSpread) / 50), math.rad(math.random(-currentSpread, currentSpread) / 50), 0)
							end

							local direction	= cframe.lookVector
							table.insert(directions, direction)
							--Fire(HandleToFire, direction)
						end
						if AddressTableValue(Module.ChargeAlterTable.SelfKnockback, Module.SelfKnockback) then
							local kbPosition = Get3DPosition(GUI.Crosshair.AbsolutePosition)
							SelfKnockback(kbPosition, Torso.Position)
						end
						Fire(HandleToFire, directions)
						Mag = Mag - 1
						ChangeMagAndAmmo:FireServer(Mag,Ammo)
						UpdateGUI()
						if Module.BurstFireEnabled then
							local BurstRate = AddressTableValue(Module.ChargeAlterTable.BurstRate, Module.BurstRate)
							local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= BurstRate
							--Thread:Wait(Module.BurstRate)
						end
						--if not ActuallyEquipped then break end
						if Mag <= 0 then break end
					end
					if not Module.ShotgunPump then
						HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

						if Module.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed	
					end
					Thread:Wait(AddressTableValue(Module.ChargeAlterTable.FireRate, Module.FireRate))
					if Mag <= 0 then
						if CurrentRate >= Module.MaximumRate and Module.SmokeTrailEnabled then
							Thread:Spawn(function()
								SmokeTrail:StopEmission()
								SmokeTrail:EmitSmokeTrail(HandleToFire, script.SmokeBeam, Module.MaximumTime)
							end)
						end				
					end
					if Module.ShotgunPump then
						if ActuallyEquipped then
							if CurrentShotgunPumpinAnim then CurrentShotgunPumpinAnim:Play(nil,nil,CurrentShotgunPumpinAnimationSpeed) end
							if HandleToFire:FindFirstChild("PumpSound") then HandleToFire.PumpSound:Play() end
							Thread:Spawn(function()
								local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
								if ActuallyEquipped then EjectShell(HandleToFire) end
							end)
						end
						HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

						if Module.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed

						CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == ShotgunPumpinAnim and Module.SecondaryShotgunPump) and SecondaryShotgunPumpinAnim or ShotgunPumpinAnim
						CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == Module.ShotgunPumpinAnimationSpeed and Module.SecondaryShotgunPump) and Module.SecondaryShotgunPumpinAnimationSpeed or Module.ShotgunPumpinAnimationSpeed
						Thread:Wait(Module.ShotgunPumpinSpeed)
					end
					ChargeLevel = 0
					Enabled = true
					if ActuallyEquipped and Module.AutoReload then
						if Mag <= 0 then Reload() end
					end
				end
			end
		else
			Down = true
			local IsChargedShot = false
			if ActuallyEquipped and Enabled and Down and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) then
				Enabled = false
				if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
				if Module.ChargedShotEnabled then
					if ActuallyEquipped and HandleToFire:FindFirstChild("ChargeSound") then HandleToFire.ChargeSound:Play() end
					Thread:Wait(Module.ChargingTime)
					IsChargedShot = true
				end
				if Module.MinigunEnabled then
					if MinigunRevUpAnim and not MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Play(nil,nil,Module.MinigunRevUpAnimationSpeed) end
					if ActuallyEquipped and HandleToFire:FindFirstChild("WindUp") then HandleToFire.WindUp:Play() end
					Thread:Wait(Module.DelayBeforeFiring)
				end
				while ActuallyEquipped and not Reloading and not HoldDown and (Down or IsChargedShot) and Mag > 0 and Humanoid.Health > 0 and AntiWallshot(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, HandleToFire:FindFirstChild("GunFirePoint").WorldPosition - Character.Head.Position) do
					IsChargedShot = false			
					for i = 1, (Module.BurstFireEnabled and Module.BulletPerBurst or 1) do
						if not ActuallyEquipped then break end
						local directions = {}
						--VVV Edit here VVV--
						knockback.t = 1 * Vector3.new(-1, -20 * .005, 0)
						--^^^ Edit here ^^^--
						Thread:Spawn(RecoilCamera)
						crossspring:accelerate(Module.CrossExpansion)
						if not Module.ShotgunPump then
							Thread:Spawn(function()
								local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
								if ActuallyEquipped then EjectShell(HandleToFire) end
							end)
						end
						local tracks = HandleToFire.FireSounds:GetChildren()
						local rn = math.random(1, #tracks)
						local track = tracks[rn]
						if track ~= nil then
							AudioHandler:PlayAudio({
								SoundId = track.SoundId,
								EmitterSize = track.EmitterSize,
								MaxDistance = track.MaxDistance,
								Volume = track.Volume,
								Pitch = track.PlaybackSpeed,
								Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint"),
								Echo = Module.EchoEffect,
								Silenced = Module.SilenceEffect
							},
							{
								Enabled = Module.LowAmmo,
								CurrentAmmo = Mag,
								AmmoPerMag = Module.AmmoPerMag,
								SoundId = HandleToFire.LowAmmoSound.SoundId,
								EmitterSize = HandleToFire.LowAmmoSound.EmitterSize,
								MaxDistance = HandleToFire.LowAmmoSound.MaxDistance,
								Volume = HandleToFire.LowAmmoSound.Volume,
								Pitch = Module.RaisePitch and (math.max(math.abs(Mag / 10 - 1), 0.4)) or HandleToFire.LowAmmoSound.PlaybackSpeed,
								Muzzle = HandleToFire:FindFirstChild("GunMuzzlePoint")
							},true)
						end
						MuzzleHandler:VisualizeMuzzle(HandleToFire,
							Module.MuzzleFlashEnabled,
							{Module.MuzzleLightEnabled,Module.LightBrightness,Module.LightColor,Module.LightRange,Module.LightShadows,Module.VisibleTime},
							script:WaitForChild("MuzzleEffect"),
							true)
						CurrentRate = CurrentRate + Module.SmokeTrailRateIncrement
						for ii = 1, (Module.ShotgunEnabled and Module.BulletPerShot or 1) do
							local Position = Get3DPosition(Mouse)
							local spread = Module.Spread * 10 * (AimDown and 1-Module.SpreadRedutionIS and 1-Module.SpreadRedutionS or 1)
							local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, Position)

							if Module.ShotgunPattern and Module.SpreadPattern then
								local x, y = Module.SpreadPattern[ii][1], Module.SpreadPattern[ii][2]
								cframe = cframe * CFrame.Angles(math.rad(spread * y / 50), math.rad(spread * x / 50), 0)
							else
								cframe = cframe * CFrame.Angles(math.rad(math.random(-spread, spread) / 50), math.rad(math.random(-spread, spread) / 50), 0)
							end

							local direction	= cframe.lookVector
							table.insert(directions, direction)
							--Fire(HandleToFire, direction)
						end
						if Module.SelfKnockback then
							local kbPosition = Get3DPosition(Mouse)
							SelfKnockback(kbPosition, Torso.Position)
						end
						Fire(HandleToFire, directions)
						Mag = Mag - 1
						ChangeMagAndAmmo:FireServer(Mag,Ammo)
						UpdateGUI()
						if Module.BurstFireEnabled then
							local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BurstRate
							--Thread:Wait(Module.BurstRate)
						end
						--if not ActuallyEquipped then break end
						if Mag <= 0 then break end
					end
					if not Module.ShotgunPump then
						HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

						if Module.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed	
					end
					Thread:Wait(Module.FireRate)
					if Mag <= 0 then
						if CurrentRate >= Module.MaximumRate and Module.SmokeTrailEnabled then
							Thread:Spawn(function()
								SmokeTrail:StopEmission()
								SmokeTrail:EmitSmokeTrail(HandleToFire, script.SmokeBeam, Module.MaximumTime)
							end)
						end				
					end
					if not Module.Auto then break end
				end
				--if HandleToFire.FireSound.Playing and HandleToFire.FireSound.Looped then HandleToFire.FireSound:Stop() end
				if Module.MinigunEnabled then
					if ActuallyEquipped and MinigunRevDownAnim and not MinigunRevDownAnim.IsPlaying then MinigunRevDownAnim:Play(nil,nil,Module.MinigunRevDownAnimationSpeed) end
					if MinigunRevUpAnim and MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Stop() end
					if ActuallyEquipped and HandleToFire:FindFirstChild("WindDown") then HandleToFire.WindDown:Play() end
					Thread:Wait(Module.DelayAfterFiring)
				end
				if Module.ShotgunPump then
					if ActuallyEquipped then
						if CurrentShotgunPumpinAnim then CurrentShotgunPumpinAnim:Play(nil,nil,CurrentShotgunPumpinAnimationSpeed) end
						if HandleToFire:FindFirstChild("PumpSound") then HandleToFire.PumpSound:Play() end
						Thread:Spawn(function()
							local StartTime = tick() repeat TargetEvent:Wait() if not ActuallyEquipped then break end until (tick()-StartTime) >= Module.BulletShellDelay
							if ActuallyEquipped then EjectShell(HandleToFire) end
						end)
					end
					HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle

					if Module.AimAnimationsEnabled then
						CurrentAimFireAnim = (CurrentAimFireAnim == AimFireAnim and Module.SecondaryFireAnimationEnabled) and AimSecondaryFireAnim or AimFireAnim
						CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
					end

					CurrentFireAnim = (CurrentFireAnim == FireAnim and Module.SecondaryFireAnimationEnabled) and SecondaryFireAnim or FireAnim
					CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == Module.FireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.SecondaryFireAnimationSpeed or Module.FireAnimationSpeed

					CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == ShotgunPumpinAnim and Module.SecondaryShotgunPump) and SecondaryShotgunPumpinAnim or ShotgunPumpinAnim
					CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == Module.ShotgunPumpinAnimationSpeed and Module.SecondaryShotgunPump) and Module.SecondaryShotgunPumpinAnimationSpeed or Module.ShotgunPumpinAnimationSpeed
					Thread:Wait(Module.ShotgunPumpinSpeed)
				end
				Enabled = true
				if ActuallyEquipped and Module.AutoReload then
					if Mag <= 0 then Reload() end
				end
			end			
		end
	end
end)

Mouse.Button1Up:connect(function()
	if not UserInputService.TouchEnabled then
		Down = false
		if Module.ChargedShotAdvanceEnabled then
			Charging = false
		end
		if CurrentRate >= Module.MaximumRate and Module.SmokeTrailEnabled then
			Thread:Spawn(function()
				SmokeTrail:StopEmission()
				SmokeTrail:EmitSmokeTrail(HandleToFire, script.SmokeBeam, Module.MaximumTime)
			end)
		end	
	end
end)

ChangeMagAndAmmo.OnClientEvent:connect(function(ChangedMag,ChangedAmmo)
	Mag = ChangedMag
	Ammo = ChangedAmmo
	UpdateGUI()
end)

Tool.Equipped:connect(function(TempMouse)
	Equipped = true
	if Module.AmmoPerMag ~= math.huge then GUI.Frame.Visible = true end
	GUI.Parent = Player.PlayerGui
	UpdateGUI()
	Handle.EquippedSound:Play()
	if Module.WalkSpeedRedutionEnabled then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed - Module.WalkSpeedRedution
	else
		Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	setcrosssettings(Module.CrossSize, Module.CrossSpeed, Module.CrossDamper)
	UserInputService.MouseIconEnabled = false
	if Module.ProjectileMotion then
		Beam, Attach0, Attach1 = ProjectileMotion.showProjectilePath(script:WaitForChild("MotionBeam"), HandleToFire:FindFirstChild("GunFirePoint").WorldPosition, Vector3.new(), 3, AddressTableValue(Module.ChargeAlterTable.Acceleration, Module.Acceleration))
	end

	table.insert(Connections, TargetEvent:connect(function(dt)			
		--Update crosshair and scope
		renderMouse()
		renderScope()
		renderCrosshair()
		--Update camera
		renderCam()
		--Update rate
		renderRate(dt)
		--Render motion
		if Module.ProjectileMotion then
			renderMotion()
		end
	end))

	if EquippedAnim then EquippedAnim:Play(nil,nil,Module.EquippedAnimationSpeed) end
	if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end

	if Module.DualEnabled and not workspace.FilteringEnabled then
		Handle2.CanCollide = false
		local LeftArm = Tool.Parent:FindFirstChild("Left Arm") or Tool.Parent:FindFirstChild("LeftHand")
		local RightArm = Tool.Parent:FindFirstChild("Right Arm") or Tool.Parent:FindFirstChild("RightHand")
		if RightArm then
			local Grip = RightArm:WaitForChild("RightGrip",0.01)
			if Grip then
				Grip2 = Grip:Clone()
				Grip2.Name = "LeftGrip"
				Grip2.Part0 = LeftArm
				Grip2.Part1 = Handle2
				--Grip2.C1 = Grip2.C1:inverse()
				Grip2.Parent = LeftArm
			end
		end
	end

	local StartTime = tick() repeat TargetEvent:Wait() if not Equipped then break end until (tick()-StartTime) >= Module.EquipTime
	if Equipped then ActuallyEquipped = true end

	if ActuallyEquipped and Module.AutoReload and not Reloading and (Ammo > 0 or not Module.LimitedAmmoEnabled) and Mag <= 0 then
		Reload()
	end

	TempMouse.KeyDown:connect(function(Key)
		if string.lower(Key) == "r" then
			Reload()
		elseif string.lower(Key) == "e" then
			if not Reloading and ActuallyEquipped and Enabled and not HoldDown and Module.HoldDownEnabled then
				HoldDown = true
				if AimIdleAnim and AimIdleAnim.IsPlaying then AimIdleAnim:Stop() end
				if IdleAnim and IdleAnim.IsPlaying then IdleAnim:Stop() end
				if HoldDownAnim then HoldDownAnim:Play(nil,nil,Module.HoldDownAnimationSpeed) end
				if AimDown then 
					TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
					setcrossscale(1)
			        --[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
			        if GUI then GUI:Destroy() end]]
					Scoping = false
					game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
					UserInputService.MouseDeltaSensitivity = InitialSensitivity
					AimDown = false
				end
			else
				HoldDown = false
				if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end
				if HoldDownAnim and HoldDownAnim.IsPlaying then HoldDownAnim:Stop() end
			end
		elseif string.lower(Key) == "f" then
			if not Reloading and ActuallyEquipped and Enabled and not AimDown and not Inspecting and Module.InspectAnimationEnabled then
				Inspecting = true
				if InspectAnim then InspectAnim:Play(nil,nil,Module.InspectAnimationSpeed) end
				local StartTime = tick() repeat TargetEvent:Wait() if ActuallyEquipped == false or Reloading == true or Enabled == false or AimDown == true then break end until (tick()-StartTime) >= InspectAnim.Length / InspectAnim.Speed
				Inspecting = false	
			end
		end
	end)

	Mouse.Button2Down:connect(function()
		if not Reloading and not HoldDown and AimDown == false and ActuallyEquipped == true and Module.IronsightEnabled and (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude <= 1 then
			TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewIS}):Play()
			setcrossscale(Module.CrossScaleIS)
			if Module.AimAnimationsEnabled and IdleAnim and IdleAnim.IsPlaying then
				IdleAnim:Stop()
				if AimIdleAnim then AimIdleAnim:Play(nil,nil,Module.AimIdleAnimationSpeed) end
			end
			--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui") or Tool.ZoomGui:Clone()
			GUI.Parent = game:GetService("Players").LocalPlayer.PlayerGui]]
			--Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveIS
			AimDown = true
			if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
		elseif not Reloading and not HoldDown and AimDown == false and ActuallyEquipped == true and Module.SniperEnabled and (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude <= 1 then
			TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewS}):Play()
			setcrossscale(Module.CrossScaleS)
			if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
			if Module.AimAnimationsEnabled and IdleAnim and IdleAnim.IsPlaying then
				IdleAnim:Stop()
				if AimIdleAnim then AimIdleAnim:Play(nil,nil,Module.AimIdleAnimationSpeed) end
			end
			AimDown = true
			local StartTime = tick() repeat TargetEvent:Wait() if not (ActuallyEquipped or AimDown) then break end until (tick()-StartTime) >= Module.ScopeDelay
			if ActuallyEquipped and AimDown then
				--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui") or Tool.ZoomGui:Clone()
				GUI.Parent = game:GetService("Players").LocalPlayer.PlayerGui]]
				local zoomsound = GUI.Scope.ZoomSound:Clone()
				zoomsound.Parent = Player.PlayerGui
				zoomsound:Play()
				game:GetService("Debris"):addItem(zoomsound,5)
				game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
				UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveS
				Scoping = true
			end
		end
	end)

	Mouse.Button2Up:connect(function()
		if AimDown then
			TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			setcrossscale(1)
			if Module.AimAnimationsEnabled and AimIdleAnim and AimIdleAnim.IsPlaying then
				AimIdleAnim:Stop()
				if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end
			end
			--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
			if GUI then GUI:Destroy() end]]
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
	end)
end)

Tool.Unequipped:connect(function()
	SmokeTrail:StopEmission()
	if Module.ChargedShotAdvanceEnabled then
		Charging = false
	end
	Equipped = false
	HoldDown = false
	ActuallyEquipped = false
	GUI.Parent = script
	GUI.Frame.Visible = false
	if Module.WalkSpeedRedutionEnabled then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed + Module.WalkSpeedRedution
	else
		Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	UserInputService.MouseIconEnabled = true
	for _,c in pairs(Connections) do
		c:disconnect()
	end
	Connections = {}
	if Beam then
		Beam:Destroy()
		Beam = nil
	end
	if Attach0 then
		Attach0:Destroy()
		Attach0 = nil
	end
	if Attach1 then
		Attach1:Destroy()
		Attach1 = nil
	end
	if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
	if AimIdleAnim and AimIdleAnim.IsPlaying then AimIdleAnim:Stop() end
	if IdleAnim and IdleAnim.IsPlaying then IdleAnim:Stop() end
	if PreShotgunReloadAnim and PreShotgunReloadAnim.IsPlaying then PreShotgunReloadAnim:Stop() end
	if Handle.PreReloadSound.IsPlaying then Handle.PreReloadSound:Stop() end
	if ShotgunClipinAnim and ShotgunClipinAnim.IsPlaying then ShotgunClipinAnim:Stop() end
	if Handle.ShotgunClipin.IsPlaying then Handle.ShotgunClipin:Stop() end
	if TacticalReloadAnim and TacticalReloadAnim.IsPlaying then TacticalReloadAnim:Stop() end 
	if Handle.TacticalReloadSound.IsPlaying then Handle.TacticalReloadSound:Stop() end
	if ReloadAnim and ReloadAnim.IsPlaying then ReloadAnim:Stop() end
	if Handle.ReloadSound.IsPlaying then Handle.ReloadSound:Stop() end
	if CurrentAimFireAnim and CurrentAimFireAnim.IsPlaying then CurrentAimFireAnim:Stop() end
	if CurrentFireAnim and CurrentFireAnim.IsPlaying then CurrentFireAnim:Stop() end
	if CurrentShotgunPumpinAnim and CurrentShotgunPumpinAnim.IsPlaying then CurrentShotgunPumpinAnim:Stop() end
	if HandleToFire.ChargeSound.IsPlaying then HandleToFire.ChargeSound:Stop() end
	if HandleToFire.WindUp.IsPlaying then HandleToFire.WindUp:Stop() end
	if HandleToFire.WindDown.IsPlaying then HandleToFire.WindDown:Stop() end
	if HandleToFire.PumpSound.IsPlaying then HandleToFire.PumpSound:Stop() end
	if HoldDownAnim and HoldDownAnim.IsPlaying then HoldDownAnim:Stop() end
	if MinigunRevDownAnim and MinigunRevDownAnim.IsPlaying then MinigunRevDownAnim:Stop() end
	if MinigunRevUpAnim and MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Stop() end
	if AimDown then
		TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
		setcrossscale(1)
		--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
		if GUI then GUI:Destroy() end]]
		Scoping = false
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseDeltaSensitivity = InitialSensitivity
		AimDown = false
	end
	if Module.DualEnabled and not workspace.FilteringEnabled then
		Handle2.CanCollide = true
		if Grip2 then Grip2:Destroy() end
	end
end)

Humanoid.Died:connect(function()
	SmokeTrail:StopEmission()
	if Module.ChargedShotAdvanceEnabled then
		Charging = false
	end
	Equipped = false
	HoldDown = false
	ActuallyEquipped = false
	GUI.Parent = script
	GUI.Frame.Visible = false
	if Module.WalkSpeedRedutionEnabled then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed + Module.WalkSpeedRedution
	else
		Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	UserInputService.MouseIconEnabled = true
	for _,c in pairs(Connections) do
		c:disconnect()
	end
	Connections = {}
	if Beam then
		Beam:Destroy()
		Beam = nil
	end
	if Attach0 then
		Attach0:Destroy()
		Attach0 = nil
	end
	if Attach1 then
		Attach1:Destroy()
		Attach1 = nil
	end
	if InspectAnim and InspectAnim.IsPlaying then InspectAnim:Stop() end
	if AimIdleAnim and AimIdleAnim.IsPlaying then AimIdleAnim:Stop() end
	if IdleAnim and IdleAnim.IsPlaying then IdleAnim:Stop() end
	if PreShotgunReloadAnim and PreShotgunReloadAnim.IsPlaying then PreShotgunReloadAnim:Stop() end
	if Handle.PreReloadSound.IsPlaying then Handle.PreReloadSound:Stop() end
	if ShotgunClipinAnim and ShotgunClipinAnim.IsPlaying then ShotgunClipinAnim:Stop() end
	if Handle.ShotgunClipin.IsPlaying then Handle.ShotgunClipin:Stop() end
	if TacticalReloadAnim and TacticalReloadAnim.IsPlaying then TacticalReloadAnim:Stop() end 
	if Handle.TacticalReloadSound.IsPlaying then Handle.TacticalReloadSound:Stop() end
	if ReloadAnim and ReloadAnim.IsPlaying then ReloadAnim:Stop() end
	if Handle.ReloadSound.IsPlaying then Handle.ReloadSound:Stop() end
	if CurrentAimFireAnim and CurrentAimFireAnim.IsPlaying then CurrentAimFireAnim:Stop() end
	if CurrentFireAnim and CurrentFireAnim.IsPlaying then CurrentFireAnim:Stop() end
	if CurrentShotgunPumpinAnim and CurrentShotgunPumpinAnim.IsPlaying then CurrentShotgunPumpinAnim:Stop() end
	if HandleToFire.ChargeSound.IsPlaying then HandleToFire.ChargeSound:Stop() end
	if HandleToFire.WindUp.IsPlaying then HandleToFire.WindUp:Stop() end
	if HandleToFire.WindDown.IsPlaying then HandleToFire.WindDown:Stop() end
	if HandleToFire.PumpSound.IsPlaying then HandleToFire.PumpSound:Stop() end
	if HoldDownAnim and HoldDownAnim.IsPlaying then HoldDownAnim:Stop() end
	if MinigunRevDownAnim and MinigunRevDownAnim.IsPlaying then MinigunRevDownAnim:Stop() end
	if MinigunRevUpAnim and MinigunRevUpAnim.IsPlaying then MinigunRevUpAnim:Stop() end
	if AimDown then
		TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
		setcrossscale(1)
		--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
		if GUI then GUI:Destroy() end]]
		Scoping = false
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseDeltaSensitivity = InitialSensitivity
		AimDown = false
	end
	if Module.DualEnabled and not workspace.FilteringEnabled then
		Handle2.CanCollide = true
		if Grip2 then Grip2:Destroy() end
	end
end)