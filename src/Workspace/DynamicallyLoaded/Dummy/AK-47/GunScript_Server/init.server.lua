local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
--local Player
--local Character
--local Humanoid
local Module = require(Tool:WaitForChild("Setting"))
local ChangeMagAndAmmo = script:WaitForChild("ChangeMagAndAmmo")
local Grip2
local Handle2

if Module.DualEnabled then
	Handle2 = Tool:WaitForChild("Handle2",1)
	if Handle2 == nil and Module.DualEnabled then error("\"Dual\" setting is enabled but \"Handle2\" is missing!") end
end

local MagValue = script:FindFirstChild("Mag") or Instance.new("NumberValue",script)
MagValue.Name = "Mag"
MagValue.Value = Module.AmmoPerMag
local AmmoValue = script:FindFirstChild("Ammo") or Instance.new("NumberValue",script)
AmmoValue.Name = "Ammo"
AmmoValue.Value = Module.LimitedAmmoEnabled and Module.Ammo or 0

if Module.IdleAnimationID ~= nil or Module.DualEnabled then
	local IdleAnim = Instance.new("Animation",Tool)
	IdleAnim.Name = "IdleAnim"
	IdleAnim.AnimationId = "rbxassetid://"..(Module.DualEnabled and 53610688 or Module.IdleAnimationID)
end
if Module.FireAnimationID ~= nil then
	local FireAnim = Instance.new("Animation",Tool)
	FireAnim.Name = "FireAnim"
	FireAnim.AnimationId = "rbxassetid://"..Module.FireAnimationID
end
if Module.ReloadAnimationID ~= nil then
	local ReloadAnim = Instance.new("Animation",Tool)
	ReloadAnim.Name = "ReloadAnim"
	ReloadAnim.AnimationId = "rbxassetid://"..Module.ReloadAnimationID
end
if Module.ShotgunClipinAnimationID ~= nil then
	local ShotgunClipinAnim = Instance.new("Animation",Tool)
	ShotgunClipinAnim.Name = "ShotgunClipinAnim"
	ShotgunClipinAnim.AnimationId = "rbxassetid://"..Module.ShotgunClipinAnimationID
end
if Module.ShotgunPumpinAnimationID ~= nil then
	local ShotgunPumpinAnim = Instance.new("Animation",Tool)
	ShotgunPumpinAnim.Name = "ShotgunPumpinAnim"
	ShotgunPumpinAnim.AnimationId = "rbxassetid://"..Module.ShotgunPumpinAnimationID
end
if Module.HoldDownAnimationID ~= nil then
	local HoldDownAnim = Instance.new("Animation",Tool)
	HoldDownAnim.Name = "HoldDownAnim"
	HoldDownAnim.AnimationId = "rbxassetid://"..Module.HoldDownAnimationID
end
if Module.EquippedAnimationID ~= nil then
	local EquippedAnim = Instance.new("Animation",Tool)
	EquippedAnim.Name = "EquippedAnim"
	EquippedAnim.AnimationId = "rbxassetid://"..Module.EquippedAnimationID
end
if Module.SecondaryFireAnimationEnabled and Module.SecondaryFireAnimationID ~= nil then
	local SecondaryFireAnim = Instance.new("Animation",Tool)
	SecondaryFireAnim.Name = "SecondaryFireAnim"
	SecondaryFireAnim.AnimationId = "rbxassetid://"..Module.SecondaryFireAnimationID
end
if Module.SecondaryShotgunPump and Module.SecondaryShotgunPumpinAnimationID ~= nil then
	local SecondaryShotgunPumpinAnim = Instance.new("Animation",Tool)
	SecondaryShotgunPumpinAnim.Name = "SecondaryShotgunPumpinAnim"
	SecondaryShotgunPumpinAnim.AnimationId = "rbxassetid://"..Module.SecondaryShotgunPumpinAnimationID
