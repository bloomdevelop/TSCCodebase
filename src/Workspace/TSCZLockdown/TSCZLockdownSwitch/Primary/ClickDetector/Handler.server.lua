local TweenService = game:GetService("TweenService")

local ClickDetector = script.Parent

local TSCZLights = workspace.TSCZLights
local TSCZLightsTwo = workspace.LightsFolder.TSCZLights
local TSCZAlarmPart = workspace.TSCZAlarmPart

local LeverPart = ClickDetector.Parent
local PullSound = LeverPart:WaitForChild("PullSound")
local DisabledSound = LeverPart:WaitForChild("DisableSound")

local SwitchModel = LeverPart.Parent
local OnPosition = SwitchModel:WaitForChild("ONPos")
local OffPosition = SwitchModel:WaitForChild("OFFPos")

local ADoor = SwitchModel.Parent.ADoor
local APrim = ADoor.LDoor.PrimaryPart
local AOpen = ADoor.LDoorOpen
local AClosed = ADoor.LDoorClosed
local ADoorSound = ADoor.Button.OpenSound

local BDoor = SwitchModel.Parent.BDoor
local BPrim = BDoor.LDoor.PrimaryPart
local BOpen = BDoor.LDoorOpen
local BClosed = BDoor.LDoorClosed
local BDoorSound = BDoor.Button.OpenSound

local ControlsLocked = SwitchModel.Parent.ControlsLocked

local ACTween = TweenService:Create(APrim, TweenInfo.new(2.2, Enum.EasingStyle.Quad), {CFrame = AClosed.CFrame})
local BCTween = TweenService:Create(BPrim, TweenInfo.new(2.2, Enum.EasingStyle.Quad), {CFrame = BClosed.CFrame})
local AOTween = TweenService:Create(APrim, TweenInfo.new(2.2, Enum.EasingStyle.Quad), {CFrame = AOpen.CFrame})
local BOTween = TweenService:Create(BPrim, TweenInfo.new(2.2, Enum.EasingStyle.Quad), {CFrame = BOpen.CFrame})

local LOnTween = TweenService:Create(LeverPart, TweenInfo.new(0.8, Enum.EasingStyle.Bounce), {CFrame = OnPosition.CFrame})
local LOffTween = TweenService:Create(LeverPart, TweenInfo.new(0.8, Enum.EasingStyle.Bounce), {CFrame = OffPosition.CFrame})

function BlockALockdown()
	ADoorSound:Play()
	ACTween:Play()
end

function BlockBLockdown()
	BDoorSound:Play()
	BCTween:Play()
end

function BlockALift()
	ADoorSound:Play()
	AOTween:Play()
end

function BlockBLift()
	BDoorSound:Play()
	BOTween:Play()
end

local underlockdown = false
local cooldown

ClickDetector.MouseClick:Connect(function(playerWhoClicked)
	if cooldown or ControlsLocked.Value == true then return end
	if ClickDetector.MaxActivationDistance+1.1 > playerWhoClicked:DistanceFromCharacter(LeverPart.Position) then
		cooldown = true

		underlockdown = not underlockdown
		
		PullSound:Play()

		if underlockdown then
			if not ADoor:FindFirstChild("Lockdown") then
				local BoolValue = Instance.new("BoolValue")
				BoolValue.Name = "Lockdown"
				BoolValue.Value = true
				BoolValue.Parent = ADoor
			end

			if not BDoor:FindFirstChild("Lockdown") then
				local BoolValue = Instance.new("BoolValue")
				BoolValue.Name = "Lockdown"
				BoolValue.Value = true
				BoolValue.Parent = BDoor
			end

			LOnTween:Play()
			TSCZAlarmPart.LightsOut:Play()
			TSCZAlarmPart.Alarm:Play()
		else
			if ADoor:FindFirstChild("Lockdown") then
				ADoor.Lockdown:Destroy()
			end

			if BDoor:FindFirstChild("Lockdown") then
				BDoor.Lockdown:Destroy()
			end

			DisabledSound:Play()
			LOffTween:Play()
			TSCZAlarmPart.PowerOn:Play()
			TSCZAlarmPart.Alarm:Stop()
		end

		for _,v1 in next, {TSCZLights, TSCZLightsTwo} do
			for _,v2 in next, v1:GetDescendants() do
				if v2:IsA("SpotLight") then
					v2.Enabled = not underlockdown
				elseif v2:IsA("BasePart") and v2.Material == (underlockdown and Enum.Material.Neon or Enum.Material.Ice) then
					v2.Material = (underlockdown and Enum.Material.Ice or Enum.Material.Neon)
				end
			end
		end

		ADoor.Closed.Value = underlockdown
		BDoor.Closed.Value = underlockdown

		if underlockdown then
			BlockALockdown()
			BlockBLockdown()
		else
			BlockALift()
			BlockBLift()
		end

		task.wait(3)
		cooldown = nil
	else
		--local distance = playerWhoClicked:DistanceFromCharacter(LeverPart.Position)
		--warn(string.format("%s tried to click TSCZ LOCKDOWN SWITCH while being %s studs away.", playerWhoClicked.Name, distance))
	end
end)