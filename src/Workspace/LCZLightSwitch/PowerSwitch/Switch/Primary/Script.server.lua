local Primary = script.Parent
local OnPos = script.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.OffPos
local TweenService = game:GetService("TweenService")
local ON = false
local Lights = script.Parent.Parent.Parent.Parent.Lights
local Cringeroni = script.Parent.Parent.Parent.Parent.Lights.Cringeroni
local main = script.Parent.Parent.Parent.Parent
function onClicked()

	ON = not ON
	if ON == true then
		script.Parent.PullSound:Play()
		TweenService:Create(Primary,TweenInfo.new(0.9,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
		for i, v in pairs(Lights:GetDescendants()) do
			if v:IsA("Part") and v.Name == ("DumbLightScriptIgnore") then
				if v:FindFirstChild("DumbLightScriptIgnore") then
					local Light = v:FindFirstChild("DumbLightScriptIgnore")
					Light.Enabled = false
					main.WeeWooWeeWoo.PowerDown:Play()
					wait(0.6)
					Cringeroni.one.Transparency = 0
					Cringeroni.two.Transparency = 0
					Cringeroni.three.Transparency = 0
					Cringeroni.four.Transparency = 0
					Cringeroni.five.Transparency = 0
					Cringeroni.six.Transparency = 0
					
	
					
					
					end
					end
					end
	else
		script.Parent.Sound:Play()
		TweenService:Create(Primary,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
					for i, v in pairs(Lights:GetDescendants()) do
						if v:IsA("Part") and v.Name == ("DumbLightScriptIgnore") then
							if v:FindFirstChild("DumbLightScriptIgnore") then
								local Light = v:FindFirstChild("DumbLightScriptIgnore")
					Light.Enabled = true
					
					Cringeroni.one.Transparency = 1
					Cringeroni.two.Transparency = 1
					Cringeroni.three.Transparency = 1
					Cringeroni.four.Transparency = 1
					Cringeroni.five.Transparency = 1
					Cringeroni.six.Transparency = 1
					
					end
					end
							end
							end
							end
	

script.Parent.ClickDetector.MouseClick:Connect(onClicked)