local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local NVG = Lighting.NightVision

local LastExposureCompensation = Lighting.ExposureCompensation

local NVGActionName = "NVG"

local AnimationTrack = nil

local UI = nil

local MaxBatteryLife = 60*10
local BatteryLife = MaxBatteryLife
local RechargeRate = 5

function haveNVG()
	return Player.Backpack:FindFirstChild("Night Vision Goggles") ~= nil or Player.Character:FindFirstChild("Night Vision Goggles") ~= nil
end

function toggleMorphLights(state : boolean)
	local Character = Player.Character
	if not Character then return end
	for i,accessory in pairs(Character:GetChildren()) do
		if accessory:IsA("Accessory") then
			for i,light in pairs(accessory:GetDescendants()) do
				if light:IsA("PointLight") or light:IsA("SurfaceLight") or light:IsA("SpotLight") then
					light.Enabled = state
				end
			end
		end
	end
end

function NVGOn()
	SoundService.SoundStorage.Misc.NVG:Play()

	LastExposureCompensation = Lighting.ExposureCompensation
	Lighting.ExposureCompensation = 5

	NVG.Enabled = true
	UI.Enabled = true
	
	toggleMorphLights(false)
end

function NVGOff(noSound: boolean?)
	if not noSound then SoundService.SoundStorage.Misc.Click1:Play() end

	Lighting.ExposureCompensation = LastExposureCompensation

	NVG.Enabled = false

	if UI ~= nil then
		UI.Enabled = false
	end
	
	toggleMorphLights(true)
end

function toggleNVG()
	AnimationTrack:Play()

	if NVG.Enabled == true then
		NVGOff()
	else
		NVGOn()
	end
end

function onAction(actionName, UserInputState, InputObject: InputObject)
	if actionName ~= NVGActionName or UserInputState ~= Enum.UserInputState.Begin or (InputObject.UserInputType == Enum.UserInputType.Keyboard and InputObject.KeyCode ~= Enum.KeyCode.N) or not haveNVG() then return end
	toggleNVG()
end

function updateBatteryUI()
	local BatteryLifeScale = BatteryLife/MaxBatteryLife
	UI.Battery.Bar.Fill.Size = UDim2.new(BatteryLifeScale, 0, 1, 0)

	if BatteryLifeScale < 0.1 then
		UI.Battery.Bar.Fill.BackgroundColor3 = Color3.new(1, 0, 0)
		UI.Battery.TimeRemaining.BackgroundColor3 = Color3.new(1, 0, 0)
	else
		UI.Battery.Bar.Fill.BackgroundColor3 = Color3.new(0, 1, 0)
		UI.Battery.TimeRemaining.BackgroundColor3 = Color3.new(0, 1, 0)
	end

	if BatteryLife > 60 then
		local Minutes = math.round(BatteryLife/60)
		UI.Battery.TimeRemaining.Text = "EST TIME REMAINING: "..Minutes.." MIN"
	else
		UI.Battery.TimeRemaining.Text = "EST TIME REMAINING: <1 MIN"
	end
end

local binded
function updateNVG()
	if haveNVG() then
		if not binded then
			ContextActionService:BindAction(NVGActionName, onAction, true, Enum.KeyCode.N)
			ContextActionService:SetTitle(NVGActionName, "NVG")
			ContextActionService:SetPosition(NVGActionName, UDim2.new(1, -70, 0, 10))
			binded = true

			local Humanoid = Player.Character:WaitForChild("Humanoid")
			
			AnimationTrack = Humanoid.Animator:LoadAnimation(script.ToggleAnimation)

			UI = script.NightVisionUI:Clone()
			UI.Parent = Player.PlayerGui

			while binded do
				updateBatteryUI()

				local TimePassed = task.wait(1)

				local BatteryChange = 0
				if NVG.Enabled == true then
					BatteryChange = -TimePassed
				else
					BatteryChange = TimePassed * RechargeRate
				end

				BatteryLife = math.clamp(BatteryLife + BatteryChange, 0, MaxBatteryLife)

				if BatteryLife == 0 then
					NVGOff()
					SoundService.SoundStorage.Misc.NVGLowBattery:Play()
				end
			end
		end
	else
		if binded then
			ContextActionService:UnbindAction(NVGActionName)
			binded = nil
		end

		NVGOff()
	end
end

function handleChild(child: Instance)
	if child.Name ~= "Night Vision Goggles" then return end
	updateNVG()
end

function CharacterAdded(character: Model)
	BatteryLife = MaxBatteryLife

	NVGOff(true)

	character.ChildAdded:Connect(handleChild)
	character.ChildRemoved:Connect(handleChild)

	local Backpack = Player:WaitForChild("Backpack") :: Backpack
	Backpack.ChildAdded:Connect(handleChild)
	Backpack.ChildRemoved:Connect(handleChild)

	updateNVG()
end

Player.CharacterAdded:Connect(CharacterAdded)

if Player.Character then
	CharacterAdded(Player.Character)
end

script:WaitForChild("ToggleNVG").Event:Connect(toggleNVG)