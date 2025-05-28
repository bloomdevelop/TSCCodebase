local SSS = game:GetService("ServerScriptService")
local WHM = require(SSS["Hayper's Scripts"].WebhookHandler)

local Primary = script.Parent.Parent.Parent.Primary
local OnPos = script.Parent.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.Parent.OffPos
local TweenService = game:GetService("TweenService")
local clickDetector = script.Parent.ClickDetector

local ON = false
local LightsOn = true

local MAD = clickDetector.MaxActivationDistance

local MarkerLights = game.Workspace.MarkerLights

function onClicked(plr)
	if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health ~= 0 and plr.Character:FindFirstChild("HumanoidRootPart") then else return end
	
	local root = plr.Character.HumanoidRootPart
	
	if (root.Position - script.Parent.Position).Magnitude <= MAD+5 then
		if ON == true then
			ON = false
			---------------------------------------------------------Shutting Down
			script.Parent.ClickDetector.MaxActivationDistance = 0
			Primary.PullSound:Play()

			TweenService:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
			for i,v in pairs(MarkerLights:GetChildren()) do
				v.Base.Body.Buzzer:Play()
				v.LightOne.DumbLightScriptIgnore.Transparency = 0
				v.LightTwo.DumbLightScriptIgnore.Transparency = 0
				v.LightOne.DumbLightScriptIgnore.DumbLightScriptIgnore.Enabled = true
				v.LightTwo.DumbLightScriptIgnore.DumbLightScriptIgnore.Enabled = true
			end

			wait(3)

			script.Parent.ClickDetector.MaxActivationDistance = 5
		else
			ON = true
			---------------------------------------------------------Powering On
			script.Parent.ClickDetector.MaxActivationDistance = 0
			Primary.PullSound2:Play()

			TweenService:Create(Primary,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
			for i,v in pairs(MarkerLights:GetChildren()) do
				v.Base.Body.Buzzer:Stop()
				v.LightOne.DumbLightScriptIgnore.Transparency = 1
				v.LightTwo.DumbLightScriptIgnore.Transparency = 1
				v.LightOne.DumbLightScriptIgnore.DumbLightScriptIgnore.Enabled = false
				v.LightTwo.DumbLightScriptIgnore.DumbLightScriptIgnore.Enabled = false
			end
			wait(3)
			script.Parent.ClickDetector.MaxActivationDistance = 5

		end
	elseif (root.Position - script.Parent.Position).Magnitude >= MAD+25 then
		WHM.queueMessage(plr.Name.." tried to click MARKER LIGHT SWITCH while being "..math.floor((root.Position - script.Parent.Position).Magnitude).." studs away.", "Button")
	end
end

script.Parent.ClickDetector.MouseClick:Connect(onClicked)

