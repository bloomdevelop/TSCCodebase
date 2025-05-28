


local Interact = script.Parent
local Sound = Interact.Sound
local Sound2 = Interact.Sound2
local Denied = Interact.Denied
local TweenService = game:GetService("TweenService")
local PanelDoor = script.Parent.Parent.PanelDoor
ShutterOn = true
function onClicked(plr)
	Interact.ClickDetector.MaxActivationDistance = 0
	if script.Parent.Enabled.Value == true then
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.8)
		Sound2:Play()
		wait(2)
		script.Parent.Parent.KeyPad.Enabled.Value = false
		Interact.ClickDetector.MaxActivationDistance = 5
		TweenService:Create(PanelDoor.Primary,TweenInfo.new(1),{CFrame = PanelDoor.Open.CFrame}):Play()
		PanelDoor.Button.ClickDetector.MaxActivationDistance = 5
		wait(60*3)
		TweenService:Create(PanelDoor.Primary,TweenInfo.new(1),{CFrame = PanelDoor.closed.CFrame}):Play()
		PanelDoor.Button.ClickDetector.MaxActivationDistance = 5
	else
		Interact.ClickDetector.MaxActivationDistance = 0
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.7)
		Sound:Play()
		wait(0.8)
		Interact.keymodel.DumbLightScriptIgnore.BrickColor = BrickColor.new("Persimmon")
		Denied:Play()
		wait(0.2)
		Interact.keymodel.DumbLightScriptIgnore.BrickColor = BrickColor.new("Smoky grey")
		Interact.ClickDetector.MaxActivationDistance = 5

	end
end


Interact.ClickDetector.MouseClick:Connect(onClicked)