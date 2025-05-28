local Speed = script.Parent.Parent.Parent.Parent.Parent.ControlPanel.Stats.Speed
----------------------------------------------------

local textbox = script.Parent.Text

Speed:GetPropertyChangedSignal("Value"):Connect(function()
	script.Parent.Parent.Beep:Play()
	textbox.Text = Speed.Value
end)