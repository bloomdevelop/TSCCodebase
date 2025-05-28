local ControlPanel = script.Parent.Parent.Parent
local OneGLight = script.Parent.Parent.Light.OneGLight
local Button = script.Parent
local ClickDetector = Button.ClickDetector
local CentrifugeSFX = ControlPanel.CentrifugeSFX
local CentrifugeStats = ControlPanel.Stats
local CabSFX = ControlPanel.Parent.Centrifuge.CabSFX
local VelLight = ControlPanel.VelLight

local DB = false
function onClicked()
	if DB or CentrifugeStats.Speed.Value <= 0 then return end
	DB = true
	--//--//--//BOOTUP--//--//--
	ClickDetector.MaxActivationDistance = 0
	OneGLight.BrickColor = BrickColor.new("Moss")
	Button.Click:Play()
	wait(0.5)
	OneGLight.BrickColor = BrickColor.new("Pearl")
	--//--//--//POWERING UP--//--//--
	CentrifugeSFX.AlertSound:Play()
	wait(4)
	ClickDetector.MaxActivationDistance = 5
	--//--//--//SPEEDUP--//--//--
	CentrifugeSFX.Start:Play()
	CentrifugeSFX.Run:Play()
	VelLight.LightSystem.L1.BrickColor = BrickColor.new("Persimmon")
	VelLight.LightSystem.L2.BrickColor = BrickColor.new("Persimmon")
	VelLight.LightSystem.L1.Buzzer:Play()
	VelLight.LightSystem.L1.SurfaceLight.Enabled = true
	CentrifugeStats.Speed.Value -=1
	wait(0.5)
	VelLight.LightSystem.L1.BrickColor = BrickColor.new("Institutional white")
	VelLight.LightSystem.L2.BrickColor = BrickColor.new("Institutional white")
	VelLight.LightSystem.L1.SurfaceLight.Enabled = false
	if CentrifugeStats.Speed.Value <= 0 then
		ClickDetector.MaxActivationDistance = 0
		OneGLight.BrickColor = BrickColor.new("Persimmon")
	end
	CentrifugeStats.Limit.Value = false
	ControlPanel.Parent.CentrifugeBase.Motor.Torque.Torque = Vector3.new(2000000*CentrifugeStats.Speed.Value,0,0)
	script.Parent.Parent.Parent.PlusVelocity.Button.ClickDetector.MaxActivationDistance = 5
	script.Parent.Parent.Parent.PlusVelocity.Light.OneGLight.BrickColor = BrickColor.new("Institutional white")
	DB = false
end


ClickDetector.MouseClick:connect(onClicked)