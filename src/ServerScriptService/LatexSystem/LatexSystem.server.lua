--[[
LatexSystem
08/27/2022
FoxxoTrystan

Remake of "MasterOfAnimating"
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Teams = game:GetService("Teams")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local Backpack = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Backpack")
local InfectedCheckModule = require(ReplicatedStorage:WaitForChild("InfectedCheckModule"))
local LatexPuddles = game.Workspace:WaitForChild("LatexPuddles")
local Infected = script.Parent:WaitForChild("Infected")
local InfectionLimbs = script.Parent:WaitForChild("InfectionLimbs")

--// PreLoad Animations
local Animator = script.Parent.Dummy.Humanoid.Animator
for _,Animation in pairs(script.Parent:GetDescendants()) do
	if Animation:IsA("Animation") then
		Animator:LoadAnimation(Animation)
	end
end
Animator = nil

local PuddleTouch = {}
local PuddleDebounce = {}

local ImmunityTeam = { --// Level-C : 200 | Level-B : 500 | Level-A : 1000
	["Recontainment Unit"] = 500,
	["Hazmat Unit"] = 500,
	["SDO"] = 500,
	["Juggernaut"] = 1000,
	["UNSDF Centurions"] = 1000,
	["SO Reaper 1-4"] = 200,
	["UNSSG"] = 200
}

local function PlayInfectSound(Pitch, Character)
	local Sound = script.Transform:Clone()
	Sound.Parent = Character.Torso
	Sound.PlaybackSpeed = Pitch + (Random.new():NextNumber(-100,100)/1000)
	Sound:Play()
	Debris:AddItem(Sound, 2)
	Sound = nil
end

local function PlayScreamSound(Pitch, Cutoff, CutoffTime, Ver, Character)
	local SSound
	if Ver == 1 then
		SSound = script.Scream1:Clone()
	elseif Ver == 2 then
		SSound = script.Scream2:Clone()
	end
	SSound.Parent = Character.Head
	SSound.PlaybackSpeed = Pitch + (math.random(-100,100)/10000)
	SSound:Play()
	if Cutoff == true then
		local FadeOutInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
		local SoundFadeOut = {Volume = 0}
		local Fade = TweenService:Create(SSound, FadeOutInfo, SoundFadeOut)
		task.wait(CutoffTime)
		Fade:Play()
		FadeOutInfo = nil
		SoundFadeOut = nil
		Fade = nil
	end
	Debris:AddItem(SSound,SSound.TimeLength)
	SSound = nil
end

--// TransfurPlayer Function
_G.TransfurPlayer = function(Player: Player, InfectionType: string, PlayerInflicted: boolean)
	local Character = Player.Character
	if not (Character) then return end
	if Character:WaitForChild("Humanoid").Health <= 0 then return end
	local Corruption = false
	local LatexValues = Character:WaitForChild("LatexValues")
	if InfectionType == nil then
		InfectionType = "WhiteLatex"
	end
	if Infected[InfectionType] then
		InfectionType = Infected[InfectionType]
	else
		InfectionType = Infected["WhiteLatex"]
	end
	
	if InfectedCheckModule(Player) and InfectionType.Name == "LightLatex" then
		Corruption = true
	end
	
	local DeathAnim
	if PlayerInflicted then
		DeathAnim = Character.Humanoid:LoadAnimation(script.Anims.PlayerInfect)
	else
		DeathAnim = Character.Humanoid:LoadAnimation(script.Anims.Generic)
	end
	
	local HeadMesh = Character:WaitForChild("InfectionHead").Head
	local LeftArmMesh = Character:WaitForChild("InfectionLeft Arm").LeftArm
	local RightArmMesh = Character:WaitForChild("InfectionRight Arm").RightArm
	local TorsoMesh = Character:WaitForChild("InfectionTorso").Torso
	local LeftLegMesh = Character:WaitForChild("InfectionLeft Leg").LeftLeg
	local RightLegMesh = Character:WaitForChild("InfectionRight Leg").RightLeg
	
	local FurryColor = InfectionType:GetAttribute("Color")
	HeadMesh.Color = FurryColor
	LeftArmMesh.Color = FurryColor
	RightArmMesh.Color = FurryColor
	TorsoMesh.Color = FurryColor
	LeftLegMesh.Color = FurryColor
	RightLegMesh.Color = FurryColor
	
	local Face = Character.Head:FindFirstChild("face")
	
	local InfectedVignette = Player.PlayerGui.LatexUI.InfectedVignette
	if (InfectedVignette) then
		InfectedVignette.BackgroundColor3 = FurryColor
		InfectedVignette.ImageColor3 = FurryColor
	end
	LatexValues.Infected.Value = true
	LatexValues.IsCIP.Value = false
	LatexValues.InfectionLevel.Value = LatexValues.MaxInfectionValue.Value
	LatexValues.LatexColor.Value = FurryColor
	LatexValues.LatexType.Value = InfectionType.Name
	
	Backpack:FireClient(Player, false)
	Character.Humanoid:UnequipTools()
	
	task.wait()
	
	Player.Backpack:ClearAllChildren()
	
	Player.Team = Teams.Latex
	
	if (DeathAnim) then
		DeathAnim.KeyframeReached:connect(function(Keyframe)
			if Keyframe == "LeftArm" then
				TweenService:Create(LeftArmMesh.Mesh,  TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Scale = Vector3.new(1.05,1.05,1.05), Offset = Vector3.new(0,0,0)}):Play()
				LeftArmMesh.Transparency = 0
				PlayInfectSound(1, Character)
			elseif Keyframe == "RightArm" then
				TweenService:Create(RightArmMesh.Mesh,  TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Scale = Vector3.new(1.05,1.05,1.05), Offset = Vector3.new(0,0,0)}):Play()
				RightArmMesh.Transparency = 0
				PlayInfectSound(1, Character)
			elseif Keyframe == "Legs" then
				TweenService:Create(LeftLegMesh.Mesh,  TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Scale = Vector3.new(1.05,1.05,1.05), Offset = Vector3.new(0,0,0)}):Play()
				TweenService:Create(RightLegMesh.Mesh,  TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Scale = Vector3.new(1.05,1.05,1.05), Offset = Vector3.new(0,0,0)}):Play()
				LeftLegMesh.Transparency = 0
				RightLegMesh.Transparency = 0
				PlayInfectSound(1, Character)
			elseif Keyframe == "Torso" then
				TweenService:Create(TorsoMesh.Mesh,  TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Scale = Vector3.new(1.05,1.05,1.05), Offset = Vector3.new(0,0,0)}):Play()
				TorsoMesh.Transparency = 0
				PlayInfectSound(0.8, Character)
			elseif Keyframe == "Head" then
				TweenService:Create(HeadMesh.Mesh,  TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Scale = Vector3.new(1.4, 1.4, 1.4), Offset = Vector3.new(0,0,0)}):Play()
				HeadMesh.Transparency = 0
				if (InfectedVignette) then
					TweenService:Create(InfectedVignette, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0), {BackgroundTransparency = 0, ImageTransparency = 0}):Play()
				end
				PlayInfectSound(1, Character)
			elseif Keyframe == "Accessories" then
				if Corruption then
					for _,Hat in pairs(Character:GetChildren()) do
						if Hat:IsA("Accessory") then
							local Mesh = Hat.Handle:FindFirstChildOfClass("SpecialMesh")
							if (Mesh) then
								Mesh.VertexColor = Vector3.new(FurryColor.R, FurryColor.G, FurryColor.B)
								Mesh.TextureId = "rbxassetid://5614579544"
							end
							Mesh = nil
						end
					end
				else
					local SafeAccessories = {}
					for i,v in pairs(InfectionType:GetChildren()) do
						if v:IsA("Accessory") then
							local Temp = v:Clone()
							if Temp:GetAttribute("FadeIn") then
								for _,Part in pairs(Temp.Handle:GetChildren()) do
									if Part:IsA("BasePart") then
										Part.Transparency = 1
									end
								end
								Temp.Parent = Character
								for _,Part in pairs(Temp.Handle:GetChildren()) do
									if Part:IsA("BasePart") then
										TweenService:Create(Part, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {Transparency = 0}):Play()
									end
								end
							else
								local AccessoryMesh = Temp.Handle:FindFirstChildOfClass("SpecialMesh")
								Temp.Parent = Character
								if InfectionType.Name ~= "SquidDog" and Temp.Name ~= "Arms" then
									Temp.Handle.Transparency = 0
								end
								TweenService:Create(AccessoryMesh, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {Offset = Temp:GetAttribute("AccessoryOffset"), Scale = Temp:GetAttribute("AccessoryScale")}):Play()
								AccessoryMesh = nil
							end
							SafeAccessories[Temp] = true
							Temp = nil
						end
					end
					for _,Hat in pairs(Character:GetChildren()) do
						if Hat:IsA("Accessory") then
							if not SafeAccessories[Hat] then
								local isHair = Hat.AccessoryType == Enum.AccessoryType.Hair or Hat.Handle:FindFirstChild("HairAttachment") ~= nil
								local isHat = Hat.AccessoryType == Enum.AccessoryType.Hat or Hat.Handle:FindFirstChild("HatAttachment") ~= nil
								if not isHat and not isHair then
									Hat:Destroy()
								end
								if isHat or isHair then
									local Mesh = Hat.Handle:FindFirstChildOfClass("SpecialMesh")
									if (Mesh) then
										Mesh.VertexColor = Vector3.new(FurryColor.R, FurryColor.G, FurryColor.B)
										Mesh.TextureId = "rbxassetid://5614579544"
									else
										Hat:Destroy()
									end
									Mesh = nil
								end
								isHair = nil
								isHat = nil
							end
						end
					end
				end
				task.wait()
				PlayInfectSound(1, Character)
			elseif Keyframe == "ConfusedFace" then
				if (Face) then
					Face.Texture = "http://www.roblox.com/asset/?id=6553092869"
				end
			elseif Keyframe == "Realization" then
				if (Face) then
					Face.Texture = "http://www.roblox.com/asset/?id=6557910673"
				end
			elseif Keyframe == "Scream" then
				if (Face) then
					Face.Texture = "http://www.roblox.com/asset/?id=6375863850"
				end
			elseif Keyframe == "ScreamSound1" then
				PlayScreamSound(1.15, false, 0, 1, Character)
			elseif Keyframe == "ScreamSound2" then
				PlayScreamSound(1.15, false, 0, 2, Character)
			elseif Keyframe == "Hurt" then
				if (Face) then
					Face.Texture = "http://www.roblox.com/asset/?id=6557885985"
				end
			elseif Keyframe == "Shocked" then
				if (Face) then
					Face.Texture = "http://www.roblox.com/asset/?id=7802853058"
				end
			end
		end)
	end
	
	Character.Humanoid.MaxHealth = math.huge
	Character.Humanoid.Health = math.huge
	if (InfectedVignette) then
		InfectedVignette.BackgroundColor3 = FurryColor
		InfectedVignette.ImageColor3 = FurryColor
	end
	local WalkspeedNumber = Instance.new("NumberValue")
	WalkspeedNumber.Parent = Character.Humanoid
	WalkspeedNumber.Name = "LatexSpeed"
	WalkspeedNumber.Value = -10
	task.wait()
	DeathAnim:Play()
	if (InfectedVignette) then
		InfectedVignette.Parent.ClientSide.YouScrewedUpSound:Play()
	end
	task.wait(DeathAnim.Length)
	if (InfectedVignette) then
		TweenService:Create(InfectedVignette.Parent.ClientSide.HighInfectionAmbience, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {PlaybackSpeed = 0}):Play()
	end
	InfectionType["Body Colors"]:Clone().Parent = Character
	if (Face) then
		Face.Face = "Bottom"
		Face.Transparency = 1
	end
	for i,v in pairs(Character:GetChildren()) do
		if v:IsA("BodyColors") or v:IsA("Clothing") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
	if not Corruption then
		for i,v in pairs(InfectionType:GetChildren()) do
			if v:IsA("Clothing") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
				v:Clone().Parent = Character
			end
		end
	end
	if InfectionType:GetAttribute("NoWeapon") then
		LatexValues.NoWeapon.Value = true
	else
		LatexValues.NoWeapon.Value = false
	end
	if InfectionType.Name ~= "LightLatex" then
		ServerStorage.Tools.Fists:Clone().Parent = Player.Backpack
		ServerStorage.Tools.Hug:Clone().Parent = Player.Backpack
	end
	ServerStorage.Tools.Infect:Clone().Parent = Player.Backpack
	if InfectionType.Name == "HypnoCat" then
		--ServerStorage.Tools.Hypno:Clone().Parent = Player.Backpack
	elseif InfectionType.Name == "SpiderWolf" then
		--ServerStorage.Tools["Web Trap"]:Clone().Parent = Player.Backpack
	end
	Backpack:FireClient(Player, true)
	if (InfectedVignette) then
		TweenService:Create(InfectedVignette, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {BackgroundTransparency = 1, ImageTransparency = 0.5}):Play()
	end
	local LimbFadeOutInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local LimbFadeOut = {Transparency = 1}
	TweenService:Create(TorsoMesh, LimbFadeOutInfo, LimbFadeOut):Play()
	TweenService:Create(LeftArmMesh, LimbFadeOutInfo, LimbFadeOut):Play()
	TweenService:Create(RightArmMesh, LimbFadeOutInfo, LimbFadeOut):Play()
	TweenService:Create(LeftLegMesh, LimbFadeOutInfo, LimbFadeOut):Play()
	TweenService:Create(RightLegMesh, LimbFadeOutInfo, LimbFadeOut):Play()
	Character.Head.Transparency = 1
	TweenService:Create(HeadMesh.face, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Transparency = 0}):Play()
	TweenService:Create(HeadMesh.Mesh, LimbFadeOutInfo, {Scale = Vector3.new(1.35, 1.35, 1.35)}):Play()
	LimbFadeOutInfo = nil
	LimbFadeOut = nil
	HeadMesh.face.Texture = InfectionType.face.Texture
	WalkspeedNumber.Value = InfectionType:GetAttribute("Speed")
	Player.Injuries:ClearAllChildren()
	Character.Humanoid.MaxHealth = InfectionType:GetAttribute("Health")
	Character.Humanoid.Health = InfectionType:GetAttribute("Health")
	
	InfectedVignette, InfectionType, Face, WalkspeedNumber, Character, FurryColor, HeadMesh, LeftArmMesh, RightArmMesh, LeftLegMesh, RightLegMesh, TorsoMesh, DeathAnim, LatexValues = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
