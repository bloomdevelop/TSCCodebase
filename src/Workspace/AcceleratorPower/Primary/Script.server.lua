local Primary = workspace.AcceleratorPower.Primary
local tweenService = game:GetService("TweenService")
local AcceleratorLights = workspace.AcceleratorLights
local CRGLights = workspace.CRGLights
local Beam = script.Parent.Parent.Parent.Beam
local Start = Beam.Pos.Start
local Past = Beam.Pos.Past

function onClicked()
	Primary.ClickDetector.MaxActivationDistance = 0
	tweenService:Create(script.Parent,TweenInfo.new(0.5),{CFrame = script.Parent.Parent.ONpos.CFrame}):Play()
	task.wait(0.5)
	Primary.Bootup:Play()
	AcceleratorLights.AL1.BrickColor = BrickColor.new("Institutional white")
	task.wait(1)
	AcceleratorLights.AL1.BrickColor = BrickColor.new("Moss")
	Primary.Ding:Play()
	task.wait(1)
	Primary.Bootup:Play()
	AcceleratorLights.AL2.BrickColor = BrickColor.new("Institutional white")
	task.wait(1)
	AcceleratorLights.AL2.BrickColor = BrickColor.new("Moss")
	Primary.Ding:Play()
	task.wait(1)
	Primary.Bootup:Play()
	AcceleratorLights.AL3.BrickColor = BrickColor.new("Institutional white")
	task.wait(1)
	AcceleratorLights.AL3.BrickColor = BrickColor.new("Moss")
	Primary.Ding:Play()
	task.wait(0.5)
	Primary.Startup:Play()
	workspace.CRGLine.BrickColor = BrickColor.new("Moss")
	task.wait(0.5)
	Primary.Bootup:Play()
	CRGLights.CRG1.BrickColor = BrickColor.new("Moss")
	task.wait(0.5)
	Primary.Bootup:Play()
	CRGLights.CRG2.BrickColor = BrickColor.new("Moss")
	task.wait(0.5)
	Primary.Bootup:Play()
	CRGLights.CRG3.BrickColor = BrickColor.new("Moss")
	task.wait(0.5)
	AcceleratorLights.PWRLine.BrickColor = BrickColor.new("Moss")
	Primary.Beep:Play()
	task.wait(0.5)
	Primary.Wirring.Playing = true
	Primary.Wirring.Looped = true
	task.wait(1)
	Primary.Beep:Play()
	task.wait(0.2)
	workspace.Beam.CanCollide = true
	workspace.Beam.CanTouch = true
	workspace.Beam.Transparency = 0
	workspace.Beam.BeamLight.Enabled = true
	tweenService:Create(Beam,TweenInfo.new(0.2),{CFrame = Past.CFrame}):Play()
	workspace.Beam.laser:Play()
	task.wait(0.3)
	workspace.Beam.CanCollide = false
	workspace.Beam.CanTouch = false
	workspace.Beam.Transparency = 1
	workspace.Beam.BeamLight.Enabled = false
	Primary.Wirring.Playing = false
	Primary.Wirring.Looped = false
	tweenService:Create(Beam,TweenInfo.new(0),{CFrame = Start.CFrame}):Play()
	task.wait(2)
	Primary.HLDing:Play()
	task.wait(1)
	AcceleratorLights.PWRLine.BrickColor = BrickColor.new("Persimmon")
	Primary.Bootup:Play()
	task.wait(1)
	Primary.Bootup:Play()
	CRGLights.CRG3.BrickColor = BrickColor.new("Persimmon")
	task.wait(0.2)
	Primary.Bootup:Play()
	CRGLights.CRG2.BrickColor = BrickColor.new("Persimmon")
	task.wait(0.2)
	Primary.Bootup:Play()
	CRGLights.CRG1.BrickColor = BrickColor.new("Persimmon")
	task.wait(0.2)

	workspace.CRGLine.BrickColor = BrickColor.new("Persimmon")
	task.wait(0.2)

	Primary.Bootup:Play()
	AcceleratorLights.AL3.BrickColor = BrickColor.new("Institutional white")
	task.wait(0.2)
	AcceleratorLights.AL3.BrickColor = BrickColor.new("Persimmon")
	--Primary.Ding:Play()
	task.wait(0.2)
	Primary.Bootup:Play()
	AcceleratorLights.AL2.BrickColor = BrickColor.new("Institutional white")
	task.wait(0.2)
	AcceleratorLights.AL2.BrickColor = BrickColor.new("Persimmon")
	--Primary.Ding:Play()
	task.wait(0.2)
	Primary.Bootup:Play()
	AcceleratorLights.AL1.BrickColor = BrickColor.new("Institutional white")
	task.wait(0.2)
	AcceleratorLights.AL1.BrickColor = BrickColor.new("Persimmon")
	--Primary.Ding:Play()
	task.wait(0.5)
	tweenService:Create(script.Parent,TweenInfo.new(0.5),{CFrame = script.Parent.Parent.OFFpos.CFrame}):Play()
	task.wait(1)

	Primary.ClickDetector.MaxActivationDistance = 5
end

script.Parent.ClickDetector.MouseClick:connect(onClicked)

