local ControlPanel = script.Parent.Parent.Parent
local Click = script.Parent.Click
local Primary = ControlPanel.CentrifugePower.Primary
local tweenService = game:GetService("TweenService")
local PlusVelocity = ControlPanel.PlusVelocity
local MinusVelocity = ControlPanel.MinusVelocity
local PowerLights = ControlPanel.PowerLightsPanel.PowerLights

local DB = false

function onClicked()
	if DB or Primary.Power.Value == false then return end
	DB = true
	Primary.Power.Value = false
	if Primary.Power.Value == false then
		Primary.Bootup:Play()
		PowerLights.CL5.BrickColor = BrickColor.new("Persimmon")
		wait(0.5)
		Primary.Bootup:Play()
		PowerLights.CL4.BrickColor = BrickColor.new("Persimmon")
		wait(0.5)
		Primary.Bootup:Play()
		PowerLights.CL3.BrickColor = BrickColor.new("Persimmon")
		wait(0.5)
		Primary.Bootup:Play()
		PowerLights.CL2.BrickColor = BrickColor.new("Persimmon")
		wait(0.5)
		Primary.Bootup:Play()
		PowerLights.CL1.BrickColor = BrickColor.new("Persimmon")
		Primary.Bootup:Play()
		Primary.Engaged:Play()
		Primary.Startup:Stop()
		PlusVelocity.Button.ClickDetector.MaxActivationDistance = 0
		MinusVelocity.Button.ClickDetector.MaxActivationDistance = 0
		Primary.ClickDetector.MaxActivationDistance = 5
		Primary.Fan.Playing = false
		ControlPanel.Parent.CentrifugeBase.Motor.Torque.Torque = Vector3.new(0,0,0)
		ControlPanel.Stats.Speed.Value = 0
		ControlPanel.Stats.Limit.Value = false
		ControlPanel.CentrifugeSFX.Run.Playing = false
	end
	DB = false
end

script.Parent.ClickDetector.MouseClick:connect(onClicked)