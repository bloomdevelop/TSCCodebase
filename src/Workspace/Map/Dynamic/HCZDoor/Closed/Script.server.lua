if script.Parent.Value == false then
	script.Parent.Parent.ButtonTwo.ClickDetector.MaxActivationDistance = 5
	if script.Parent.Value == true then
		script.Parent.Parent.ButtonTwo.ClickDetector.MaxActivationDistance = 0
	end
end