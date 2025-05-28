local tweenService = game:GetService("TweenService")
local AlarmLights = workspace.AlarmLights

local AlarmEnabled = script.AlarmEnabled

local Tweens = {}

for _,switch in pairs(script.Parent:GetChildren())do
	if switch:IsA("Model") then
		switch.Primary.ClickDetector.MouseClick:Connect(function(plr)
			if plr then
				if plr:DistanceFromCharacter(switch.Primary.ClickDetector.Parent.Position) <= switch.Primary.ClickDetector.MaxActivationDistance+1.1 then
					switch.Primary.PullSound:Play()
					tweenService:Create(switch.Primary,TweenInfo.new(0.8,Enum.EasingStyle.Bounce),{CFrame = switch.ONpos.CFrame}):Play()
					wait(0.7)
					tweenService:Create(switch.Primary,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = switch.OFFpos.CFrame}):Play()
					wait(0.5)
					AlarmEnabled.Value = not AlarmEnabled.Value
				end
			end
		end)
	end
end

AlarmEnabled.Changed:Connect(function()
	local AlarmValue = AlarmEnabled.Value
	
	for _,AlarmLight in pairs(AlarmLights:GetChildren())do
		local LightPart = AlarmLight.Light.DumbLightScriptIgnore
		
		if LightPart:FindFirstChild("SpotLight") then
			--	LightPart.SpotLight.Enabled = AlarmValue
			-- LightPart.Material = LightPart.SpotLight.Enabled and  Enum.Material.Neon or Enum.Material.SmoothPlastic
			if AlarmValue then
				local Tween = tweenService:Create(LightPart,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,-1),{
					Orientation =  Vector3.new(360, LightPart.Orientation.Y, LightPart.Orientation.Z)
				})
				table.insert(Tweens,Tween)
			end
		end
	end
	
	if AlarmValue then
		for _,tween in pairs(Tweens) do if tween then tween:Play() end end
	else
		for _,tween in pairs(Tweens) do if tween then tween:Cancel() end end
		table.clear(Tweens)
		gcinfo()
	end
end)