end

--// InfectPlayer Function
_G.InfectPlayer = function(Player: Player, InfectAmount: number, InfectionType: string, PlayerInflicted: boolean, Color: Color3)
	if (Player) and (InfectAmount) and (InfectionType) then
		local Character = Player.Character
		if (Character) then
			if Character:WaitForChild("Humanoid").Health <= 0 then return end
			local LatexValues = Character:WaitForChild("LatexValues")
			if InfectedCheckModule(Player) then
				if InfectionType == "LightLatex" and LatexValues.LatexType.Value ~= "LightLatex" then
					_G.TransfurPlayer(Player, InfectionType, PlayerInflicted)
				end
				return
			end
			if LatexValues.FullImmunity.Value then return end
			if (Color) then
				LatexValues.LatexColor.Value = Color
			end
			LatexValues.LastHit.Value = InfectionType
			if LatexValues.InfectionLevel.Value < LatexValues.MaxInfectionValue.Value then
				if (LatexValues.InfectionLevel.Value + InfectAmount) >= LatexValues.MaxInfectionValue.Value then
					LatexValues.InfectionLevel.Value = LatexValues.MaxInfectionValue.Value
					_G.TransfurPlayer(Player, InfectionType, PlayerInflicted)
				else
					LatexValues.InfectionLevel.Value += InfectAmount
					local Humanoid = Character:WaitForChild("Humanoid")
					local Select = math.random(1, 2)
					local HurtAnim = Humanoid:LoadAnimation(script.Anims.HurtAnimations["Hurt"..Select])
					Select = nil
					if (HurtAnim) then
						HurtAnim:Play()
					end
					HurtAnim = nil
					local InfectSound = script.Transform:Clone()
					InfectSound.Parent = Character.Torso
					InfectSound:Play()
					task.delay(1.5, function()
						InfectSound:Destroy()
					end)
					Humanoid = nil
				end
			end
			LatexValues = nil
		end
		Character = nil
	end
