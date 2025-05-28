
local Click = script.Parent.Click8
local Buzzer = script.Parent.Parent.Parent.Indicator.Buzzer

function onClicked()
	script.Parent.ClickDetector.MaxActivationDistance = 0
	Click:Play()
	Buzzer.BrickColor = BrickColor.new("Persimmon")
	wait(60*10)
	Buzzer.BrickColor = BrickColor.new("Shamrock")
	Buzzer.Sound:Play()
	wait(1.572)
	Buzzer.BrickColor = BrickColor.new("Pearl")
	script.Parent.ClickDetector.MaxActivationDistance = 5
end


script.Parent.ClickDetector.MouseClick:Connect(onClicked)