end
if Module.AimAnimationsEnabled and Module.AimIdleAnimationID ~= nil then
	local AimIdleAnim = Instance.new("Animation",Tool)
	AimIdleAnim.Name = "AimIdleAnim"
	AimIdleAnim.AnimationId = "rbxassetid://"..Module.AimIdleAnimationID
end
if Module.AimAnimationsEnabled and Module.AimFireAnimationID ~= nil then
	local AimFireAnim = Instance.new("Animation",Tool)
	AimFireAnim.Name = "AimFireAnim"
	AimFireAnim.AnimationId = "rbxassetid://"..Module.AimFireAnimationID
end
if Module.AimAnimationsEnabled and Module.AimSecondaryFireAnimationID ~= nil then
	local AimSecondaryFireAnim = Instance.new("Animation",Tool)
	AimSecondaryFireAnim.Name = "AimSecondaryFireAnim"
	AimSecondaryFireAnim.AnimationId = "rbxassetid://"..Module.AimSecondaryFireAnimationID
end
if Module.AimAnimationsEnabled and Module.AimChargingAnimationID ~= nil then
	local AimChargingAnim = Instance.new("Animation",Tool)
	AimChargingAnim.Name = "AimChargingAnim"
	AimChargingAnim.AnimationId = "rbxassetid://"..Module.AimChargingAnimationID
end
if Module.TacticalReloadAnimationEnabled and Module.TacticalReloadAnimationID ~= nil then
	local TacticalReloadAnim = Instance.new("Animation",Tool)
	TacticalReloadAnim.Name = "TacticalReloadAnim"
	TacticalReloadAnim.AnimationId = "rbxassetid://"..Module.TacticalReloadAnimationID
end
if Module.InspectAnimationEnabled and Module.InspectAnimationID ~= nil then
	local InspectAnim = Instance.new("Animation",Tool)
	InspectAnim.Name = "InspectAnim"
	InspectAnim.AnimationId = "rbxassetid://"..Module.InspectAnimationID
end
if Module.ShotgunReload and Module.PreShotgunReload and Module.PreShotgunReloadAnimationID ~= nil then
	local PreShotgunReloadAnim = Instance.new("Animation",Tool)
	PreShotgunReloadAnim.Name = "PreShotgunReloadAnim"
	PreShotgunReloadAnim.AnimationId = "rbxassetid://"..Module.PreShotgunReloadAnimationID
end
if Module.MinigunRevUpAnimationID ~= nil then
	local MinigunRevUpAnim = Instance.new("Animation",Tool)
	MinigunRevUpAnim.Name = "MinigunRevUpAnim"
	MinigunRevUpAnim.AnimationId = "rbxassetid://"..Module.MinigunRevUpAnimationID
end
if Module.MinigunRevDownAnimationID ~= nil then
	local MinigunRevDownAnim = Instance.new("Animation",Tool)
	MinigunRevDownAnim.Name = "MinigunRevDownAnim"
	MinigunRevDownAnim.AnimationId = "rbxassetid://"..Module.MinigunRevDownAnimationID
end
if Module.ChargingAnimationEnabled and Module.ChargingAnimationID ~= nil then
	local ChargingAnim = Instance.new("Animation",Tool)
	ChargingAnim.Name = "ChargingAnim"
	ChargingAnim.AnimationId = "rbxassetid://"..Module.ChargingAnimationID
end

ChangeMagAndAmmo.OnServerEvent:connect(function(Player,Mag,Ammo)
	MagValue.Value = Mag
	AmmoValue.Value = Ammo
end)

Tool.Equipped:connect(function()
	--Player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	--Character = Tool.Parent
	--Humanoid = Character:FindFirstChild("Humanoid")
	if Module.DualEnabled and workspace.FilteringEnabled then
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
end)

Tool.Unequipped:connect(function()
	if Module.DualEnabled and workspace.FilteringEnabled then
		Handle2.CanCollide = true
		if Grip2 then Grip2:Destroy() end
	end
end)