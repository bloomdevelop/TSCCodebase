
local Click = script.Parent.Click8
local Buzzer = script.Parent.Indicator.Sound

function onClicked()
	script.Parent.ClickDetector.MaxActivationDistance = 0
	Click:Play()
	Buzzer.Parent.BrickColor = BrickColor.new("Persimmon")
	Buzzer:Play()
	wait(1.572)
	Buzzer.Parent.BrickColor = BrickColor.new("Pearl")
	wait(0.5)
	script.Parent.ClickDetector.MaxActivationDistance = 5
end


script.Parent.ClickDetector.MouseClick:Connect(onClicked)