local ClickDetector = script.Parent
local PullSound = script.Parent.Parent.PullSound
local tweenService = game:GetService("TweenService")
local ONPos = script.Parent.Parent.Parent.ONPos
local OFFPos = script.Parent.Parent.Parent.OFFPos
local Switch = script.Parent.Parent
local Alarm = workspace.CTZAlarmPart.Alarm
local Primary = script.Parent.Parent
local DisableSound = script.Parent.Parent.DisableSound
local CTZBuzzers = workspace.CTZBuzzers

local CTZ = workspace.LightsFolder.CTZ
local SFX = workspace.CTZAlarmPart
local HCZdoor = script.Parent.Parent.Parent.Parent.HCZDoor
local HCZPrimary = HCZdoor.LDoor.LeftPrimary
local HCZOpen = HCZdoor.LDoorOpen
local HCZClosed = HCZdoor.LDoorClosed
local HCZSound = HCZdoor.ExternalSoundPlayer.OpenSound
local HCZOpenTween = tweenService:Create(HCZPrimary,TweenInfo.new(7,Enum.EasingStyle.Quad),{CFrame = HCZOpen.CFrame})
local HCZCloseTween = tweenService:Create(HCZPrimary,TweenInfo.new(7,Enum.EasingStyle.Quad),{CFrame = HCZClosed.CFrame})


local HevDoor= script.Parent.Parent.Parent.Parent.HeavyDoor
local HevPrimary = HevDoor.LDoor.LeftPrimary
local HevOpen = HevDoor.LDoorOpen
local HevClosed = HevDoor.LDoorClosed
local HevOpenSound = HevDoor.ExternalSoundPlayer.OpenSound
local HevCloseSound = HevDoor.ExternalSoundPlayer.CloseSound
local HevCloseTween = tweenService:Create(HevPrimary,TweenInfo.new(0.7,Enum.EasingStyle.Quad),{CFrame = HevClosed.CFrame})
local HevOpenTween = tweenService:Create(HevPrimary,TweenInfo.new(0.7,Enum.EasingStyle.Quad),{CFrame = HevOpen.CFrame})

function BuzzersOn()
	for i,v in pairs(CTZBuzzers:GetDescendants()) do
		if v.Name ==("Light") then
			v.Alarm:Play()
			v.WarningLight.Enabled = true
			v.Material = ("Neon")
			v.BrickColor = BrickColor.new("Persimmon")
		end
	end
end

function BuzzersOff()
	for i,v in pairs(CTZBuzzers:GetDescendants()) do
		if v.Name ==("Light") then
			v.Alarm:Stop()
			v.WarningLight.Enabled = false
			v.Material = ("Plastic")
			v.BrickColor = BrickColor.new("Institutional white")
		end
	end
end


underLockdown = false

function onClicked(plr)
	if plr then
		if plr:DistanceFromCharacter(ClickDetector.Parent.Position) <= ClickDetector.MaxActivationDistance+1.1 then
			underLockdown = not underLockdown

			if underLockdown then
				PullSound:Play()
				tweenService:Create(Primary,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = ONPos.CFrame}):Play()
				Alarm:Play()
				
				local LockdownValue = Instance.new("BoolValue")
				LockdownValue.Name = "Lockdown"
				LockdownValue.Parent = HCZdoor
				
				LockdownValue:Clone().Parent = HevDoor
				
				if HevDoor.Closed.Value == false then
					HevCloseTween:Play()
					HevCloseSound:Play()
				end
				if HCZdoor.Closed.Value == false then
					HCZCloseTween:Play()
					HCZSound:Play()
				end

				SFX.Warning:Play()

				BuzzersOn()
				Alarm:Play()
				SFX.PowerDown:Play()
				
				for i,v in pairs(CTZ:GetDescendants()) do
					if v:IsA("SpotLight") then v.Enabled = false
					end
				end
				for i,v in pairs(CTZ:GetDescendants()) do
					if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
						v.Material = Enum.Material.Ice
					end
				end
				
				HevDoor.Closed.Value = true
				HCZdoor.Closed.Value = true

			else
				DisableSound:Play()
				tweenService:Create(Primary,TweenInfo.new(0.8,Enum.EasingStyle.Bounce),{CFrame = OFFPos.CFrame}):Play()
				
				if HCZdoor:FindFirstChild("Lockdown") then
					HCZdoor.Lockdown:Destroy()
				end
				if HevDoor:FindFirstChild("Lockdown") then
					HevDoor.Lockdown:Destroy()
				end
				
				BuzzersOff()
				Alarm:Stop()
				SFX.PowerUp:Play()
				
				for i,v in pairs(CTZ:GetDescendants()) do
					if v:IsA("SpotLight") then v.Enabled = true
					end
				end
				for i,v in pairs(CTZ:GetDescendants()) do
					if v:IsA("BasePart") and v.Material == Enum.Material.Ice then
						v.Material = Enum.Material.Neon
					end
				end
			end
		end



	elseif plr:DistanceFromCharacter(ClickDetector.Parent.Position) >= ClickDetector.MaxActivationDistance+5 then
		local distance = plr:DistanceFromCharacter(ClickDetector.Parent.Position)
		--print(plr.Name .. " tried to click CTZ LOCKDOWN SWITCH while being " .. distance .. " studs away.")
	end
end

ClickDetector.MouseClick:Connect(onClicked)