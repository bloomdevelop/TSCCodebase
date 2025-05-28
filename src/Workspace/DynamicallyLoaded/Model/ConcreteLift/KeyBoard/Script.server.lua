


local Interact = script.Parent
local Sound = Interact.Sound
local Sound2 = Interact.Sound2
local Denied = Interact.Denied
local MagicWord = Interact.MagicWord
local TweenService = game:GetService("TweenService")
ShutterOn = true
function onClicked(plr)
	Interact.ClickDetector.MaxActivationDistance = 0
	if plr.Backpack:FindFirstChild("Card-L3") then
		Sound:Play()
		wait(11)
		Sound2:Play()
		wait(2)
		script.Parent.Parent.KeyPad.Enabled.Value = true
		script.Parent.Parent.KeyPad.keymodel.DumbLightScriptIgnore.BrickColor = BrickColor.new("Cool yellow")
		Interact.ClickDetector.MaxActivationDistance = 5
		wait(60*4)
		script.Parent.Parent.KeyPad.Enabled.Value = false
		script.Parent.Parent.KeyPad.keymodel.DumbLightScriptIgnore.BrickColor = BrickColor.new("Smoky grey")
	else
		Interact.ClickDetector.MaxActivationDistance = 0
		Sound:Play()
		wait(10)
		Denied:Play()
		wait(0.2)
		MagicWord:Play()
		wait(4.3)
		MagicWord:Play()
		wait(4.3)
		MagicWord:Play()
		wait(4.3)
		MagicWord:Play()
		wait(4.3)
		MagicWord:Play()
		wait(4.3)
		Interact.ClickDetector.MaxActivationDistance = 5

	end
end


Interact.ClickDetector.MouseClick:Connect(onClicked)