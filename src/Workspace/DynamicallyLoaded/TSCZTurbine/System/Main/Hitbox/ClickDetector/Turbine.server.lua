local Main = script.Parent.Parent.Parent
local CD = script.Parent
local Down = script.Parent.Parent.Parent.Parent.Down
local Up = script.Parent.Parent.Parent.Parent.Up
local PullSound = Main.PullSound
local TS = game.TweenService
local Turbine = script.Parent.Parent.Parent.Parent.Turbine
local Smog = script.Parent.Parent.Parent.Parent.Smog.Smoke
local TSCZ = workspace.LightsFolder.TSCZLights
local TSCZAlarmPart = workspace.TSCZAlarmPart
function Interact()
	TS:Create(Main,TweenInfo.new(0.6,Enum.EasingStyle.Bounce),{CFrame = Down.CFrame}):Play()
	PullSound:Play()
	CD.MaxActivationDistance = 0
	wait(0.3)
	Turbine.Start:Play()
	Smog.Enabled = true
	wait(0.7)
	TS:Create(Main,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = Up.CFrame}):Play()
	wait(1.2)
	Turbine.Run:Play()
	TSCZAlarmPart.PowerOn:Play()
	for i,v in pairs(workspace.LightsFolder.TSCZLights:GetDescendants()) do
		if v:IsA("SpotLight") then
			v.Enabled = true
		elseif v:IsA("BasePart") and v.Material == Enum.Material.Ice then
			v.Material = Enum.Material.Neon
		end
		end
	wait(10)
	Turbine.Run.Volume = 1.8
	wait(1)
	Turbine.Run.Volume = 1.5
	wait(1)
	Turbine.Run.Volume = 1
	wait(1)
	Turbine.Run.Volume = 0.5
	wait(1)
	Turbine.Run.Volume = 0.3
	wait(1)
	Turbine.Run.Volume = 0.2
	wait(1)
	Turbine.Run.Volume = 0.1
	wait(1)
	Turbine.Run:Stop()
	Smog.Enabled = false
	Turbine.Run.Volume = 2
	CD.MaxActivationDistance = 5
	
end

CD.MouseClick:Connect(Interact)