end

Players.PlayerAdded:Connect(function(Player: Player)
	local LastTeam = nil
	Player.CharacterAdded:Connect(function(Character)
		PuddleTouch[Player.Name] = nil
		PuddleDebounce[Player.Name] = nil
		script.LatexValues:Clone().Parent = Character
		for i,v in pairs(InfectionLimbs:GetChildren()) do
			coroutine.wrap(function(v)
				local Temp = v:Clone()
				Temp.Name = "Infection"..v.Name
				Temp.Parent = Character
				local Weld = Instance.new("Weld")
				Weld.Part0 = Character[v.Name]
				Weld.Part1 = Temp.Middle
				Weld.C0 = CFrame.new(0, 0, 0)
				Weld.Parent = Weld.Part0
				Temp = nil
				Weld = nil
			end)(v)
		end
		
		if Player.Team == Teams["Latex"] then
			Player.Team = LastTeam
		end
		LastTeam = Player.Team
		
		if Player.Team == Teams["Contained Infected Subject"] then
			Character:WaitForChild("LatexValues").LatexType.Value = "DarkLatex"
		end
		
		Character.Humanoid.Died:Connect(function()
			local isInfected, IsCIP = InfectedCheckModule(Player)
			if isInfected and Player:FindFirstChild("SafeZone") == nil then
				if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end

				local Puddle = script.Puddle:Clone()
				if IsCIP then
					Puddle.Size = Vector3.new(0.05, 3, 3)
				else
					Puddle:SetAttribute("Infectious", true)
					local LatexValues = Character:FindFirstChild("LatexValues")
					if (LatexValues) then
						Puddle:SetAttribute("LatexType", LatexValues.LatexType.Value)
					else
						Puddle:SetAttribute("LatexType", "WhiteLatex")
					end
				end
				Puddle.Parent = workspace.Messes.ActiveMesses
				Puddle.Color = Character.Torso.Color
				CollectionService:AddTag(Puddle, "Puddle")
				local Position = Character.HumanoidRootPart.Position
				Puddle.Position = Position
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {Character}
				raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
				local ray = workspace:Raycast(Position, Vector3.new(0, -1000, 0), raycastParams)
				if not ray then
					Puddle.Position = Vector3.new(Position.X, Position.Y, Position.Z)
				else
					Puddle.Position = Vector3.new(ray.Position.X, ray.Position.Y, ray.Position.Z)
				end
				raycastParams = nil
				ray = nil
				Position = Puddle.Position
				local Eff1 = script.bom:Clone()
				local Eff2 = script.bom2:Clone()
				Eff1.Parent = Character.HumanoidRootPart
				Eff2.Parent = Character.HumanoidRootPart
				Eff1.Color = ColorSequence.new(Puddle.Color)
				Eff2.Color = ColorSequence.new(Puddle.Color)
				Eff1:Emit(20)
				Eff2:Emit(20)
				for i = 1, Random.new():NextInteger(1,10) do
					local Dots = script.Dots:Clone()
					Dots.Parent = Character
					Dots.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
					Dots.Color = Puddle.Color
					Dots.Trail.Color = ColorSequence.new(Puddle.Color)
					Dots.Velocity = Vector3.new(Random.new():NextInteger(-30,30), Random.new():NextInteger(50,60), Random.new():NextInteger(-30,30)) 
					Debris:AddItem(Dots, 1)
					Dots = nil
				end
				Eff1 = nil
				Eff2 = nil
				Puddle = nil
				Position = nil
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(Player: Player)
	PuddleTouch[Player.Name] = nil
	PuddleDebounce[Player.Name] = nil
end)

--// Death Puddles
local PuddleTouchConnection = {}
local PuddletouchEndedConnection = {}
local function PuddleTouched(Puddle: Part, Hit: Part)
	local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
	if (Humanoid) then
		local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
		if (Player) then
			if not PuddleTouch[Player.Name] then
				PuddleTouch[Player.Name] = true
				while task.wait(0.1) do
					if not PuddleTouch[Player.Name] then
						break
					end
					if not PuddleDebounce[Player.Name] then
						_G.InfectPlayer(Player, 25, Puddle:GetAttribute("LatexType", nil), false, Puddle.Color)
						PuddleDebounce[Player.Name] = true
						task.delay(1, function()
							PuddleDebounce[Player.Name] = nil
						end)
					end
				end
			end
		end
	end
	Humanoid = nil
end

local function PuddletouchEnded(Puddle: Part, Hit: Part)
	local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
	if (Humanoid) then
		local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
		if (Player) then
			if PuddleTouch[Player.Name] then
				PuddleTouch[Player.Name] = nil
			end
		end
		Player = nil
	end
	Humanoid = nil
end

CollectionService:GetInstanceAddedSignal("Puddle"):Connect(function(Puddle: Part)
	if Puddle:GetAttribute("Infectious") then
		PuddleTouchConnection[Puddle] = Puddle.Touched:Connect(function(Hit: Part)
			PuddleTouched(Puddle, Hit)
		end)
		PuddletouchEndedConnection[Puddle] = Puddle.TouchEnded:Connect(function(Hit: Part)
			PuddletouchEnded(Puddle, Hit)
		end)
	end
end)

CollectionService:GetInstanceRemovedSignal("Puddle"):Connect(function(Puddle: Part)
	if PuddleTouchConnection[Puddle] then PuddleTouchConnection[Puddle]:Disconnect() end
	if PuddletouchEndedConnection[Puddle] then PuddletouchEndedConnection[Puddle]:Disconnect() end
end)

--// Puddle System
for _,Puddle: Folder in pairs(LatexPuddles:GetChildren()) do
	for _,Part: Instance in pairs(Puddle:GetDescendants()) do
		if Part:IsA("BasePart") and not Part:GetAttribute("PuddleIngore") then
			local Puddlecolor = Part.Color
			Part.Touched:Connect(function(Hit)
				local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
				if (Humanoid) then
					local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
					if (Player) then
						if not PuddleTouch[Player.Name] then
							PuddleTouch[Player.Name] = true
							while task.wait(0.1) do
								if not PuddleTouch[Player.Name] then
									break
								end
								if not PuddleDebounce[Player.Name] then
									_G.InfectPlayer(Player, 25, Puddle:GetAttribute("LatexType", nil), false, Part.Color)
									PuddleDebounce[Player.Name] = true
									task.delay(1, function()
										PuddleDebounce[Player.Name] = nil
									end)
								end
							end
						end
					end
				end
				Humanoid = nil
			end)
			
			Part.TouchEnded:Connect(function(Hit)
				local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
				if (Humanoid) then
					local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
					if (Player) then
						if PuddleTouch[Player.Name] then
							PuddleTouch[Player.Name] = nil
						end
					end
					Player = nil
				end
				Humanoid = nil
			end)
		end
	end
end


while task.wait(30) do
	for _,Player in pairs(Players:GetChildren()) do
		coroutine.wrap(function()
			if not InfectedCheckModule(Player) then
				local Character = Player.Character
				if (Character) then
					local LatexValues = Character:WaitForChild("LatexValues")
					if LatexValues.InfectionLevel.Value > 0 then
						_G.InfectPlayer(Player, math.random(1, 5), LatexValues.LastHit.Value, false)
					end
					LatexValues = nil
				end
				Character = nil
			end	
		end)()
	end
end