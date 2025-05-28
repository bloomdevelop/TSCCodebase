function OnClicked()
	script.Parent.Parent.Parent.Parent.Keyboard2.ClickDetector.MaxActivationDistance = 5
	script.Parent.Parent.Parent.Parent.Keyboard2.Part.Bliss.Transparency = 0.25
	script.Parent.Parent.Sound:Play()
	wait(45)
	script.Parent.Parent.Parent.Parent.Keyboard2.ClickDetector.MaxActivationDistance = 0
	script.Parent.Parent.Parent.Parent.Keyboard2.Part.Bliss.Transparency = 1
end
script.Parent.MouseClick:Connect(OnClicked)
