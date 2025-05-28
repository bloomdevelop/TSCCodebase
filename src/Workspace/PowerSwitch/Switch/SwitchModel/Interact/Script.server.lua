local Primary = script.Parent.Parent.Parent.Primary
local OnPos = script.Parent.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.Parent.OffPos
local TweenService = game:GetService("TweenService")
local PowerLight = workspace.PowerLight.LightSystem
local ON = false
local LightsOn = true
local MainGenerator = workspace.MainGenerator.System
local Lighting = game:GetService("Lighting")
local AmbientsDisabled = game.SoundService.SoundStorage.BackgroundAmbients
local Lighting = game:GetService("Lighting")
function onClicked()
	ON = not ON
	if ON == true then
		---------------------------------------------------------Shutting Down
		script.Parent.ClickDetector.MaxActivationDistance = 0
		Primary.PullSound:Play()
		MainGenerator.Online.Value = false
		TweenService:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
		for i, v in pairs(workspace:GetDescendants()) do
			if v:IsA("StringValue") and v.Name == ("Interactable") then
				v.Name = ("Disabled")
			end
		end


		for i, v in pairs(game.SoundService.SoundStorage.BackgroundAmbients:GetDescendants()) do
			if v:IsA("Sound") then
				local Sound = v
				Sound:Stop()
			end
		end


		game.SoundService.SoundStorage.Machinery.PowerDown:Play()
		MainGenerator.SoundEmmiter.ElectricMotor.Playing = false
		MainGenerator.SoundEmmiter.PowerOn:Stop()
		MainGenerator.RTL.Transparency = 1
		MainGenerator.RTR.Transparency = 1
		MainGenerator.BigGreenBar.Transparency = 1
		MainGenerator.BottomGreen.Transparency = 1
		script.Parent.ClickDetector.MaxActivationDistance = 5
		game.SoundService.SoundStorage.Machinery.PowerDown:Play()

		MainGenerator.Lights.Value = false
		if MainGenerator.Lights.Value == false then
			Lighting.LightsOff.Enabled = true
			for i,v in pairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.Material == Enum.Material.Neon and v.Name ~= "DumbLightScriptIgnore"   then --Makes all slate parts neon
					v.Material = Enum.Material.Slate
				elseif v:IsA("Light")  and v.Parent.Name ~= "DumbLightScriptIgnore" then --Enables all lights
					v.Enabled = false
				end
			end
		end

		------------------------------------------------------------------
	else
		------------------------------------------------------------------

		---------------------------------------------------------Powering On
		script.Parent.ClickDetector.MaxActivationDistance = 0
		Primary.PullSound2:Play()
		MainGenerator.Online.Value = true
		TweenService:Create(Primary,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
		for i, v in pairs(workspace:GetDescendants()) do
			if v:IsA("StringValue") and v.Name == ("Disabled") then
				v.Name = ("Interactable")
			end
		end

		for i, v in pairs(game.SoundService.SoundStorage.BackgroundAmbients:GetDescendants()) do
			if v:IsA("Sound") then
				local Sound = v
				Sound:Play()
			end
		end

		MainGenerator.Lights.Value = true
		Lighting.LightsOff.Enabled = false
		if MainGenerator.Lights.Value == true then
			for i,v in pairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.Material == Enum.Material.Slate and v.Name ~= "DumbLightScriptIgnore" then --Makes all neon parts slate
					v.Material = Enum.Material.Neon
				elseif v:IsA("Light") and v.Parent.Name ~= "DumbLightScriptIgnore" then --Disables all lights
					v.Enabled = true
				end
			end	
			MainGenerator.SoundEmmiter.ElectricMotor.Playing = true
			MainGenerator.SoundEmmiter.PowerOn:Play()
			MainGenerator.RTL.Transparency = 0
			MainGenerator.RTR.Transparency = 0
			wait(0.5)
			MainGenerator.BigGreenBar.Transparency = 0
			wait(0.3)
			MainGenerator.BottomGreen.Transparency = 0
			script.Parent.ClickDetector.MaxActivationDistance = 5

		end

	end
end









script.Parent.ClickDetector.MouseClick:Connect(onClicked)

