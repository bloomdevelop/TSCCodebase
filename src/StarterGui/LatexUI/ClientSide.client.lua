--[[
FoxxoTrystan
LatexUI
29/08/2022
]]

--// Variables/Services
local Players = game:GetService("Players")
local Localplayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Effects = script.Parent:WaitForChild("Effects")
local Vignette = script.Parent:WaitForChild("InfectedVignette")
local Hypno = Effects:WaitForChild("Hypno")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ContaminationVisible = false
local LatexValues = Character:WaitForChild("LatexValues")
local InfectionLevel = LatexValues:WaitForChild("InfectionLevel")
local MaxInfectionValue = LatexValues:WaitForChild("MaxInfectionValue")
local Infected = LatexValues:WaitForChild("Infected")
local LatexColor = LatexValues:WaitForChild("LatexColor")
local Hypnotized = LatexValues:WaitForChild("Hypnotized")
local LatexType = LatexValues:WaitForChild("LatexType")
local IsInfected = require(game:GetService("ReplicatedStorage"):WaitForChild("InfectedCheckModule"))
local TweenyInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

--// Vignette Handle
local function VignetteHandle()
	if not Infected.Value then
		local Change = {}
		if InfectionLevel.Value >= 0 then
			Change = {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}
		elseif InfectionLevel.Value > 0 then
			Change = {
				BackgroundTransparency = ((MaxInfectionValue.Value/InfectionLevel.Value)-1)+0.75,
				ImageTransparency = ((MaxInfectionValue.Value/InfectionLevel.Value)-1)
			}
		end
		TweenService:Create(Vignette, TweenyInfo, Change):Play()
		TweenService:Create(script.HighInfectionAmbience, TweenyInfo, {Volume = ((InfectionLevel.Value/MaxInfectionValue.Value)-0.66)}):Play()
		TweenService:Create(Vignette, TweenyInfo, {BackgroundColor3 = LatexColor.Value, ImageColor3 = LatexColor.Value}):Play()
		Change = nil
	else
		TweenService:Create(Vignette, TweenyInfo, {BackgroundTransparency = ((1)-1)+0.75, ImageTransparency = ((1)-1)})
		TweenService:Create(script.HighInfectionAmbience, TweenyInfo, {Volume = ((1)-0.66)}):Play()
		TweenService:Create(Vignette, TweenyInfo, {BackgroundColor3 = LatexColor.Value, ImageColor3 = LatexColor.Value}):Play()
	end
end

--// ContaminationBar
InfectionLevel.Changed:Connect(VignetteHandle)
MaxInfectionValue.Changed:Connect(VignetteHandle)

--// Effects
--// Hypno
local HypnoSpiral = TweenService:Create(Hypno.Spiral, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0), {Rotation = 360})
Hypnotized.Changed:Connect(function()
	if Hypnotized.Value then
		TweenService:Create(Hypno.Spiral, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {BackgroundTransparency = 0, ImageTransparency = 0}):Play()
		script.Ping:Play()
		HypnoSpiral:Play()
	else
		TweenService:Create(Hypno.Spiral, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {BackgroundTransparency = 1, ImageTransparency = 1}):Play()
		task.wait(0.5)
		HypnoSpiral:Cancel()
		Hypno.Spiral.Rotation = 0
	end
	task.wait(5)
	Hypnotized.Value = false
end)

--// Hivemind
LatexType.Changed:Connect(function()
	local function ApplyHivemind(v, TargetChar)
		local Drone = script.DroneHighlight:Clone()
		local TargetLatexValues = TargetChar:FindFirstChild("LatexValues") or TargetChar:WaitForChild("LatexValues")
		if IsInfected(v) then
			if TargetLatexValues.LatexType.Value == "LightLatex" then
				Drone.OutlineColor = Color3.new(0, 255, 0)
			else
				Drone.OutlineColor = Color3.new(255, 0, 0)
			end
		end
		Drone.Parent = TargetChar
	end
	
	if LatexType.Value == "LightLatex" then
		for i,v in pairs(Players:GetPlayers()) do
			if Localplayer ~= v then
				local TargetChar = v.Character
				
				if (TargetChar) then
					ApplyHivemind(v, TargetChar)
				end				
				
				v.CharacterAdded:Connect(function(NewChar)
					ApplyHivemind(v, NewChar)
				end)
				
				if (TargetChar) then
					local TargetLatexValues = TargetChar:FindFirstChild("LatexValues") or TargetChar:WaitForChild("LatexValues")
					TargetLatexValues.LatexType.Changed:Connect(function()
						ApplyHivemind(v, TargetChar)
					end)
				end
			end
		end
		
		Players.PlayerAdded:Connect(function(v)
			v.CharacterAdded:Connect(function(TargetChar)
				if Localplayer ~= v then
					ApplyHivemind(v, TargetChar)
					
					local TargetLatexValues = TargetChar:FindFirstChild("LatexValues") or TargetChar:WaitForChild("LatexValues")
					TargetLatexValues.LatexType.Changed:Connect(function()
						ApplyHivemind(v, TargetChar)
					end)
				end
			end)
		end)
	end
end)

--// Reset Hivemind
if LatexType ~= "LightLatex" then
	for i,v in pairs(Players:GetPlayers()) do
		local TargetChar = v.Character
		if (TargetChar) then
			local Drone = TargetChar:FindFirstChild("DroneHighlight")
			if (Drone) then
				Drone:Destroy()
			end
			Drone = nil
		end
		TargetChar = nil
	end
end
