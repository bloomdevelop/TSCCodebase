local SFX = workspace.ChamberSFX
local Smoke1 = workspace.Smoke1.Smoke
local Smoke2 = workspace.Smoke2.Smoke
local Gas = workspace.DynamicallyLoaded.FurryGas
local Click = workspace.Deactivate.Click

function onClicked()
	task.wait(0.1)
	script.Parent.ClickDetector.MaxActivationDistance = 0
	Click:Play()
	task.wait(0.5)
	SFX.Vent:Play()
	Smoke1.Enabled = false
	Smoke2.Enabled = false
	task.wait(5)
	Gas.CanTouch = false
	task.wait(1)
	SFX.Fan.Playing = false
	task.wait(0.5)
	script.Parent.ClickDetector.MaxActivationDistance = 5
	
end

script.Parent.ClickDetector.MouseClick:connect(onClicked)