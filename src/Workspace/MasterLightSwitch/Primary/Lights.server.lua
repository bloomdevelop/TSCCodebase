slocal SSS = game:GetService("ServerScriptService")
local WHM = require(SSS["Hayper's Scripts"].WebhookHandler)

local db = false

local LightsOn = true
local Primary = workspace.MasterLightSwitch.Primary
local PullSound = workspace.MasterLightSwitch.Primary.PullSound
local tweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local clickDetector = script.Parent.ClickDetector
local Animation = script.Animation
local Darkness = game.Workspace.GlobalSounds.Darkness
local MAD = clickDetector.MaxActivationDistance
local Ambience = game.SoundService.Ambience
local lightTable = {}
local LightsFolder = workspace.LightsFolder

function SoundOff()
	for i,v in pairs(LightsFolder:GetDescendants()) do if v:IsA("Sound") then
			v:Stop()
		end
	end
end

function SoundOn()
	for i,v in pairs(LightsFolder:GetDescendants()) do if v:IsA("Sound") then
			v:Play()
		end
	end
end

for _,light in pairs(workspace.LightsFolder:GetDescendants())do
	if light:IsA("BasePart") and light.Material == Enum.Material.Neon and light.Name ~= "DumbLightScriptIgnore"   then --Makes all slate parts neon
		lightTable[light] = true
	elseif light:IsA("Light")  and light.Parent.Name ~= "DumbLightScriptIgnore" then --Enables all lights
		lightTable[light] = true
	end
end

workspace.LightsFolder.DescendantAdded:Connect(function(desc)
	if desc:IsA("BasePart") and desc.Material == Enum.Material.Neon and desc.Name ~= "DumbLightScriptIgnore"   then --Makes all slate parts neon
		lightTable[desc] = true
	elseif desc:IsA("Light")  and desc.Parent.Name ~= "DumbLightScriptIgnore" then --Enables all lights
		lightTable[desc] = true
	end
end)

workspace.LightsFolder.DescendantRemoving:Connect(function(desc)
	lightTable[desc] = nil
end)

function LightsPowerOn()
	for light in pairs(lightTable) do
		if light:IsA("BasePart")  then --Makes all slate parts neon
			light.Material = Enum.Material.Neon
		else --Enables all lights
			light.Enabled = true							
		end
	end
end
function LightsPowerOff()
	for light in pairs(lightTable) do
		if light:IsA("BasePart") then --Makes all neon parts slate
			light.Material = Enum.Material.Slate
		else  --Disables all lights
			light.Enabled = false			
		end
		end
end
function onClicked(plr)
	if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health ~= 0 and plr.Character:FindFirstChild("HumanoidRootPart") then else return end
	
	if db == false then
		db = true
		
		local root = plr.Character.HumanoidRootPart
		
		if (root.Position - script.Parent.Position).Magnitude <= MAD+5 then
			------------------------------------------------------------------POWERS ON LIGHTS
			PullSound:Play()
			clickDetector.MouseClick:Connect(function(ClickyBaka) 
				local AnimationTrack = ClickyBaka.Character:WaitForChild("Humanoid"):LoadAnimation(Animation) 
				AnimationTrack:Play() 
			end)
			if not Lighting.LightsOff.Outage.Value then
				LightsOn = not LightsOn
				if LightsOn then
					tweenService:Create(script.Parent,TweenInfo.new(0.8,Enum.EasingStyle.Bounce),{CFrame = script.Parent.Parent.ONpos.CFrame}):Play()

				
					LightsPowerOn()
					SoundOn()
					Darkness:Stop()
					game.Workspace.GlobalSounds.LightsOn:Play()
					Lighting.LightsOff.Enabled = false
					wait(3)
					--^^--------------------------------^^^---------------------------POWERS ON LIGHTS^^^
				else
					------------------------------------------------------------------POWERS OFF LIGHTS
					game.Workspace.GlobalSounds.LightsOn:Stop()
					tweenService:Create(script.Parent,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = script.Parent.Parent.OFFpos.CFrame}):Play()
					Darkness:Play()
					LightsPowerOff()
						game.Workspace.GlobalSounds.PowerDown:Play()
						Lighting.LightsOff.Enabled = true
					
					SoundOff()
					for _,v in pairs(workspace.LightsFolder.TSCZLights:GetDescendants()) do
						if v:IsA("SpotLight") then 
							v.Enabled = false
						end
					end
					



					for _,v in pairs(workspace.LightsFolder.TSCZLights:GetDescendants()) do
						if v:IsA("PointLight") then 
							v.Enabled = false
						end
					end
				end
				wait(3)
				----------^^^-------------------------------------------^^^-------POWERS OFF LIGHTS^^^
			else
				--OUTAGE HAS OCCURED, PLAY SOUND OR SMTH
			end
			
		elseif (root.Position - script.Parent.Position).Magnitude >= MAD+25 then
			WHM.queueMessage(plr.Name.." tried to click MASTER LIGHT SWITCH while being "..math.floor((root.Position - script.Parent.Position).Magnitude).." studs away.", "Button")
		end
		
		db = false
	end
end

clickDetector.MouseClick:connect(onClicked)