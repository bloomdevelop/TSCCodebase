function onClicked()
	script.Parent.ClickDetector.MaxActivationDistance = 0
	
	script.Parent.Parent.Model.Primary.Valve.Value = true
	
	script.Parent.ClickDetector.MaxActivationDistance = 5
	end
script.Parent.ClickDetector.MouseClick:connect(onClicked)